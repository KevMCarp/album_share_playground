import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager extends CacheManager {
  static const key = 'remoteVideoCacheKey';
  static VideoCacheManager? _instance;

  static VideoCacheManager get instance {
    return _instance ??= VideoCacheManager._();
  }

  VideoCacheManager._()
      : super(
          Config(
            key,
            maxNrOfCacheObjects: 50,
            stalePeriod: const Duration(days: 30),
          ),
        );
}
