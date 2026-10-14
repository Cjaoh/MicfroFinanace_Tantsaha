import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

const int longueurPin = 4;

enum ErreurPin { longueur, chiffresSeulement, trivial }

/// Retourne l'erreur du PIN, ou null s'il est valide.
ErreurPin? validerPin(String pin) {
  if (pin.length != longueurPin) return ErreurPin.longueur;
  if (!RegExp(r'^[0-9]+$').hasMatch(pin)) return ErreurPin.chiffresSeulement;
  if (_estTrivial(pin)) return ErreurPin.trivial;
  return null;
}

bool _estTrivial(String pin) {
  final chiffres = pin.codeUnits.map((c) => c - 48).toList();
  final toutesIdentiques = chiffres.every((c) => c == chiffres.first);
  return toutesIdentiques ||
      _suitePas(chiffres, 1) ||
      _suitePas(chiffres, -1);
}

bool _suitePas(List<int> chiffres, int pas) {
  for (var i = 1; i < chiffres.length; i++) {
    if (chiffres[i] - chiffres[i - 1] != pas) return false;
  }
  return true;
}

/// Sel aléatoire cryptographiquement sûr, à stocker avec le hash.
String genererSel() {
  final aleatoire = Random.secure();
  final octets = List<int>.generate(16, (_) => aleatoire.nextInt(256));
  return base64Url.encode(octets);
}

/// Hash SHA-256 du sel suivi du PIN. Le PIN n'est jamais stocké en clair.
String hasherPin(String pin, String sel) {
  return sha256.convert(utf8.encode('$sel:$pin')).toString();
}

/// Compare le PIN saisi au hash enregistré, sans fuite de temps.
bool verifierPin(
  String pinSaisi, {
  required String sel,
  required String hashAttendu,
}) {
  final calcule = hasherPin(pinSaisi, sel);
  if (calcule.length != hashAttendu.length) return false;

  var difference = 0;
  for (var i = 0; i < calcule.length; i++) {
    difference |= calcule.codeUnitAt(i) ^ hashAttendu.codeUnitAt(i);
  }
  return difference == 0;
}