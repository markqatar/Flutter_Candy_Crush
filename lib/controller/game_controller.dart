import 'dart:collection';
import 'dart:math' as math;

import '../bloc/game_bloc.dart';
import '../model/array_2d.dart';
import '../model/chain.dart';
import '../model/combo.dart';
import '../model/level.dart';
import '../model/row_col.dart';
import '../model/swap.dart';
import '../model/swap_move.dart';
import '../model/tile.dart';

class GameController {
  late Level level;
  late Array2d<Tile> _grid;
  Array2d<Tile> get grid => _grid;
  late math.Random _rnd;

  //
  /// Lista di tutti gli swap possibili (mosse valide)
  //
  late HashMap<int, Swap> _swaps;
  List<Swap> get swaps => _swaps.values.toList();

  //
  /// Aiutante per identificare le variazioni di una mossa (serve a determinare gli swap possibili)
  //
  static final List<SwapMove> _moves = <SwapMove>[
    const SwapMove(row: 0, col: -1),
    const SwapMove(row: 0, col: 1),
    const SwapMove(row: -1, col: 0),
    const SwapMove(row: 1, col: 0),
  ];

  //
  /// Aiutante per identificare le posizioni coinvolte in un'esplosione, a seconda del tipo di bomba
  //
  final Map<TileType, List<SwapMove>> _explosions = {
    TileType.bombH: <SwapMove>[
      const SwapMove(row: 0, col: -1),
      const SwapMove(row: 0, col: -2),
      const SwapMove(row: 0, col: -3),
      const SwapMove(row: 0, col: -4),
      const SwapMove(row: 0, col: -5),
      const SwapMove(row: 0, col: -6),
      const SwapMove(row: 0, col: -7),
      const SwapMove(row: 0, col: -8),
      const SwapMove(row: 0, col: -9),
      const SwapMove(row: 0, col: -10),
      const SwapMove(row: 0, col: 0),
      const SwapMove(row: 0, col: 1),
      const SwapMove(row: 0, col: 2),
      const SwapMove(row: 0, col: 3),
      const SwapMove(row: 0, col: 4),
      const SwapMove(row: 0, col: 5),
      const SwapMove(row: 0, col: 6),
      const SwapMove(row: 0, col: 7),
      const SwapMove(row: 0, col: 8),
      const SwapMove(row: 0, col: 9),
      const SwapMove(row: 0, col: 10),
    ],
    TileType.bombV: <SwapMove>[
      const SwapMove(col: 0, row: -1),
      const SwapMove(col: 0, row: -2),
      const SwapMove(col: 0, row: -3),
      const SwapMove(col: 0, row: -4),
      const SwapMove(col: 0, row: -5),
      const SwapMove(col: 0, row: -6),
      const SwapMove(col: 0, row: -7),
      const SwapMove(col: 0, row: -8),
      const SwapMove(col: 0, row: -9),
      const SwapMove(col: 0, row: -10),
      const SwapMove(col: 0, row: 0),
      const SwapMove(col: 0, row: 1),
      const SwapMove(col: 0, row: 2),
      const SwapMove(col: 0, row: 3),
      const SwapMove(col: 0, row: 4),
      const SwapMove(col: 0, row: 5),
      const SwapMove(col: 0, row: 6),
      const SwapMove(col: 0, row: 7),
      const SwapMove(col: 0, row: 8),
      const SwapMove(col: 0, row: 9),
      const SwapMove(col: 0, row: 10),
    ],
    TileType.flare: <SwapMove>[
      const SwapMove(row: 0, col: -1),
      const SwapMove(row: 0, col: 1),
      const SwapMove(row: -1, col: 0),
      const SwapMove(row: 1, col: 0),
      const SwapMove(row: 0, col: 0),
    ],
    TileType.bomb: <SwapMove>[
      const SwapMove(row: 0, col: -2),
      const SwapMove(row: 0, col: -1),
      const SwapMove(row: 0, col: 1),
      const SwapMove(row: 0, col: 2),
      const SwapMove(row: -1, col: 0),
      const SwapMove(row: -1, col: -1),
      const SwapMove(row: -1, col: 1),
      const SwapMove(row: 1, col: -1),
      const SwapMove(row: 1, col: 0),
      const SwapMove(row: 1, col: 1),
      const SwapMove(row: -2, col: 0),
      const SwapMove(row: 2, col: 0),
      const SwapMove(row: 0, col: 0),
    ],
    TileType.wrapped: <SwapMove>[
      const SwapMove(row: 0, col: -3),
      const SwapMove(row: 0, col: -2),
      const SwapMove(row: 0, col: -1),
      const SwapMove(row: 0, col: 1),
      const SwapMove(row: 0, col: 2),
      const SwapMove(row: 0, col: 3),
      const SwapMove(row: -1, col: -2),
      const SwapMove(row: -1, col: -1),
      const SwapMove(row: -1, col: 0),
      const SwapMove(row: -1, col: 1),
      const SwapMove(row: -1, col: 2),
      const SwapMove(row: 1, col: -2),
      const SwapMove(row: 1, col: -1),
      const SwapMove(row: 1, col: 0),
      const SwapMove(row: 1, col: 1),
      const SwapMove(row: 1, col: 2),
      const SwapMove(row: -2, col: -1),
      const SwapMove(row: -2, col: 0),
      const SwapMove(row: -2, col: 1),
      const SwapMove(row: 2, col: -1),
      const SwapMove(row: 2, col: 0),
      const SwapMove(row: 2, col: 1),
      const SwapMove(row: -3, col: 0),
      const SwapMove(row: 3, col: 0),
      const SwapMove(row: 0, col: 0),
    ],
  };

