import 'package:flutter/material.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import 'game_page.dart';
import '../model/level.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
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
          child: IconButton(
            icon: const Icon(Icons.add),
            iconSize: 60,
            onPressed: () async {
              Level newLevel = await gameBloc.setLevel(3);
              if (!mounted) return;
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => GamePage(
                    level: newLevel,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
