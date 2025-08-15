import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';

class AppLanguage {
  static const supportedLocales = [
    Locale('en'), // English
    Locale('it'), // Italiano
    Locale('ru'), // Русский
    Locale('fr'), // Français
    Locale('es'), // Español
    Locale('de'), // Deutsch
    Locale('pt'), // Português
    Locale('ar'), // العربية
  ];
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => AppLanguage.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

// In main.dart dovrai:
// MaterialApp(
//   localizationsDelegates: [
//     AppLocalizationDelegate(),
//     GlobalMaterialLocalizations.delegate,
//     GlobalWidgetsLocalizations.delegate,
//     GlobalCupertinoLocalizations.delegate,
//   ],
//   supportedLocales: AppLanguage.supportedLocales,
//   ...
// )
