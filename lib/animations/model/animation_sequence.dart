
import 'package:candycrush/model/tile.dart';
import 'package:candycrush/animations/model/tile_animation.dart';

class AnimationSequence {
  // Range of time for this sequence of animations
  int startDelay;
  int endDelay;

  // Type of tile in the sequence of animations,根据糖果类型决定动画类型
  TileType tileType;

  // List of all animations, part of the sequence
  List<TileAnimation> animations;

  // Constructor
  AnimationSequence({
    required this.tileType,
    required this.startDelay,
    required this.endDelay,
    required this.animations,
  });
}
