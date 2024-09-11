import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../core/utils/extension_methods.dart';
import '../../models/album.dart';
import '../../models/asset.dart';
import '../api/api_service.dart';
import '../database/database_service.dart';

class ForegroundService extends StateNotifier<SyncState> {
  ForegroundService(
    this._syncFrequency,
    this._api,
    this._db,
  ) : super(_getInitialState(_db));

  final int _syncFrequency;
  final ApiService _api;
  final DatabaseService _db;

  final _logger = Logger('ForegroundService');

  Timer? _timer;

  static SyncState _getInitialState(DatabaseService db) {
    final haveAssets = db.haveAssetsSync();
    return SyncState(!haveAssets);
  }

  void start() async {
    _logger.info('Starting');
    await update();
    _timer = Timer.periodic(
      _syncFrequency.seconds,
      (_) {
        _logger.info('Checking for updates');
        unawaited(update());
      },
    );
  }

  Future<void> update() async {
    state = state.started();
    await _syncAlbums();
    state = state.assetSyncComplete();
    await _syncActivity();
    state = state.activitySyncComplete();
    state = state.syncComplete();
  }

  Future<void> _syncAlbums() async {
    late bool albumFetchFailed;

    final onlineAlbums = await _api.getSharedAlbums().then((albums) {
      albumFetchFailed = false;
      return albums;
    }).onError((_, __) {
      albumFetchFailed = true;
      return [];
    });

    // Client offline, use local only
    if (albumFetchFailed) {
      _logger.warning('Album fetch failed');
      return;
    }

    final offlineAlbums = await _db.getAlbums();

    // Downloaded new assets.
    bool assetsUpdated = false;

    final List<Asset> assets = [];
    for (Album album in onlineAlbums) {
      final offlineIndex = offlineAlbums.indexOf(album);

      // If album is not in offline db
      // Or album in offline db is out of date.
      bool albumUpdated = false;
      if (offlineIndex == -1) {
        _logger.info('Album ${album.id} not found in offline db.');
        albumUpdated = true;
      } else if (offlineAlbums[offlineIndex].lastUpdatedMillis !=
          album.lastUpdatedMillis) {
        _logger.info('Album ${album.id} has been updated.');
        albumUpdated = true;
      } else {
        _logger.info('No changes to album ${album.id}');
      }

      if (albumUpdated) {
        try {
          _logger.info('Fetching new assets.');
          assets.merge(await _api.getAlbumAssets(album.id));
          assetsUpdated = true;
        } on ApiException {
          _logger.warning('Failed to update assets for album.');
          assets.merge(await _db.assets(album));
        }
      } else {
        assets.merge(await _db.assets(album));
      }
    }

    if (kDebugMode) {
      _logger.info('Checking for duplicates');
      for (int i = 0; i < assets.length; i++) {
        final asset = assets.elementAt(i);
        final duplicates = assets.where((a) => a.id == asset.id);
        final duplicateCount = duplicates.length - 1;
        if (duplicateCount > 0) {
          throw '$duplicateCount Duplicate(s) found for asset: $asset';
        }
      }
    }

    if (assetsUpdated || !onlineAlbums.equals(offlineAlbums)) {
      _logger.info('Assets updated: $assetsUpdated');
      _logger.info('Saving to offline db.');
      await _db.setAlbums(onlineAlbums);
      await _db.setAssets(assets.sorted());
    }
  }

  Future<void> _syncActivity() async {
    //TODO
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SyncState {
  /// True if the offline database doesn't contain any assets
  /// and there has not yet been a sync since the app has been opened.
  final bool firstRun;

  /// If false, service is waiting until next sync period.
  /// If assets is true, at least one sync has already been completed;
  final bool syncing;

  /// True if assets have been synced at least once since the app has
  /// been opened.
  final bool assets;

  /// True if activity has been synced at least once since the app has
  /// been opened;
  final bool activity;

  const SyncState._({
    required this.firstRun,
    required this.syncing,
    required this.assets,
    required this.activity,
  });

  const SyncState(this.firstRun)
      : syncing = false,
        assets = false,
        activity = false;

  SyncState assetSyncComplete() {
    return SyncState._(
      firstRun: firstRun,
      syncing: syncing,
      assets: true,
      activity: activity,
    );
  }

  SyncState activitySyncComplete() {
    return SyncState._(
      firstRun: firstRun,
      syncing: syncing,
      assets: assets,
      activity: true,
    );
  }

  SyncState syncComplete() {
    return SyncState._(
      firstRun: false,
      syncing: false,
      assets: assets,
      activity: activity,
    );
  }

  SyncState started() {
    return SyncState._(
      firstRun: firstRun,
      syncing: true,
      assets: false,
      activity: false,
    );
  }
}
