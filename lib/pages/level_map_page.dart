import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import '../bloc/game_bloc.dart';
import 'game_page.dart';
import '../l10n/app_localizations.dart';

/// Vista mappa livelli con plugin game_levels_scrolling_map
class LevelMapPage extends StatelessWidget {
  final GameBloc gameBloc;
  final int unlockedLevels;

  const LevelMapPage(
      {Key? key, required this.gameBloc, required this.unlockedLevels})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final int totalLevels = gameBloc.numberOfLevels;
    final double width = MediaQuery.of(context).size.width;
    final double mapWidth = width;
    final double xLeft = mapWidth * 0.25;
    final double xRight = mapWidth * 0.75;
    final double xCenter = mapWidth * 0.5;
    final double yStart = 120.0;
    final double yStep = 120.0;

    List<PointModel> points = [];
    for (int i = 0; i < totalLevels; i++) {
      final levelNumber = i + 1;
      bool unlocked = levelNumber <= unlockedLevels;
      bool isCurrent = levelNumber == unlockedLevels;
      // Zig-zag: alterna sinistra/destra, ogni 5 livelli metti centrale
      double x;
      if ((i % 10) == 4 || (i % 10) == 9) {
        x = xCenter;
      } else if ((i % 2) == 0) {
        x = xLeft;
      } else {
        x = xRight;
      }
      double y = yStart + i * yStep;
      points.add(
        PointModel(
          60.0, // width
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: unlocked ? Colors.orange : Colors.grey.shade400,
              shape: BoxShape.circle,
              border:
                  isCurrent ? Border.all(color: Colors.blue, width: 4) : null,
              boxShadow: [
                if (isCurrent)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: unlocked
                  ? GestureDetector(
                      onTap: () async {
                        final selectedLevel =
                            await gameBloc.setLevel(levelNumber);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GamePage(level: selectedLevel),
                          ),
                        );
                      },
                      child: Text('$levelNumber',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    )
                  : Icon(Icons.lock, color: Colors.black38),
            ),
          ),
          isCurrent: isCurrent,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('level_map'))),
      body: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/images/background/map_vertical.png", // o la tua mappa
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: 20,
        pointsPositionDeltaY: 20,
        svgUrl: 'assets/images/background/map_vertical.svg',
        // svgUrl: 'assets/svg/map_vertical.svg', // opzionale
        points: points,
      ),
    );
  }
}
