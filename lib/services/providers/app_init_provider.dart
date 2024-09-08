import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../api/api_provider.dart';
import '../database/database_providers.dart';
import '../logger/app_logger.dart';

final appInitProvider = FutureProvider((ref) async {
  // Ensure cookies are retrieved from storage.
  await ref.watch(ApiProviders.cookies.future);

  final database = ref.watch(DatabaseProviders.service);
  await database.init();

  // Init the logger service.
  AppLogger.instance;

  final logger = Logger('UncaughtErrorLogger');

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.severe(
      'FlutterError',
      '"${details.toString()}\n'
          'Exception: ${details.exception}\n'
          'Library: ${details.library}\n'
          'Context: ${details.context}"',
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.severe('PlatformDispatcher', error, stack);
    return true;
  };

  final apiService = ref.watch(ApiProviders.service);
  apiService.checkEndpoint();
});
