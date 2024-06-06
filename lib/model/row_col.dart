
/// Contains the position of a cell, in terms of row and col
/// 记录糖果所在的位置，第几行第几列
class RowCol extends Object {
  RowCol({
    required this.row,
    required this.col,
    this.x,
    this.y
  });
 final int row;
 final int col;
 final double? x;
 final double? y;



  @override
  bool operator ==(Object other) =>
      identical(this, other) || hashCode == other.hashCode;

  @override
  int get hashCode => row * 1000 + col;

  @override
  String toString() {
    return '[$row][$col]';
  }
}
