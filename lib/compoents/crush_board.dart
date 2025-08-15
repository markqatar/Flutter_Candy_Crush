import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../model/array_2d.dart';
import 'package:candycrush/bloc/bloc_provider.dart';
import 'package:candycrush/bloc/game_bloc.dart';
import '../model/level.dart';

class CrushBoard extends StatefulWidget {
  const CrushBoard({super.key, required this.level});

  final Level level;

  @override
  State<CrushBoard> createState() => _CrushBoardState();
}

class _CrushBoardState extends State<CrushBoard> {
  Array2d<BoxDecoration>? _decorations;
  Array2d<Color>? _checker;
  final _keyChecker = GlobalKey();
  final _keyCheckerCell = GlobalKey();
  late GameBloc gameBloc;

  @override
  void initState() {
    super.initState();
    // As the GridView.builder builds top to bottom
    // and we need to compute the decorations bottom up
    // we need to do it at first
    _buildDecorations();
    _buildChecker();
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild());
  }

  /// 显示游戏棋盘
  void _buildDecorations() {
    if (_decorations != null) return;
    _decorations = Array2d<BoxDecoration>(
        widget.level.numberOfCols + 1, widget.level.numberOfRows + 1);
    for (int row = 0; row <= widget.level.numberOfRows; row++) {
      for (int col = 0; col <= widget.level.numberOfCols; col++) {
        // If there is nothing at (row, col) => no decoration
        int topLeft = 0;
        int bottomLeft = 0;
        int topRight = 0;
        int bottomRight = 0;
        BoxDecoration? boxDecoration;
        if (col > 0) {
          if (row < widget.level.numberOfRows) {
            if (widget.level.grid[row][col - 1] != 'X') {
              topLeft = 1;
            }
          }
          if (row > 0) {
            if (widget.level.grid[row - 1][col - 1] != 'X') {
              bottomLeft = 1;
            }
          }
        }
        if (col < widget.level.numberOfCols) {
          if (row < widget.level.numberOfRows) {
            if (widget.level.grid[row][col] != 'X') {
              topRight = 1;
            }
          }
          if (row > 0) {
            if (widget.level.grid[row - 1][col] != 'X') {
              bottomRight = 1;
            }
          }
        }
        int value = topLeft;
        value |= (topRight << 1);
        value |= (bottomLeft << 2);
        value |= (bottomRight << 3);

        if (value != 0 && value != 6 && value != 9) {
          boxDecoration = BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/borders/border_$value.png'),
                fit: BoxFit.cover),
          );
        }
        _decorations![row][col] = boxDecoration;
      }
    }
  }

  void _buildChecker() {
    if (_checker != null) return;

    _checker =
        Array2d<Color>(widget.level.numberOfRows, widget.level.numberOfCols);
    int counter = 0;

    for (int row = 0; row < widget.level.numberOfRows; row++) {
      counter = (row % 2 == 1) ? 0 : 1;
      for (int col = 0; col < widget.level.numberOfCols; col++) {
        final double opacity = ((counter + col) % 2 == 1) ? 0.3 : 0.1;

        Color color = (widget.level.grid[row][col] == 'X')
            ? Colors.transparent
            : Colors.white.withValues(alpha: opacity);

        _checker![row][col] = color;
      }
    }
  }

  /// Costruisce il contenitore dinamico della griglia delle tiles.
  /// La dimensione (righe, colonne) e il layout si adattano ai dati del livello corrente.
  @override
  Widget build(BuildContext context) {
    gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDimension = math.min(screenSize.width, screenSize.height);
    final double maxTileWidth = math.min(maxDimension / 12, 28);

    // Calcola dinamicamente le dimensioni del contenitore della griglia in base a righe/colonne del livello
    final double width = maxTileWidth * (widget.level.numberOfCols + 1) * 1.1;
    final double height = maxTileWidth * (widget.level.numberOfRows + 1) * 1.1;

    // Il contenitore delle tiles è completamente dinamico: si adatta a qualsiasi dimensione di livello
    return Container(
      padding: const EdgeInsets.all(0.0),
      width: width,
      height: height,
      color: Colors.transparent,
      child: Stack(
        children: [
          _showDecorations(maxTileWidth),
          // La griglia delle tiles viene costruita dinamicamente in base ai dati del livello
          _showGrid(maxTileWidth),
        ],
      ),
    );
  }

  /// Mostra le decorazioni dei bordi della griglia (dinamiche)
  Widget _showDecorations(double width) {
    return GridView.builder(
      padding: const EdgeInsets.all(0.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.level.numberOfCols + 1,
        childAspectRatio: 1.01,
      ),
      itemCount:
          (widget.level.numberOfCols + 1) * (widget.level.numberOfRows + 1),
      itemBuilder: (BuildContext context, int index) {
        final int col = index % (widget.level.numberOfCols + 1);
        final int row = (index / (widget.level.numberOfRows + 1)).floor();

        //
        // Use the decoration from bottom up during this build
        //
        return Container(
            decoration: _decorations![widget.level.numberOfRows - row][col]);
      },
    );
  }

  /// Costruisce la griglia delle celle (tiles) in modo dinamico, adattandosi a righe/colonne del livello
  Widget _showGrid(double width) {
    bool isFirst = true;
    return Padding(
      padding: EdgeInsets.all(width * 0.6),
      child: GridView.builder(
        key: _keyChecker,
        padding: const EdgeInsets.all(0.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.level.numberOfCols,
          childAspectRatio: 1.01, // 1.01 risolve problemi di floating point
        ),
        itemCount: widget.level.numberOfCols * widget.level.numberOfRows,
        itemBuilder: (BuildContext context, int index) {
          final int col = index % widget.level.numberOfCols;
          final int row = (index / widget.level.numberOfRows).floor();

          // Ogni cella viene colorata e gestita dinamicamente
          return Container(
            color: _checker![widget.level.numberOfRows - row - 1][col],
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (isFirst) {
                isFirst = false;
                return Container(key: _keyCheckerCell);
              }
              return Container();
            }),
          );
        },
      ),
    );
  }

  Rect _getDimensionsFromContext(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    final Offset topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomRight(box.localToGlobal(Offset.zero));
    return Rect.fromLTRB(
        topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  }

  void _afterBuild() {
    //
    // Let's get the dimensions and position of the exact position of the board
    //
    if (_keyChecker.currentContext != null) {
      final Rect rectBoard =
          _getDimensionsFromContext(_keyChecker.currentContext!);

      //
      // Save the position of the board
      //
      widget.level.boardLeft = rectBoard.left;
      widget.level.boardTop = rectBoard.top;

      //
      // Let's get the dimensions of one cell of the board
      //
      final Rect rectBoardSquare =
          _getDimensionsFromContext(_keyCheckerCell.currentContext!);

      //
      // Save it for later reuse
      //
      widget.level.tileWidth = rectBoardSquare.width;
      widget.level.tileHeight = rectBoardSquare.height;

      //
      // Send a notification to inform that we are ready to display the tiles from now on
      //
      gameBloc.setReadyToDisplayTiles(true);
    }
  }
}
