import 'package:album_share/core/utils/extension_methods.dart';
import 'package:album_share/models/asset_group.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/album.dart';
import '../../models/asset.dart';
import '../../models/endpoint.dart';
import '../../models/preferences.dart';
import '../../models/user.dart';

class DatabaseService {
  Isar? _isar;

  Isar get _db {
    if (_isar == null) {
      throw DatabaseException('The database has not been opened.', 'get _db');
    }
    return _isar!;
  }

  Future<T> _readTxn<T>(Future<T> Function() callback, String origin) async {
    try {
      return await _db.txn(callback);
    } on IsarError catch (e) {
      throw DatabaseException(e.message, origin);
    }
  }

  Future<void> _writeTxn<T>(
      Future<T> Function() callback, String origin) async {
    try {
      await _db.writeTxn(callback);
    } on IsarError catch (e) {
      throw DatabaseException(e.message, origin);
    }
  }

  /// Opens the database ready for reading and writing.
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open([
        EndpointSchema,
        UserSchema,
        AlbumSchema,
        AssetSchema,
        PreferencesSchema,
      ], directory: dir.path);
    } catch (e) {
      throw DatabaseException('Failed to open the database.', 'init', '$e');
    }
  }

  /// Removes all data from the offline database.
  ///
  /// Enpoint retained unless [endpoint] set to true.
  Future<void> clear([bool endpoint = false]) async {
    try {
      await _db.writeTxn(() async {
        await _db.users.clear();
        await _db.albums.clear();
        await _db.assets.clear();
        await _db.preferences.clear();
        if (endpoint) {
          await _db.endpoints.clear();
        }
      });
    } on IsarError catch (e) {
      throw DatabaseException(
          'Failed to clear the database', 'clear', e.message);
    }
  }

  /// Gets the server url endpoint if set, otherwise returns null.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<Endpoint?> getEndpoint() {
    return _readTxn(
      () => _db.endpoints.get(Endpoint.id),
      'getEndpoint',
    );
  }

  /// Inserts or updates the server url endpoint.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<void> setEndpoint(Endpoint endpoint) {
    return _writeTxn(
      () => _db.endpoints.put(endpoint),
      'setEndpoint',
    );
  }

  /// Gets the current user if set, otherwise returns null.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<User?> getUser() {
    return _readTxn<User?>(
      () => _db.users.get(User.defaultIsarId),
      'getUser',
    );
  }

  /// Inserts or updates the current user.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<void> setUser(User user) {
    return _writeTxn(() => _db.users.put(user), 'setUser');
  }

  Future<List<Album>> getAlbums() {
    return _readTxn(
      () => _db.albums.where().anyIsarId().findAll(),
      'getAlbums',
    );
  }

  Future<void> setAlbums(List<Album> albums) {
    return _writeTxn(
      () async {
        await _db.albums.clear();
        await _db.albums.putAll(albums);
      },
      'setAlbums',
    );
  }

  /// Retrieves assets for the selected album.
  ///
  /// If album is null, all assets are retrieved.
  Future<List<Asset>> assets([Album? album]) {
    return _readTxn(
      () => album == null
          ? _db.assets.where().anyIsarId().findAll()
          : _db.assets.where().filter().albumIdEqualTo(album.id).findAll(),
      'getAssets',
    );
  }

  /// Retrieves assets for the passed [AssetGroup]
  /// 
  /// Removes any entries that could not be found in the database.
  Future<List<Asset>> assetsFromGroup(AssetGroup group) {
    return _readTxn(() async {
      final assets = await _db.assets.getAll(group.isarIds);
      return assets.listWhereType<Asset>();
    }, 'assetsFromGroup');
  }



  Future<void> setAssets(List<Asset> assets) {
    return _writeTxn(
      () async {
        await _db.assets.clear();
        await _db.assets.putAll(assets);
      },
      'setAssets',
    );
  }

  /// Returns the preferences for the current user,
  /// or null if no preferences have been saved.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<Preferences?> getPreferences() {
    return _readTxn(
      () => _db.preferences.get(Preferences.id),
      'getPreferences',
    );
  }

  /// Stores the preferences for the current user.
  ///
  /// Throws [DatabaseException] if the operation fails.
  Future<void> setPreferences(Preferences preferences) {
    return _writeTxn(
      () => _db.preferences.put(preferences),
      'setPreferences',
    );
  }
}

class DatabaseException implements Exception {
  DatabaseException(
    this.message,
    this.method, [
    this.details,
  ]);

  final String message;
  final String? details;
  final String method;

  String debugMessage() => 'DatabaseService.$method: $message \n$details';
}
