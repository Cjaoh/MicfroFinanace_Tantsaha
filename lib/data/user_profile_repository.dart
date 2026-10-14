import '../models/user_profile.dart';
import 'app_database.dart';

/// Lecture et écriture du profil local (une seule ligne, id = profil-local).
class UserProfileRepository {
  UserProfileRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  static const String profilId = 'profil-local';

  /// Retourne le profil enregistré, ou null si aucun profil n'existe encore.
  Future<UserProfile?> charger() async {
    final db = await appDatabase.database;
    final lignes = await db.query(
      AppDatabase.usersTable,
      where: 'id = ?',
      whereArgs: [profilId],
      limit: 1,
    );
    if (lignes.isEmpty) return null;

    final ligne = lignes.first;
    return UserProfile.restaurer(
      prenom: ligne['prenom'] as String,
      nom: ligne['nom'] as String,
      telephone: ligne['telephone'] as String,
      langue: LangueProfil.values.byName(ligne['langue'] as String),
      commune: ligne['commune'] as String?,
      pinHash: ligne['pin_hash'] as String?,
      pinSel: ligne['pin_sel'] as String?,
    );
  }

  /// Crée le profil s'il n'existe pas, sinon met à jour les données existantes.
  /// La date de création est conservée lors des mises à jour.
  /// Les colonnes PIN ne sont écrites que si le profil possède un PIN, afin
  /// qu'un profil rechargé sans PIN n'efface pas celui déjà enregistré.
  Future<void> enregistrer(UserProfile profil) async {
    final db = await appDatabase.database;
    final valeurs = <String, Object?>{
      'prenom': profil.prenom,
      'nom': profil.nom,
      'telephone': profil.telephone,
      'langue': profil.langue.name,
      'commune': profil.commune,
      if (profil.aUnPin) 'pin_hash': profil.pinHash,
      if (profil.aUnPin) 'pin_sel': profil.pinSel,
    };

    final existants = await db.query(
      AppDatabase.usersTable,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [profilId],
    );

    if (existants.isEmpty) {
      await db.insert(AppDatabase.usersTable, {
        ...valeurs,
        'id': profilId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.update(
        AppDatabase.usersTable,
        valeurs,
        where: 'id = ?',
        whereArgs: [profilId],
      );
    }
  }

  /// Enregistre le hash et le sel du PIN, sans toucher aux autres données.
  /// Lève une [StateError] si aucun profil n'existe encore.
  Future<void> enregistrerPin({
    required String pinHash,
    required String pinSel,
  }) async {
    final db = await appDatabase.database;
    final modifies = await db.update(
      AppDatabase.usersTable,
      {'pin_hash': pinHash, 'pin_sel': pinSel},
      where: 'id = ?',
      whereArgs: [profilId],
    );
    if (modifies == 0) {
      throw StateError('Aucun profil local : impossible d\'enregistrer le PIN.');
    }
  }
}