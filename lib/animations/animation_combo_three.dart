import 'package:flutter/material.dart';

import '../model/combo.dart';
import '../model/tile.dart';

class AnimationComboThree extends StatefulWidget {
  const AnimationComboThree({
    super.key,
    required this.combo,
    required this.onComplete,
  });

  final Combo combo;
  final VoidCallback onComplete;

  @override
  State<AnimationComboThree> createState() => _AnimationComboThreeState();
}

class _AnimationComboThreeState extends State<AnimationComboThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation animationIn;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });
    animationIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.combo.tiles.map((Tile tile) {
        return Positioned(
          left: tile.x,
          top: tile.y,
          child: Transform.scale(
            scale: 1.0 - _controller.value,
            child: tile.widget,
          ),
        );
      }).toList(),
    );
  }
}