  //
  /// Inizializzazione del controller di gioco
  //
  GameController({
    required this.level,
  }) {
    // Inizializza la griglia alle dimensioni del livello e la riempie di tessere vuote
    _grid = Array2d<Tile>(level.numberOfRows, level.numberOfCols,
        defaultValue: Tile(type: TileType.empty));

    // Inizializza il generatore casuale
    _rnd = math.Random();

    // Inizializza la struttura per gli swap
    _swaps = HashMap<int, Swap>();
  }

  ///
  /// Inizializza le tessere nella griglia di gioco (solo celle vuote)
  ///
  void shuffle() {
    TileType type;
    Array2d<Tile> clone = _grid.clone();
    bool isFirst = true;

    do {
      if (!isFirst) {
        _grid = clone.clone();
      }
      isFirst = false;

      //
      // 1. Riempie le celle vuote
      //
      for (int row = 0; row < level.numberOfRows; row++) {
        for (int col = 0; col < level.numberOfCols; col++) {
          // Considera solo le celle vuote
          if (_grid[row][col].type != TileType.empty) {
            continue;
          }

          late Tile tile;
          switch (level.grid[row][col]) {
            case '1': // Regular cell
            case '2': // Regular cell but frozen

              do {
                type = Tile.random(_rnd);
              } while ((col > 1 &&
                      _grid[row][col - 1].type == type &&
                      _grid[row][col - 2].type == type) ||
                  (row > 1 &&
                      _grid[row - 1][col].type == type &&
                      _grid[row - 2][col].type == type));
              tile = Tile(
                  row: row,
                  col: col,
                  type: type,
                  level: level,
                  depth: (level.grid[row][col] == '2') ? 1 : 0);
              break;

            case 'X':
              // No cell
              tile = Tile(
                  row: row,
                  col: col,
                  type: TileType.forbidden,
                  level: level,
                  depth: 1);
              break;

            case 'W':
              // A wall
              tile = Tile(
                  row: row,
                  col: col,
                  type: TileType.wall,
                  level: level,
                  depth: 1);
              break;
          }

          // Assign the tile
          _grid[row][col] = tile;
        }
      }

      //
      // 2. Identifica le mosse possibili (swap)
      //
      identifySwaps();
    } while (_swaps.isEmpty);

    //
    // Una volta pronta la griglia, costruisce i widget delle tessere
    //
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        // Considera solo le celle autorizzate (non proibite)
        if (_grid[row][col].type == TileType.forbidden) continue;

        _grid[row][col].build();
      }
    }
  }

  //
  /// Identifica tutte le mosse possibili (swap validi)
  //
  void identifySwaps() {
    _swaps.clear();
    int index;
    int destRow;
    int destCol;
    int totalRows = _grid.height;
    int totalCols = _grid.width;
    Tile fromTile;
    Tile toTile;
    bool isSrcNormalTile;
    bool isSrcBombTile;
    bool isDestNormalTile;
    bool isDestBombTile;

    SwapMove move;

    for (int row = 0; row < totalRows; row++) {
      for (int col = 0; col < totalCols; col++) {
        index = -1;
        fromTile = Tile.clone(_grid[row][col]);

        isSrcNormalTile = Tile.isNormal(fromTile.type!);
        isSrcBombTile = Tile.isBomb(fromTile.type!);

        if (isSrcNormalTile || isSrcBombTile) {
          do {
            index++;
            move = _moves[index];
// TODO: controlla se la mossa è permessa (barriere)
            destRow = row + move.row;
            destCol = col + move.col;

            if (destRow > -1 &&
                destRow < totalRows &&
                destCol > -1 &&
                destCol < totalCols) {
              toTile = Tile.clone(_grid[destRow][destCol]);

              // Se la destinazione non esiste, salta
              if (toTile.type == TileType.forbidden) continue;

              // Se la tessera di partenza è una bomba o la destinazione è vuota, tutti gli swap sono possibili
              if (isSrcBombTile) {
                _addSwaps(fromTile, toTile);
                continue;
              }

              isDestNormalTile = Tile.isNormal(toTile.type!);
              isDestBombTile = Tile.isBomb(toTile.type!);

              // Se la destinazione è una bomba, tutti gli swap sono possibili
              if (isDestBombTile) {
                _addSwaps(fromTile, toTile);
                continue;
              }

              // Se si vogliono scambiare tessere dello stesso tipo, salta
              if (toTile.type == fromTile.type) continue;

              if (isDestNormalTile || toTile.type == TileType.empty) {
                // Scambia le tessere
                _grid[destRow][destCol] =
                    Tile(row: row, col: col, type: fromTile.type, level: level);
                _grid[row][col] = Tile(
                    row: destRow,
                    col: destCol,
                    type: toTile.type,
                    level: level);

                //
                // Controlla se questo scambio crea una catena (combo)
                //
                ChainHelper chainHelper = ChainHelper();

                Chain? chainH =
                    chainHelper.checkHorizontalChain(destRow, destCol, _grid);
                if (chainH != null) {
                  _addSwaps(fromTile, toTile);
                }

                Chain? chainV =
                    chainHelper.checkVerticalChain(destRow, destCol, _grid);
                if (chainV != null) {
                  _addSwaps(fromTile, toTile);
                }

                chainH = chainHelper.checkHorizontalChain(row, col, _grid);
                if (chainH != null) {
                  _addSwaps(toTile, fromTile);
                }

                chainV = chainHelper.checkVerticalChain(row, col, _grid);
                if (chainV != null) {
                  _addSwaps(toTile, fromTile);
                }

                // Ripristina la situazione originale
                _grid[destRow][destCol] = toTile;
                _grid[row][col] = fromTile;
              }
            }
          } while (index < 3);
        }
      }
    }
  }

  //
  /// Poiché l'hashCode varia a seconda della direzione dello swap, bisogna registrare entrambi
  //
  void _addSwaps(Tile fromTile, Tile toTile) {
    Swap newSwap = Swap(from: fromTile, to: toTile);
    _swaps.putIfAbsent(newSwap.hashCode, () => newSwap);

    newSwap = Swap(from: toTile, to: fromTile);
    _swaps.putIfAbsent(newSwap.hashCode, () => newSwap);
  }

  //
  /// Controlla se lo swap tra due tessere è valido
  //
  bool swapContains(Tile source, Tile destination) {
    Swap testSwap = Swap(from: source, to: destination);
    return _swaps.keys.contains(testSwap.hashCode);
  }

  /// Scambia due tessere (swap di posizione e coordinate)
  void swapTiles(Tile source, Tile destination) {
    RowCol sourceRowCol = RowCol(row: source.row, col: source.col);
    RowCol destRowCol = RowCol(row: destination.row, col: destination.col);

    // Scambia posizione e coordinate tra le due tessere
    source.swapRowColWith(destination);
    Tile tft = grid[sourceRowCol.row][sourceRowCol.col];
    grid[sourceRowCol.row][sourceRowCol.col] =
        grid[destRowCol.row][destRowCol.col];
    grid[destRowCol.row][destRowCol.col] = tft;
  }

  //
  /// Ottiene la combo risultante da una mossa
  //
  Combo getCombo(int row, int col) {
    ChainHelper chainHelper = ChainHelper();
    Chain? verticalChain = chainHelper.checkVerticalChain(row, col, _grid);
    Chain? horizontalChain = chainHelper.checkHorizontalChain(row, col, _grid);

    return Combo(horizontalChain, verticalChain, row, col);
  }

  /// Risolve una combo (rimozione delle tessere coinvolte)
  void resolveCombo(Combo combo, GameBloc gameBloc) {
    // We now need to remove all the Tiles from the grid and change the type if necessary
    for (final tile in combo.tiles) {
      if (tile != combo.commonTile) {
        // Decrementa il livello di "congelamento" o rimuove la tessera
        if (--grid[tile.row][tile.col].depth < 0) {
          // Aggiorna eventuali obiettivi
          gameBloc.pushTileEvent(grid[tile.row][tile.col].type, 1);
          // Se la profondità è minore di 0, la tessera può essere rimossa
          grid[tile.row][tile.col].type = TileType.empty;
        }
        // Ricostruisce il widget della tessera
        grid[tile.row][tile.col].build();
      } else {
        grid[tile.row][tile.col].row = combo.commonTile!.row;
        grid[tile.row][tile.col].col = combo.commonTile!.col;
        grid[tile.row][tile.col].type = combo.resultingTileType;
        grid[tile.row][tile.col].visible = true;
        grid[tile.row][tile.col].build();

        // Notifica la creazione di una nuova tessera speciale
        gameBloc.pushTileEvent(combo.resultingTileType!, 1);
      }
    }
  }

  //
  /// Ricostruisce la griglia dopo le animazioni
  //
  void refreshGridAfterAnimations(
      Array2d<TileType> tileTypes, Set<RowCol> involvedCells) {
    for (final rowCol in involvedCells) {
      _grid[rowCol.row][rowCol.col].row = rowCol.row;
      _grid[rowCol.row][rowCol.col].col = rowCol.col;
      _grid[rowCol.row][rowCol.col].type = tileTypes[rowCol.row][rowCol.col];
      _grid[rowCol.row][rowCol.col].visible = true;
      _grid[rowCol.row][rowCol.col].depth = 0;
      _grid[rowCol.row][rowCol.col].build();
    }
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        if (_grid[row][col].visible == false ||
            (_grid[row][col].visible == true &&
                _grid[row][col].type == TileType.empty)) {
          final color = (["red", "green", "blue", "orange", "purple", "yellow"]
                ..shuffle())
              .first;
          final newType =
              TileType.values.firstWhere((element) => element.name == color);
          _grid[row][col].visible = true;
          _grid[row][col].type = (_grid[row][col].type != TileType.empty)
              ? _grid[row][col].type
              : (tileTypes[row][col] != TileType.empty)
                  ? tileTypes[row][col]
                  : newType;

          _grid[row][col].depth = 0;
          _grid[row][col].build();
        }
      }
    }
  }

  //
  /// Gestisce un'esplosione (la propagazione dipende dal tipo di bomba)
  //
  void proceedWithExplosion(Tile tileExplosion, GameBloc gameBloc,
      {bool skipThis = false}) {
    // Normalizza il tipo di bomba
    TileType? expositionType = Tile.normalizeBombType(tileExplosion.type!);

    // Recupera la lista delle variazioni di posizione
    List<SwapMove>? swaps = _explosions[expositionType];

    // Registra eventuali esplosioni concatenate (bombe che fanno esplodere altre bombe)
    List<Tile> subExplosions = <Tile>[];

    // Tutte le tessere nell'area esplodono
    swaps?.forEach((SwapMove move) {
      int row = tileExplosion.row + move.row;
      int col = tileExplosion.col + move.col;

      // Controlla se la cella è valida
      if (row > -1 &&
          row < level.numberOfRows &&
          col > -1 &&
          col < level.numberOfCols) {
        // E se la tessera può essere fatta esplodere
        if (level.grid[row][col] == '1') {
          Tile? tile = _grid[row][col];
          if (tile != null &&
              Tile.isBomb(tile.type!) &&
              !skipThis &&
              tile.row != tileExplosion.row &&
              tile.col != tileExplosion.col) {
            // Un'altra bomba deve esplodere (esplosione concatenata)
            subExplosions.add(tile);
          } else {
            // Notifica la rimozione di tessere
            gameBloc.pushTileEvent(tile!.type!, 1);

            // Svuota la cella
            if (tile.depth == 0) {
              tile.type = TileType.empty;
            } else {
              // Se la tessera era congelata, scongela di un livello
              tile.depth--;
            }
            tile.build();
          }
        }
      }
    });

    // Procedi con le esplosioni concatenate
    for (final tile in subExplosions) {
      proceedWithExplosion(tile, gameBloc, skipThis: true);
    }
  }

  //
  /// Controlla se ci sono ancora mosse possibili
  //
  bool stillMovesToPlay() {
    if (_swaps.isEmpty) {
      // Se non ci sono più swap, controlla se ci sono ancora bombe
      for (int row = 0; row < level.numberOfRows; row++) {
        for (int col = 0; col < level.numberOfCols; col++) {
          Tile tile = _grid[row][col] as Tile;

          if (level.grid[row][col] == '1' && Tile.isBomb(tile.type!)) {
            // C'è una bomba, quindi si può ancora giocare
            return true;
          }
        }
      }

      return false;
    }
    return true;
  }

  //
  /// Mischia la griglia (reshuffling)
  //
  void reshuffling() {
    // Rimuove tutte le celle normali
    for (int row = 0; row < level.numberOfRows; row++) {
      for (int col = 0; col < level.numberOfCols; col++) {
        Tile tile = _grid[row][col] as Tile;

        if (Tile.isNormal(tile.type!)) {
          _grid[row][col].type = TileType.empty;
          // tile = null;
        }
      }
    }

    // Poi riempie le celle vuote
    shuffle();
  }
}
