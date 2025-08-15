import 'package:candycrush/panel/objective/components/stream_objective_item.dart';
import 'package:flutter/material.dart';

import '../../../bloc/bloc_provider.dart';
import '../../../bloc/game_bloc.dart';
import '../../../model/level.dart';
import '../model/objective.dart';

class ObjectivePanel extends StatelessWidget {
  const ObjectivePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    final Level level = gameBloc.gameController.level;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final EdgeInsets paddingTop = EdgeInsets.only(
        top: (orientation == Orientation.portrait ? 10.0 : 0.0));
    //
    // Build the objectives
    //
    List<Widget> objectiveWidgets = level.objectives.map((Objective obj) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: StreamObjectiveItem(objective: obj),
      );
    }).toList();

    return Padding(
      padding: paddingTop,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              width: 5.0, color: Colors.black.withValues(alpha: 0.5)),
        ),
        height: 80.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: objectiveWidgets,
        ),
      ),
    );
  }
}
