import 'dart:async';
import 'package:candycrush/controller/game_controller.dart';
import 'package:flutter/material.dart';

import '../animations/animation_chain.dart';
import '../animations/animation_combo_collapse.dart';
import '../animations/animation_combo_three.dart';
import '../animations/animation_swap_tiles.dart';
import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../animations/model/animation_sequence.dart';
import '../animations/model/animations_resolver.dart';
import '../compoents/crush_board.dart';
import '../model/array_2d.dart';
import '../model/audio.dart';
import '../model/combo.dart';
import '../model/level.dart';
import '../model/row_col.dart';
import '../model/tile.dart';
import '../panel/moves/game_moves_left_panel.dart';
import '../panel/objective/components/objective_panel.dart';
import '../splash/game_over_splash.dart';
import '../splash/game_reshuffling_splash.dart';
import '../splash/game_splash.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.level,
  });
  final Level level;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _gameSplash;
  late GameBloc _gameBloc;
  bool _allowGesture = false;
  StreamSubscription? _gameOverSubscription;
  bool? _gameOverReceived;

  ///记录触发手势的糖果
  Tile? _gestureFromTile;
  ///记录触发手势的糖果位置，行和列
  RowCol? _gestureFromRowCol;
  ///记录手势的滑动距离
  Offset? _gestureOffsetStart;
  ///标记手势是否开始
  bool? _gestureStarted;
  static const double _MIN_GESTURE_DELTA = 2.0;
  OverlayEntry? _overlayEntryFromTile;
  OverlayEntry? _overlayEntryAnimateSwapTiles;

  @override
  void initState() {
    super.initState();
    _gameOverReceived = false;
    WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now that the context is available, retrieve the gameBloc
    _gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    // Reset the objectives
    _gameBloc.reset();
    // Listen to "game over" notification
    _gameOverSubscription = _gameBloc.gameIsOver.listen(_onGameOver);
  }

  @override
  void dispose() {
    _gameOverSubscription?.cancel();
    _gameOverSubscription = null;
    _overlayEntryAnimateSwapTiles?.remove();
    _overlayEntryFromTile?.remove();
    _gameSplash?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.close),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: GestureDetector(
          onPanDown: (DragDownDetails details) => _onPanDown(details),
          onPanStart: _onPanStart,
          onPanEnd: _onPanEnd,
          onPanUpdate: (DragUpdateDetails details) => _onPanUpdate(details),
          onTap: _onTap,
          onTapUp: _onPanEnd,
          child: Stack(
            children:[
              _buildMovesLeftPanel(orientation),
              _buildObjectivePanel(orientation),
              _buildBoard(),
              _buildTiles(),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the score panel
  Widget _buildMovesLeftPanel(Orientation orientation) {
    Alignment alignment = orientation == Orientation.portrait
        ? Alignment.topLeft
        : Alignment.topLeft;
    return Align(
      alignment: alignment,
      child: const GameMovesLeftPanel(),
    );
  }

  // Builds the objective panel
  Widget _buildObjectivePanel(Orientation orientation) {
    Alignment alignment = orientation == Orientation.portrait
        ? Alignment.topRight
        : Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: const ObjectivePanel(),
    );
  }

  // Builds the game board
  Widget _buildBoard() {
    return Align(
      alignment: Alignment.center,
      child: CrushBoard(
        level: widget.level,
      ),
    );
  }
  // Builds the tiles
  Widget _buildTiles() {
    return StreamBuilder<bool>(
      stream: _gameBloc.outReadyToDisplayTiles,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          List<Widget> tiles = <Widget>[];
          Array2d<Tile> grid = _gameBloc.gameController.grid;

          for (int row = 0; row < widget.level.numberOfRows; row++) {
            for (int col = 0; col < widget.level.numberOfCols; col++) {
              final Tile tile = grid[row][col];
              if (tile.type != TileType.empty &&
                  tile.type != TileType.forbidden &&
                  tile.visible) {

                // Make sure the widget is correctly positioned
                tile.setPosition();
                tiles.add(Positioned(
                  left: tile.x,
                  top: tile.y,
                  child: tile.widget,
                ));
              }
            }
          }

          return Stack(
            children: tiles,
          );
        }
        // If nothing is ready, simply return an empty container
        return Container();
      },
    );
  }

  //
  // Gesture
  //

  RowCol _rowColFromGlobalPosition(Offset globalPosition) {
    final double top = globalPosition.dy - widget.level.boardTop;
    final double left = globalPosition.dx - widget.level.boardLeft;
    return RowCol(
      col: (left / widget.level.tileWidth).floor(),
      row: widget.level.numberOfRows -
          (top / widget.level.tileHeight).floor() -
          1,
    );
  }

  //
  // The pointer touches the screen
  //
  void _onPanDown(DragDownDetails details) {
    if (!_allowGesture) return;

    // Determine the [row,col] from touch position
    RowCol rowCol = _rowColFromGlobalPosition(details.globalPosition);

    // Ignore if we touched outside the grid
    if (rowCol.row < 0 ||
        rowCol.row >= widget.level.numberOfRows ||
        rowCol.col < 0 ||
        rowCol.col >= widget.level.numberOfCols) return;

    // Check if the [row,col] corresponds to a possible swap
    Tile? selectedTile = _gameBloc.gameController.grid[rowCol.row][rowCol.col];
    bool canBePlayed = false;

    // Reset
    _gestureFromTile = null;
    _gestureStarted = false;
    _gestureOffsetStart = null;
    _gestureFromRowCol = null;

    if (selectedTile != null) {
      //TODO: Condition no longer necessary
      canBePlayed = selectedTile.canMove;
    }

    if (canBePlayed) {
      _gestureFromTile = selectedTile;
      _gestureFromRowCol = rowCol;

      //
      // Let's position the tile on the Overlay and inflate it a bit to make it more visible
      //
      _overlayEntryFromTile = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return Positioned(
              left: _gestureFromTile!.x,
              top: _gestureFromTile!.y,
              child: Transform.scale(
                scale: 1.1,
                child: _gestureFromTile!.widget,
              ),
            );
          });
      Overlay.of(context).insert(_overlayEntryFromTile!);
    }
  }
  //
  // The pointer starts to move
  //
  void _onPanStart(DragStartDetails details) {
    if (!_allowGesture) return;
    if (_gestureFromTile != null) {
      _gestureStarted = true;
      _gestureOffsetStart = details.globalPosition;
    }
  }

  //
  // The user releases the pointer from the screen
  //
  void _onPanEnd(_) {
    if (!_allowGesture) return;
    _gestureStarted = false;
    _gestureOffsetStart = null;
    _overlayEntryFromTile?.remove();
    _overlayEntryFromTile = null;
  }

  //
  // The pointer has been moved since its last "start"
  //
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_allowGesture) return;
    if (_gestureStarted == true) {
      // Try to determine the move type (up, down, left, right)
      Offset delta = details.globalPosition - _gestureOffsetStart!;
      int deltaRow = 0;
      int deltaCol = 0;
      bool test = false;
      if (delta.dx.abs() > delta.dy.abs() &&
          delta.dx.abs() > _MIN_GESTURE_DELTA) {
        // horizontal move
        deltaCol = delta.dx.floor().sign;
        test = true;
      } else if (delta.dy.abs() > _MIN_GESTURE_DELTA) {
        // vertical move
        deltaRow = -delta.dy.floor().sign;
        test = true;
      }

      if (test == true) {
        RowCol rowCol = RowCol(
            row: _gestureFromRowCol!.row + deltaRow,
            col: _gestureFromRowCol!.col + deltaCol);
        if (rowCol.col < 0 ||
            rowCol.col == widget.level.numberOfCols ||
            rowCol.row < 0 ||
            rowCol.row == widget.level.numberOfRows) {
          // Not possible, outside the boundaries
        } else {
          Tile? destTile = _gameBloc.gameController.grid[rowCol.row][rowCol.col];
          bool canBePlayed = false;

          if (destTile != null) {
            //TODO:  Condition no longer necessary
            canBePlayed = destTile.canMove || destTile.type == TileType.empty;
          }

          if (canBePlayed) {
            // We need to test the swap
            bool swapAllowed = _gameBloc.gameController
                .swapContains(_gestureFromTile!, destTile!);

            // Do not allow the gesture recognition during the animation
            _allowGesture = false;

            // 1. Remove the expanded tile
            _overlayEntryFromTile?.remove();
            _overlayEntryFromTile = null;


            // 2. Generate the up/down tiles
            Tile upTile = _gestureFromTile!.cloneForAnimation();
            Tile downTile = destTile.cloneForAnimation();

            // 3. Remove both tiles from the game grid
            _gameBloc.gameController.grid[rowCol.row][rowCol.col].visible = false;
            _gameBloc
                .gameController
                .grid[_gestureFromRowCol!.row][_gestureFromRowCol!.col]
                .visible = false;

            setState(() {});
            // 4. Animate both tiles
            _overlayEntryAnimateSwapTiles = OverlayEntry(
                opaque: false,
                builder: (BuildContext context) {
                  return AnimationSwapTiles(
                    upTile: upTile,
                    downTile: downTile,
                    swapAllowed: swapAllowed,
                    onComplete: () async {
                      // 5. Put back the tiles in the game grid
                      _gameBloc.gameController.grid[rowCol.row][rowCol.col]
                          .visible = true;
                      _gameBloc
                          .gameController
                          .grid[_gestureFromRowCol!.row][_gestureFromRowCol!.col]
                          .visible = true;

                      // 6. Remove the overlay Entry
                      _overlayEntryAnimateSwapTiles?.remove();
                      _overlayEntryAnimateSwapTiles = null;

                      if (swapAllowed == true) {
                        // Remember if the tile we move is a bomb
                        bool isSourceTileABomb =
                        Tile.isBomb(_gestureFromTile!.type!);

                        // Swap the 2 tiles，交换目标糖果和原糖果的位置和坐标信息
                        _gameBloc.gameController
                            .swapTiles(_gestureFromTile!, destTile);

                        // Get the tiles that need to be removed, following the swap
                        // We need to get the tiles from all possible combos
                        Combo comboOne = _gameBloc.gameController.getCombo(
                            _gestureFromTile!.row, _gestureFromTile!.col);
                        Combo comboTwo = _gameBloc.gameController
                            .getCombo(destTile.row, destTile.col);

                        /// Wait for both animations to complete
                        await Future.wait(
                            [_animateCombo(comboOne),_animateCombo(comboTwo)]);

                        // Resolve the combos
                        _gameBloc.gameController
                            .resolveCombo(comboOne, _gameBloc);
                        _gameBloc.gameController
                            .resolveCombo(comboTwo, _gameBloc);

                        // If the tile we moved is a bomb, we need to process the explosion
                        if (isSourceTileABomb) {
                          _gameBloc.gameController.proceedWithExplosion(
                              Tile(
                                  row: destTile.row,
                                  col: destTile.row,
                                  type: _gestureFromTile!.type),
                              _gameBloc);
                        }
                        /// Proceed with the falling tiles
                        await _playAllAnimations();

                        /// Once this is all done, we need to recalculate all the possible swaps
                        _gameBloc.gameController.identifySwaps();

                        // Record the fact that we have played a move
                        _gameBloc.playMove();

                        if (!_gameBloc.gameController.stillMovesToPlay()) {
                          // No moves left
                          await _showReshufflingSplash();
                          _gameBloc.gameController.reshuffling();
                          setState(() {});
                        }
                        // Make sure there is a correct delay before refreshing the screen
                        await Future.delayed(const Duration(milliseconds: 300));
                      }

                      // 7. Reset
                      _allowGesture = true;
                      _onPanEnd(null);
                      if(mounted){
                        setState(() {});
                      }
                    },
                  );
                });
            Overlay.of(context).insert(_overlayEntryAnimateSwapTiles!);
          }
        }
      }
    }
  }

  /// The user tap on a tile, is this a bomb ?
  /// If yes make it explode
  void _onTap() {
    if (!_allowGesture) return;
    if (_gestureFromTile != null && Tile.isBomb(_gestureFromTile!.type!)) {
      // Prevent the user from playing during the animation
      _allowGesture = false;
      print("playAsset==============");
      // Play explosion
      Audio.playAsset(AudioType.bomb);

      // Proceed with explosion
      _gameBloc.gameController.proceedWithExplosion(_gestureFromTile!, _gameBloc);

      // Rebuild the board and proceed with animations
      WidgetsBinding.instance.addPostFrameCallback((_) async {

        // Proceed with the falling tiles
        await _playAllAnimations();

        // Once this is all done, we need to recalculate all the possible swaps
        _gameBloc.gameController.identifySwaps();

        // The user may now play
        _allowGesture = true;

        // Record the fact that we have played a move
        _gameBloc.playMove();

        // Check if there are still moves to play
        if (!_gameBloc.gameController.stillMovesToPlay()) {
          // No moves left
          await _showReshufflingSplash();
          _gameBloc.gameController.reshuffling();
          setState(() {});
        }
      });
    }
  }

  /// Show/hide the tiles related to a Combo.
  /// This is used just before starting an animation
  void _showComboTilesForAnimation(Combo combo, bool visible) {
    for (final tile in combo.tiles) {
      tile.visible = visible;
    }
    setState(() {});
  }

  /// Launch an Animation which returns a Future when completed
  Future<dynamic> _animateCombo(Combo combo) async {
    final completer = Completer();
    OverlayEntry? overlayEntry;

    switch (combo.type) {
      case ComboType.three:
      // Hide the tiles before starting the animation
        _showComboTilesForAnimation(combo, false);

        // Launch the animation for a chain of 3 tiles
        overlayEntry = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return AnimationComboThree(
              combo: combo,
              onComplete: () {
                overlayEntry?.remove();
                overlayEntry = null;
                completer.complete(null);
              },
            );
          },
        );

        // Play sound
        await Audio.playAsset(AudioType.move_down);
        if(mounted){
          Overlay.of(context).insert(overlayEntry!);
        }
        break;

      case ComboType.none:
      case ComboType.one:
      case ComboType.two:
      // These type of combos are not possible, therefore directly return
        completer.complete(null);
        break;

      default:
      // Hide the tiles before starting the animation
        _showComboTilesForAnimation(combo, false);

        // We need to create the resulting tile
        Tile? resultingTile = Tile(
          col: combo.commonTile!.col,
          row: combo.commonTile!.row,
          type: combo.resultingTileType,
          level: widget.level,
          depth: 0,
        );
        resultingTile.build();

        // Launch the animation for a chain more than 3 tiles
        overlayEntry = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return AnimationComboCollapse(
              combo: combo,
              resultingTile: resultingTile!,
              onComplete: () {
                resultingTile = null;
                overlayEntry?.remove();
                overlayEntry = null;

                completer.complete(null);
              },
            );
          },
        );

        // Play sound
        await Audio.playAsset(AudioType.swap);
        if(mounted){
          Overlay.of(context).insert(overlayEntry!);
        }
        break;
    }
    return completer.future;
  }
  //
  // Routine that launches all animations, resulting from a combo
  //
  Future<dynamic> _playAllAnimations() async {
    final completer = Completer();
    /// Determine all animations (and sequence of animations) that
    /// need to be played as a consequence of a combo
    final animationResolver =
    AnimationsResolver(gameBloc: _gameBloc, level: widget.level);
    animationResolver.resolve();

    /// Determine the list of cells that are involved in the animation(s)
    /// and make them invisible
    if (animationResolver.involvedCells.isEmpty) {
      /// At first glance, there is no animations... so directly return
      completer.complete(null);
    }

    // Obtain the animation sequences
    final sequences =
    animationResolver.getAnimationsSequences();
    int pendingSequences = sequences.length;

    /// Make all involved cells invisible
    for (final rowCol in animationResolver.involvedCells) {
      _gameBloc.gameController.grid[rowCol.row][rowCol.col].visible = false;
    }

    /// Make a refresh of the board and the end of which we will play the animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// As the board is now refreshed, it is time to start playing
      /// all the animations
      final overlayEntries = <OverlayEntry>[];
      for (final animationSequence in sequences) {

        /// Prepare all the animations at once.
        /// This is important to avoid having multiple rebuild
        /// when we are going to put them all on the Overlay
        overlayEntries.add(
          OverlayEntry(
            opaque: false,
            builder: (BuildContext context) {
              return AnimationChain(
                level: widget.level,
                animationSequence: animationSequence,
                onComplete: () {
                  // Decrement the number of pending animations
                  pendingSequences--;

                  //
                  // When all have finished, we need to "rebuild" the board,
                  // refresh the screen and yied the hand back
                  //
                  if (pendingSequences == 0) {

                    // Remove all OverlayEntries
                    for (final entry in overlayEntries) {
                      entry.remove();
                    }
                    _gameBloc.gameController.refreshGridAfterAnimations(
                        animationResolver.resultingGridInTermsOfTileTypes,
                        animationResolver.involvedCells);

                    // We now need to proceed with a final rebuild and yield the hand
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Finally, yield the hand
                      if(!completer.isCompleted){
                        completer.complete(null);
                      }
                    });
                    setState(() {});
                  }
                },
              );
            },
          ),
        );
      }
      Overlay.of(context).insertAll(overlayEntries);
    });

    setState(() {});
    return completer.future;
  }


  //
  // The game is over
  //
  // We need to show the adequate splash (win/lost)
  //
  void _onGameOver(bool success) async {
    // Prevent from bubbling
    if (_gameOverReceived == true) {
      return;
    }
    _gameOverReceived = true;

    // Since some animations could still be ongoing, let's wait a bit
    // before showing the user that the game is won
    await Future.delayed(const Duration(seconds: 1));

    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameOverSplash(
            success: success,
            level: widget.level,
            onComplete: () {
              _gameSplash!.remove();
              _gameSplash = null;

              // as the game is over, let's leave the game
              Navigator.of(context).pop();
            },
          );
        });

    Overlay.of(context).insert(_gameSplash!);
  }

  //
  // SplashScreen to be displayed when the game starts
  // to show the user the objectives
  //
  void _showGameStartSplash(_) {
    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameSplash(
            level: widget.level,
            onComplete: () {
              _gameSplash?.remove();
              _gameSplash = null;

              // allow gesture detection
              _allowGesture = true;
            },
          );
        });

    Overlay.of(context).insert(_gameSplash!);
  }

  //
  // SplashScreen to indicate that there is no more moves
  // and a reshuffling is going to happen
  //
  Future<void> _showReshufflingSplash() async {
    Completer completer = Completer();

    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameReshufflingSplash(
            onComplete: () {
              _gameSplash?.remove();
              _gameSplash = null;

              // allow gesture detection
              _allowGesture = true;

              // gives the hand back
              completer.complete();
            },
          );
        });

    Overlay.of(context).insert(_gameSplash!);

    return completer.future;
  }
}
