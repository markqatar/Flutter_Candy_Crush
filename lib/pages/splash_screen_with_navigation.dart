import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// SplashScreen che mostra l'animazione Lottie e poi naviga alla schermata di login
class SplashScreenWithNavigation extends StatefulWidget {
  const SplashScreenWithNavigation({super.key});

  @override
  State<SplashScreenWithNavigation> createState() =>
      _SplashScreenWithNavigationState();
}

class _SplashScreenWithNavigationState
    extends State<SplashScreenWithNavigation> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color.fromARGB(
                  220, 255, 255, 255), // bianco più luminoso al centro
              Color(0xFF42A5F5), // azzurro vivace (lucido) ai lati
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: Lottie.asset(
            'assets/animations/splash.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
