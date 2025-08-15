import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'options': 'Options',
      'account': 'Account',
      'volume': 'Sound volume',
      'board_style': 'Board style',
      'logout': 'Logout',
      'delete_account': 'Delete account',
      // ...altre chiavi...
    },
    'it': {
      'options': 'Opzioni',
      'account': 'Account',
      'volume': 'Volume suoni',
      'board_style': 'Stile della board',
      'logout': 'Logout',
      'delete_account': 'Cancella account',
    },
    'ru': {
      'options': 'Опции',
      'account': 'Аккаунт',
      'volume': 'Громкость',
      'board_style': 'Стиль доски',
      'logout': 'Выйти',
      'delete_account': 'Удалить аккаунт',
    },
    'fr': {
      'options': 'Options',
      'account': 'Compte',
      'volume': 'Volume sonore',
      'board_style': 'Style du plateau',
      'logout': 'Déconnexion',
      'delete_account': 'Supprimer le compte',
    },
    'es': {
      'options': 'Opciones',
      'account': 'Cuenta',
      'volume': 'Volumen',
      'board_style': 'Estilo del tablero',
      'logout': 'Cerrar sesión',
      'delete_account': 'Eliminar cuenta',
    },
    'de': {
      'options': 'Optionen',
      'account': 'Konto',
      'volume': 'Lautstärke',
      'board_style': 'Brettstil',
      'logout': 'Abmelden',
      'delete_account': 'Konto löschen',
    },
    'pt': {
      'options': 'Opções',
      'account': 'Conta',
      'volume': 'Volume',
      'board_style': 'Estilo do tabuleiro',
      'logout': 'Sair',
      'delete_account': 'Excluir conta',
    },
    'ar': {
      'options': 'الإعدادات',
      'account': 'الحساب',
      'volume': 'مستوى الصوت',
      'board_style': 'نمط اللوحة',
      'logout': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'it',
        'ru',
        'fr',
        'es',
        'de',
        'pt',
        'ar'
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
