import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../core/utils/app_localisations.dart';
import '../../core/utils/extension_methods.dart';
import '../../models/activity.dart';
import '../../models/album.dart';
import '../../models/asset.dart';
import '../api/api_service.dart';
import '../database/database_service.dart';
import '../notifications/notifications_service.dart';

class ForegroundService extends StateNotifier<SyncState> {
  ForegroundService(
    this._syncFrequency,
    this._api,
    this._db,
    this._notifications,
  ) : super(_getInitialState(_db));

  final int _syncFrequency;
  final ApiService _api;
  final DatabaseService _db;
  final NotificationsService _notifications;

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
    final albums = await _syncAlbums();
    state = state.assetSyncComplete();
    await _syncActivity(albums);
    state = state.activitySyncComplete();
    state = state.syncComplete();
  }

  Future<List<Album>> _syncAlbums() async {
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
      return [];
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

    return onlineAlbums;
  }

  Future<void> _syncActivity(List<Album> albums) async {
    final List<Activity> activity = [];

    for (final album in albums) {
      await _getAlbumActivity(album, activity);
    }

    late List<Activity> newActivity;

    if (state.firstRun) {
      newActivity = activity.listWhere((activ) {
        final now = DateTime.now();
        return now.difference(activ.createdAt).inDays < 1;
      });
    } else {
      final offlineActivity = await _db.getActivity();
      newActivity = activity.listWhere((activ) {
        return !offlineActivity.contains(activ);
      });
    }

    if (newActivity.isNotEmpty) {
      _logger.info('Sending activity notification');
      _notifyActivity(newActivity);
    }

    await _db.setActivity(activity);
  }

  Future<void> _getAlbumActivity(Album album, List<Activity> activity) async {
    _logger.info('Fetching activity for album ${album.id}');
    late final bool activityFetchFailed;

    final onlineActivity = await _api.getActivity(album).then((activity) {
      activityFetchFailed = false;
      return activity;
    }).onError((e, s) {
      _logger.warning('Activity fetch failed', e, s);
      activityFetchFailed = true;
      return const [];
    });

    if (activityFetchFailed) {
      activity.addAll(await _db.getActivity(album: album));
      return;
    }
    activity.addAll(onlineActivity);
  }

  void _notifyActivity(List<Activity> activity) async {
    if (activity.isEmpty) {
      return;
    }
    final locale = AppLocale.instance.current;
    if (activity.length == 1) {
      final activ = activity[0];
      Asset? asset;
      if (activ.assetId != null) {
        asset = await _db.asset(id: activ.assetId!);
      }
      if (asset != null) {
        _notifications.notify(
          title: activ.describe(locale, asset),
          content: activ.comment ?? '❤️',
          assets: [asset],
        );
      }
      return;
    }

    final hasLikes = activity.any((e) => e.type == ActivityType.like);
    final hasComments = activity.any((e) => e.type == ActivityType.comment);

    if (hasLikes && hasComments) {
      _notifications.notify(
        content: locale.notificationCount(activity.length),
      );
      return;
    }
    // Likes only
    if (hasLikes) {
      _notifications.notify(
        content: locale.likesCount(activity.length),
      );
      return;
    }
    // Comments only
    _notifications.notify(
      content: locale.commentsCount(activity.length),
    );
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
