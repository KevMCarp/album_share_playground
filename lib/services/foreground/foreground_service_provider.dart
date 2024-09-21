import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_provider.dart';
import '../database/database_providers.dart';
import '../preferences/preferences_providers.dart';
import 'foreground_service.dart';

final foregroundServiceProvider =
    StateNotifierProvider.autoDispose<ForegroundService, SyncState>((ref) {
  final db = ref.watch(DatabaseProviders.service);
  final api = ref.watch(ApiProviders.service);
  final syncFrequency = ref.watch(PreferencesProviders.syncFrequency);

  final service = ForegroundService(syncFrequency, api, db);

  service.start();

  return service;
});
