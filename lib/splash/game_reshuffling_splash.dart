import 'package:flutter/material.dart';

import '../compoents/double_curved_container.dart';

class GameReshufflingSplash extends StatefulWidget {
  const GameReshufflingSplash({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  GameReshufflingSplashState createState() => GameReshufflingSplashState();
}

class GameReshufflingSplashState extends State<GameReshufflingSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationAppear;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (widget.onComplete != null) {
            widget.onComplete?.call();
          }
        }
      });

    _animationAppear = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.1,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Play the intro
    // Audio.playAsset(AudioType.game_start);

    // Launch the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    Color darkColor = Colors.blue[700]!;
    Color lightColor = Colors.blue;
    String message = "Reshuffling";

    return AnimatedBuilder(
      animation: _animationAppear,
      child: Material(
        color: Colors.transparent,
        child: DoubleCurvedContainer(
          width: screenSize.width,
          height: 150.0,
          outerColor: darkColor,
          innerColor: lightColor,
          child: Container(
            color: lightColor,
            child: Center(
              child: Text(message,
                  style: const TextStyle(
                    fontSize: 50.0,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          left: 0.0,
          top: 150.0 + 100.0 * _animationAppear.value,
          child: child!,
        );
      },
    );
  }
}
