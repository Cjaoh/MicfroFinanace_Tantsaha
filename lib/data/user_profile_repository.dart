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
    );
  }

  /// Crée le profil s'il n'existe pas, sinon met à jour les données existantes.
  /// La date de création est conservée lors des mises à jour.
  Future<void> enregistrer(UserProfile profil) async {
    final db = await appDatabase.database;
    final valeurs = <String, Object?>{
      'prenom': profil.prenom,
      'nom': profil.nom,
      'telephone': profil.telephone,
      'langue': profil.langue.name,
      'commune': profil.commune,
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
}

