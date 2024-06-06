import 'dart:collection';
import 'package:candycrush/model/tile.dart';
import 'array_2d.dart';

/// Chain,以糖果为中心，记录其上下左右与之匹配的糖果
class Chain {
  // Number of tiles that compose the chain
  int length = 0;

  // Type of chain (horizontal or vertical)
  ChainType type;

  // List of the tiles, part of the chain
  final _tiles = HashMap<int, Tile>();
  List<Tile> get tiles => _tiles.values.toList();
  // Constructor
  Chain({
    this.length = 0,
    required this.type,
  });

  // Add a tile to the list of unique ones belonging to the chain
  void addTile(Tile? tile) {
    if (tile != null) {
      _tiles.putIfAbsent(tile.hashCode, () => tile);
      length = _tiles.length;
    }
  }

  @override
  String toString() {
    List<String> details =
    tiles.map((Tile tile) => '[${tile.row},${tile.col}]').toList();
    return '$type${details.join(' - ')}';
  }
}

class ChainHelper {
  /// Check if there is a vertical chain.检查是否是竖直匹配
  Chain? checkVerticalChain(int row, int col, Array2d grid) {
    Chain chain = Chain(type: ChainType.vertical);
    int maxHeight = grid.height - 1;
    int minRow = (row - 5).clamp(0, maxHeight);
    int maxRow = (row + 5).clamp(0, maxHeight);
    int index = row;
    TileType? type = grid[row][col]?.type;

    // By default the tested tile is part of the chain
    chain.addTile(grid[row][col]);

    // Search Down，向下搜索
    index = row - 1;
    while (index >= minRow &&
        grid[index][col]?.type != null &&
        grid[index][col]?.type == type &&
        grid[index][col]?.type != TileType.empty) {
      chain.addTile(grid[index][col]);
      index--;
    }

    // Search Up，向上搜素
    index = row + 1;
    while (index <= maxRow &&
        grid[index][col]?.type != null &&
        grid[index][col]?.type == type &&
        grid[index][col]?.type != TileType.empty) {
      chain.addTile(grid[index][col]);
      index++;
    }

    /// If the chain counts at least 3 tiles => return it，如果有3个以上与之相同的糖果则匹配成功
    return chain.length > 2 ? chain : null;
  }

  /// Check if there is a horizontal chain.检查是否水平匹配
  Chain? checkHorizontalChain(int row, int col, Array2d grid) {
    Chain chain = Chain(type: ChainType.horizontal);
    int maxWidth = grid.width - 1;
    int minCol = (col - 5).clamp(0, maxWidth);
    int maxCol = (col + 5).clamp(0, maxWidth);
    int index = col;
    TileType? type = grid[row][col]?.type;

    // By default the tested tile is part of the chain
    chain.addTile(grid[row][col]);

    // Search Left，向左搜索
    index = col - 1;
    while (index >= minCol &&
        grid[index][col]?.type != null &&
        grid[row][index]?.type == type &&
        grid[row][index]?.type != TileType.empty) {
      chain.addTile(grid[row][index]);
      index--;
    }

    // Search Right，向右搜索
    index = col + 1;
    while (index <= maxCol &&
        grid[index][col]?.type != null &&
        grid[row][index]?.type == type &&
        grid[row][index]?.type != TileType.empty) {
      chain.addTile(grid[row][index]);
      index++;
    }

    // If the chain counts at least 3 tiles => return it
    return chain.length > 2 ? chain : null;
  }
}

// Types of chains
enum ChainType {
  horizontal,
  vertical,
}
