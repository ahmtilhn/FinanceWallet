// l10n/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Her dilin çevirilerini burada tanımlayın
  String get title {
    return Intl.message('Welcome', name: 'title', desc: 'Title for the App');
  }

  String get greeting {
    return Intl.message('Hello', name: 'greeting', desc: 'Greeting text');
  }

  // Bu delegate fonksiyonu, yerelleştirme ayarlarını yapacaktır
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Burada dil dosyanızı yükleyin
    return AppLocalizations();
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
