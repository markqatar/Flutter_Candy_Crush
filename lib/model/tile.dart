import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'level.dart';

/// Rappresenta una tessera della griglia di gioco di tipo Candy Crush
class Tile extends Object {
  TileType? type;
  int row;
  int col;
  Level? level;
  int depth;
  Widget? _widget;
  double? x;
  double? y;
  bool visible;

  Tile({
    this.type,
    this.row = 0,
    this.col = 0,
    this.level,
    this.depth = 0,
    this.visible = true,
  });

  /// Crea una copia della tessera (utile per swap e animazioni)
  factory Tile.clone(Tile otherTile) {
    Tile newTile = Tile(
      type: otherTile.type,
      row: otherTile.row,
      col: otherTile.col,
      level: otherTile.level,
      depth: otherTile.depth,
      visible: otherTile.visible,
    );
    newTile._widget = otherTile._widget;
    newTile.x = otherTile.x;
    newTile.y = otherTile.y;
    return newTile;
  }

  @override
  int get hashCode => row * 1000 + col;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other.hashCode == hashCode;
  }

  @override
  String toString() {
    return '[$row][$col] => ${type!.name}';
  }

  //
  /// Costruisce il widget grafico della tessera, applicando eventuali decorazioni (es. ghiaccio)
  void build({bool computePosition = true}) {
    if (depth > 0 && type != TileType.wall) {
      // Se la tessera è "congelata" (depth > 0), mostra l'effetto ghiaccio sopra
      _widget = Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Transform.scale(
              scale: 0.8,
              child: _buildDecoration(),
            ),
          ),
          _buildDecoration('deco/ice_02.png'),
        ],
      );
    } else if (type == TileType.empty) {
      // Tessera vuota
      _widget = Container();
    } else {
      // Tessera normale
      _widget = _buildDecoration();
    }
    if (computePosition) {
      setPosition();
    }
  }

  /// Restituisce il widget grafico per la tessera, scegliendo l'immagine in base al tipo
  Widget _buildDecoration([String path = ""]) {
    String imageAsset = path;
    if (imageAsset == "") {
      if (depth < 0) depth = 0;
      switch (type) {
        case TileType.wall:
          imageAsset = "deco/wall.png";
          break;
        case TileType.bomb:
          imageAsset = "bombs/mine.png";
          break;
        case TileType.flare:
          imageAsset = "bombs/tnt.png";
          break;
        case TileType.wrapped:
          imageAsset = "tiles/multicolor.png";
          break;
        case TileType.fireball:
          imageAsset = "bombs/rocket.png";
          break;
        // Bombe colorate: prendi il nome senza l'ultima lettera (H/V) per trovare l'immagine
        case TileType.blueV:
        case TileType.blueH:
        case TileType.redV:
        case TileType.redH:
        case TileType.greenV:
        case TileType.greenH:
        case TileType.orangeV:
        case TileType.orangeH:
        case TileType.purpleV:
        case TileType.purpleH:
        case TileType.yellowV:
        case TileType.yellowH:
          final name = type!.name.substring(0, type!.name.length - 1);
          imageAsset = "bombs/$name.png";
          break;
        default:
          try {
            imageAsset = "tiles/${type!.name}.png";
          } catch (e) {
            return Container();
          }
          break;
      }
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/$imageAsset'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  //
  // Returns the position of this tile in the checkerboard
  // based on its position in the grid (row, col) and
  // the dimensions of the board and a tile
  //
  void setPosition() {
    double bottom =
        level!.boardTop + (level!.numberOfRows - 1) * level!.tileHeight;
    x = level!.boardLeft + col * level!.tileWidth;
    y = bottom - row * level!.tileHeight;
  }

  //
  // Generate a tile to be used during the swap animations
  //
  Tile cloneForAnimation() {
    Tile tile = Tile(level: level, type: type, row: row, col: col);
    tile.build();

    return tile;
  }

  /// Scambia riga, colonna e posizione con un'altra tessera (swap)
  void swapRowColWith(Tile destTile) {
    int tft = destTile.row;
    destTile.row = row;
    row = tft;

    tft = destTile.col;
    destTile.col = col;
    col = tft;

    double? txt = destTile.x;
    destTile.x = x;
    x = txt;

    double? tyt = destTile.y;
    destTile.y = y;
    y = tyt;
  }

  //
  /// Restituisce il widget grafico della tessera con dimensioni specifiche
  Widget get widget => getWidgetSized(level!.tileWidth, level!.tileHeight);

  Widget getWidgetSized(double width, double height) => SizedBox(
        width: width,
        height: height,
        child: _widget,
      );

  //
  /// Ritorna true se la tessera può essere mossa (non è bloccata o speciale)
  bool get canMove => (depth == 0) && (canBePlayed(type!));

  //
  /// Ritorna true se la tessera può cadere (non muro, non vuota, non proibita)
  bool get canFall =>
      type != TileType.wall &&
      type != TileType.forbidden &&
      type != TileType.empty;

  // ----------- FUNZIONI DI SUPPORTO -------------

  /// Genera un tipo di tessera casuale tra quelle normali
  static TileType random(math.Random rnd) {
    int minValue = _firstNormalTile;
    int maxValue = _lastNormalTile;
    int value = rnd.nextInt(maxValue - minValue) + minValue;
    return TileType.values[value];
  }

  static int get _firstNormalTile => TileType.red.index;
  static int get _lastNormalTile => TileType.yellow.index;
  static int get _firstBombTile => TileType.bomb.index;
  static int get _lastBombTile => TileType.fireball.index;

  /// Ritorna true se il tipo è una tessera normale (colorata)
  static bool isNormal(TileType type) {
    int index = type.index;
    return (index >= _firstNormalTile && index <= _lastNormalTile);
  }

  /// Ritorna true se il tipo è una bomba
  static bool isBomb(TileType type) {
    int index = type.index;
    return (index >= _firstBombTile && index <= _lastBombTile);
  }

  /// Ritorna true se la tessera può essere giocata (non muro, non proibita)
  static bool canBePlayed(TileType type) =>
      (type != TileType.wall && type != TileType.forbidden);

  /// Normalizza il tipo di bomba (es. blueV -> bombV)
  static TileType normalizeBombType(TileType bombType) {
    switch (bombType) {
      case TileType.blueV:
      case TileType.redV:
      case TileType.greenV:
      case TileType.orangeV:
      case TileType.purpleV:
      case TileType.yellowV:
        return TileType.bombV;
      case TileType.blueH:
      case TileType.redH:
      case TileType.greenH:
      case TileType.orangeH:
      case TileType.purpleH:
      case TileType.yellowH:
        return TileType.bombH;
      default:
        return bombType;
    }
  }
}

/// Types of tiles
enum TileType {
  forbidden,
  empty,
  red,
  green,
  blue,
  orange,
  purple,
  yellow,
  wall,
  bomb,
  flare,
  blueV,
  blueH,
  redV,
  redH,
  greenV,
  greenH,
  orangeV,
  orangeH,
  purpleV,
  purpleH,
  yellowV,
  yellowH,
  wrapped,
  fireball,
  bombV,
  bombH,
  fished, // combo quadrato 2x2
  multicolor, // combo 5 in fila
  colorTransform, // combo 6 (5+1)
  last,
}
