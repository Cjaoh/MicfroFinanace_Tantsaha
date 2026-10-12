import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Langue choisie par l'utilisateur : malgache par défaut, français en option.
/// Le choix est mémorisé sur le téléphone (cahier des charges, AUTH-01).
class LocaleProvider with ChangeNotifier {
  LocaleProvider({required Locale initialLocale}) : _locale = initialLocale;

  static const String _prefKey = 'app_locale';
  static const Locale malagasy = Locale('mg');
  static const Locale francais = Locale('fr');
  static const List<Locale> supported = [malagasy, francais];

  Locale _locale;
  Locale get locale => _locale;

  /// Lit la langue mémorisée. Sans choix enregistré, le malgache est utilisé.
  static Future<LocaleProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    return LocaleProvider(
      initialLocale: code == francais.languageCode ? francais : malagasy,
    );
  }

  /// Change la langue, met à jour l'interface et enregistre le choix.
  Future<void> setLocale(Locale newLocale) async {
    if (!supported.contains(newLocale) || newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLocale.languageCode);
  }
}