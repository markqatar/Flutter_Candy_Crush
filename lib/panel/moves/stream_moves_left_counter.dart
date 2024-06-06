import 'package:flutter/material.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/game_bloc.dart';

///
/// StreamMovesLeftCounter
///
/// Displays the number of moves left for the game.
/// Listens to the "movesLeftCount" stream.
///
class StreamMovesLeftCounter extends StatelessWidget {
  const StreamMovesLeftCounter({super.key});

  @override
  Widget build(BuildContext context) {
    GameBloc gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.swap_horiz,
          color: Colors.black,
        ),
        const SizedBox(width: 8.0),
        StreamBuilder<int>(
            initialData: gameBloc.gameController.level.maxMoves,
            stream: gameBloc.movesLeftCount,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Text(
                '${snapshot.data}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              );
            }),
      ],
    );
  }
}
