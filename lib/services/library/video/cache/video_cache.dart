import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../models/asset.dart';
import '../../../../models/progress_event.dart';
import '../../../database/database_service.dart';

class VideoCache {
  VideoCache._();

  /// Returns the file path for the video at the specified url.
  static Future<String> loadVideoFromCache(
    Asset asset, {
    required CacheManager cache,
    required void Function(ProgressEvent progress) onProgress,
  }) async {
    final endpoint = DatabaseService.instance.getEndpointSync();
    final token = DatabaseService.instance.getAuthTokenSync();

    final path = asset.videoUrl(endpoint.serverUrl);

    final headers = {
      'x-immich-user-token': token,
      'Accept': 'application/octet-stream'
    };

    final stream = cache.getFileStream(
      path,
      withProgress: true,
      headers: headers,
    );

    await for (final result in stream) {
      if (result is DownloadProgress) {
        onProgress(ProgressEvent(result.downloaded, result.totalSize));
      } else if (result is FileInfo) {
        return result.file.path;
      }
    }

    throw VideoLoadingException('Could not load video from stream.');
  }
}

class VideoLoadingException implements Exception {
  final String message;

  VideoLoadingException(this.message);
}
