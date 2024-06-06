

import 'package:candycrush/model/tile.dart';


/// Identifies a possible swap between 2 tiles
/// 识别两个糖果之间是否能交换
class Swap extends Object {
  Tile from;
  Tile to;

  Swap({
    required this.from,
    required this.to,
  });

  @override
  int get hashCode => from.hashCode * 1000 + to.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) || other.hashCode == hashCode;
  }

  @override
  String toString() => '[${from.row}][${from.col}] => [${to.row}][${to.col}]';
}
