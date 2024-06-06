import 'package:flutter/material.dart';

import 'model/animation_sequence.dart';
import '../model/level.dart';
import 'model/tile_animation.dart';

var _curve = Curves.fastLinearToSlowEaseIn;
class AnimationChain extends StatefulWidget {
  const AnimationChain({
    super.key,
    this.animationSequence,
    required this.level,
    this.onComplete,
  });

  final AnimationSequence? animationSequence;
  final VoidCallback? onComplete;
  final Level level;

  @override
  State<AnimationChain> createState() => _AnimationChainState();
}

class _AnimationChainState extends State<AnimationChain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // List of all individual animations (one per delay)
  final List<Animation<double>> _animations = <Animation<double>>[];

  // Normal duration of one fall
  final int _normalDurationInMs = 50;

  // Duration of one delay
  final int _delayInMs = 3;

  // Total duration, taking into consideration the number of different delays
  int totalDurationInMs = 0;



  @override
  void initState() {
    super.initState();
    /// We need to compute the total duration
    totalDurationInMs = (widget.animationSequence!.endDelay + 1) * _delayInMs +
        _normalDurationInMs;
    _controller = AnimationController(
        duration: Duration(milliseconds: totalDurationInMs), vsync: this)
      ..addListener(() {
        setState(() {});})
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onComplete != null) {
            widget.onComplete?.call();
          }
        }
      });

    /// Let's build the list of all animations in the sequence
    for (final tileAnimation in widget.animationSequence!.animations) {
      int start = tileAnimation.delay * (_delayInMs);
      int end = start + _normalDurationInMs;
      final double ratioStart = start / totalDurationInMs;
      final double ratioEnd = end / totalDurationInMs;

      _animations.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            ratioStart,
            ratioEnd,
            curve: _curve,
          ),
        ),
      ));
    }
    _controller.forward(from: 0.0);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TileAnimation firstAnimation = widget.animationSequence!.animations[0];
    int totalAnimations = widget.animationSequence!.animations.length;
    int index = totalAnimations - 1;
    Widget theWidget = firstAnimation.tile.widget;
    /// In order to build the Widgets tree, we need to start from the last one up to the first
    while (index >= 0) {
      theWidget = _buildSubAnimationFactory(
          index, widget.animationSequence!.animations[index], theWidget);
      index--;
    }

    return Stack(
      children: [
        Positioned(
          left: firstAnimation.tile.x,
          top: firstAnimation.tile.y,
          child: theWidget,
        ),
      ],
    );
  }

  Widget _buildSubAnimationFactory(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    Widget widget;
    switch (tileAnimation.animationType) {
      case TileAnimationType.newTile:
        _curve = Curves.fastOutSlowIn;
        widget =
            _buildSubAnimationAppearance(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.moveDown:
        _curve = Curves.fastOutSlowIn;
        widget = _buildSubAnimationMoveDown(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.avalanche:
        _curve = Curves.fastLinearToSlowEaseIn;
        widget = _buildSubAnimationSlide(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.collapse:
        _curve = Curves.easeInOutCubic;
        widget = _buildSubAnimationCollapse(index, tileAnimation, childWidget);
        break;
      case TileAnimationType.chain:
        _curve = Curves.easeInOutCubic;
        widget = _buildSubAnimationChain(index, tileAnimation, childWidget);
        break;
    }
    return widget;
  }

  //
  // The appearance consists in an initial translated (-Y) position,
  // followed by a move down
  //
  Widget _buildSubAnimationAppearance(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    return Transform.translate(
      offset: Offset(
          0.0,
          -widget.level.tileHeight +
              widget.level.tileHeight * _animations[index].value),
      child: _buildSubAnimationMoveDown(index, tileAnimation, childWidget),
    );
  }

  //
  // A move down animation consists in moving the tile down to its final position
  //
  Widget _buildSubAnimationMoveDown(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    final double distance = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;
    return Transform.translate(
      offset: Offset(0.0, -_animations[index].value * distance),
      child: childWidget,
    );
  }

  //
  // A slide consists in moving the tile horizontally
  //
  Widget _buildSubAnimationSlide(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    final double distanceX = (tileAnimation.to.col - tileAnimation.from.col) *
        widget.level.tileWidth;
    final double distanceY = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;
    return Transform.translate(
      offset: Offset(_animations[index].value * distanceX,
          -_animations[index].value * distanceY),
      child: childWidget,
    );
  }

  //
  // A chain consists in making tiles disappear
  //
  Widget _buildSubAnimationChain(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    return Transform.scale(
      scale: (1.0 - _animations[index].value),
      child: childWidget,
    );
  }

  //
  // A collapse consists in moving the tile to the destination tile position
  //
  Widget _buildSubAnimationCollapse(
      int index, TileAnimation tileAnimation, Widget childWidget) {
    final double distanceX = (tileAnimation.to.col - tileAnimation.from.col) *
        widget.level.tileWidth;
    final double distanceY = (tileAnimation.to.row - tileAnimation.from.row) *
        widget.level.tileHeight;
    return Transform.translate(
      offset: Offset(_animations[index].value * distanceX,
          -_animations[index].value * distanceY),
      child: childWidget,
    );
  }
}
