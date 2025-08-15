import 'package:candycrush/l10n/app_localizations.dart';
import 'package:candycrush/pages/home_page.dart';
import 'package:candycrush/pages/splash_screen_with_navigation.dart';
import 'package:candycrush/pages/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/bloc_provider.dart';
import 'bloc/game_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      bloc: GameBloc(),
      child: MaterialApp(
        title: 'Crush Candy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('it'),
          Locale('ru'),
          Locale('fr'),
          Locale('es'),
          Locale('de'),
          Locale('pt'),
          Locale('ar'),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreenWithNavigation(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
