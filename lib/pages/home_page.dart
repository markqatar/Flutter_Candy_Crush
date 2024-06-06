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
      body: Center(
        child: IconButton(icon: const Icon(Icons.add),iconSize: 60, onPressed: () async {
          Level newLevel = await gameBloc.setLevel(3);
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (_) => GamePage(level: newLevel,)));
        },),
      ),
    );
  }
}
