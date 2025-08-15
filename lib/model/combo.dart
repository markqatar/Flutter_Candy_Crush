import 'dart:collection';

import 'package:candycrush/model/tile.dart';

import 'chain.dart';

///
/// Rappresenta una combinazione (combo) di tessere trovata sulla griglia
///
///
class Combo {
  /// Tutte le tessere che fanno parte della combo
  final _tiles = HashMap<int, Tile>();
  List<Tile> get tiles => UnmodifiableListView(_tiles.values.toList());

  /// Tipo di combo (tris, quattro, cinque, ecc.)
  ComboType _type = ComboType.none;
  ComboType get type => _type;

  /// Tipo di tessera risultante dalla combo (es. bomba, razzo, ecc.)
  TileType? resultingTileType;

  /// Tessera centrale/responsabile della combo (se presente)
  Tile? commonTile;

  /// Una tessera della combo (usata per determinare il colore delle bombe H/V)
  Tile? oneTile;

  /// True se la combo da 4 è orizzontale
  bool combo4IsHorizontal = false;

  /// Costruttore: riceve le catene orizzontali/verticali e calcola la combo
  Combo(Chain? horizontalChain, Chain? verticalChain, int row, int col) {
    if (horizontalChain == null && verticalChain == null) return;

    // Aggiungi tutte le tessere della catena orizzontale
    horizontalChain?.tiles.forEach((Tile tile) {
      oneTile = tile;
      _tiles.putIfAbsent(tile.hashCode, () => tile);
    });

    // Aggiungi tutte le tessere della catena verticale
    verticalChain?.tiles.forEach((Tile tile) {
      if (commonTile == null &&
          horizontalChain != null &&
          _tiles.keys.contains(tile.hashCode)) {
        commonTile = tile;
      }
      _tiles.putIfAbsent(tile.hashCode, () => tile);
      oneTile = tile;
    });

    int total = _tiles.length;
    _type = ComboType.values[total];

    // Se la combo è >3 ma non è una croce, trova la tessera centrale
    if (total > 3 && commonTile == null) {
      for (final tile in _tiles.values) {
        if (tile.row == row && tile.col == col) {
          commonTile = tile;
        }
      }
    }

    // --- LOGICA SPECIALE PER LE COMBO ---
    // 1. Combo da 4: striped (riga/colonna) oppure quadrato (fished)
    if (total == 4) {
      // Verifica se è un quadrato 2x2
      bool isSquare = false;
      if (_tiles.length == 4) {
        final rows = _tiles.values.map((t) => t.row).toSet();
        final cols = _tiles.values.map((t) => t.col).toSet();
        if (rows.length == 2 && cols.length == 2) {
          // Sono su due righe e due colonne adiacenti
          List<int> r = rows.toList()..sort();
          List<int> c = cols.toList()..sort();
          if ((r[1] - r[0] == 1) && (c[1] - c[0] == 1)) {
            isSquare = true;
          }
        }
      }
      if (isSquare) {
        resultingTileType = TileType.fished;
      } else {
        // striped: orizzontale o verticale
        if (oneTile != null) {
          combo4IsHorizontal = (horizontalChain != null);
          switch (oneTile!.type) {
            case TileType.red:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.redH : TileType.redV;
              break;
            case TileType.green:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.greenH : TileType.greenV;
              break;
            case TileType.blue:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.blueH : TileType.blueV;
              break;
            case TileType.orange:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.orangeH : TileType.orangeV;
              break;
            case TileType.yellow:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.yellowH : TileType.yellowV;
              break;
            case TileType.purple:
              resultingTileType =
                  !combo4IsHorizontal ? TileType.purpleH : TileType.purpleV;
              break;
            default:
              resultingTileType = TileType.flare;
          }
        } else {
          resultingTileType = TileType.flare;
        }
      }
    }
    // 2. Combo da 5 in fila: multicolor
    else if (total == 5) {
      // Verifica se sono tutti su stessa riga o colonna
      final rows = _tiles.values.map((t) => t.row).toSet();
      final cols = _tiles.values.map((t) => t.col).toSet();
      if (rows.length == 1 || cols.length == 1) {
        resultingTileType = TileType.multicolor;
      } else {
        resultingTileType = TileType.wrapped; // fallback
      }
    }
    // 3. Combo da 6 (5+1): colorTransform
    else if (total == 6) {
      resultingTileType = TileType.colorTransform;
    }
    // 4. Combo da 7: fireball (come prima)
    else if (total == 7) {
      resultingTileType = TileType.fireball;
    }
  }
}

//
// Tutti i tipi di combo possibili (in base al numero di tessere)
//
enum ComboType {
  none,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
}
