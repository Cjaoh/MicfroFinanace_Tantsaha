import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Le malagasy ('mg') n'est pas fourni par Flutter pour ses widgets
/// internes (boutons "OK"/"Annuler" des dialogues, sélecteur de date,
/// info-bulles...). Sans ces délégués, une app en 'mg' plante avec
/// "No MaterialLocalizations found".
///
/// Solution : pour la langue 'mg', ces petits textes système retombent sur
/// le français. Tous NOS textes, eux, restent en malagasy (fichiers .arb).
/// Si un jour tu veux aussi traduire ces textes système, c'est ici qu'on
/// branchera une vraie traduction.
const Locale _fallback = Locale('fr');

class _MgMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MgMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_fallback);

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class _MgWidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _MgWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(_fallback);

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) =>
      false;
}

class _MgCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MgCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_fallback);

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}

/// À placer dans MaterialApp.localizationsDelegates.
const List<LocalizationsDelegate<dynamic>> mgFallbackDelegates = [
  _MgMaterialDelegate(),
  _MgWidgetsDelegate(),
  _MgCupertinoDelegate(),
];