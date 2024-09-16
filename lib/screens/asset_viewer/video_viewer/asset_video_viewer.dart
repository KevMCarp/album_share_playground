import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/asset.dart';
import '../../../services/video/cache/video_cache.dart';
import '../../../services/video/cache/video_cache_manager.dart';
import 'video_viewer.dart';

class AssetVideoViewer extends ConsumerStatefulWidget {
  const AssetVideoViewer({
    required this.asset,
    required this.placeholder,
    required this.loopVideo,
    super.key,
  });

  final Asset asset;
  final Widget placeholder;
  final bool loopVideo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AssetVideoViewerState();
}

class _AssetVideoViewerState extends ConsumerState<AssetVideoViewer> {
  _ViewerState _viewerState = _ViewerState.downloading;

  // Download progress
  double? _progress;

  // Either a file path or error message
  String? _payload;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _startDownload());
  }

  void _setIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void _startDownload() async {
    final cache = VideoCacheManager.instance;

    try {
      final result = await VideoCache.loadVideoFromCache(
        widget.asset,
        cache: cache,
        onProgress: (progress) {
          _setIfMounted(() {
            _progress = progress.value;
          });
        },
      );
      _setIfMounted(() {
        _viewerState = _ViewerState.ready;
        _payload = result;
      });
    } on VideoLoadingException catch (e) {
      _setIfMounted(() {
        _viewerState = _ViewerState.error;
        _payload = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_viewerState) {
      _ViewerState.downloading => SizedBox.fromSize(
          size: MediaQuery.sizeOf(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.placeholder,
              Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: _progress,
                  ),
                ),
              ),
            ],
          ),
        ),
      _ViewerState.error => Center(
          child: Text(_payload!),
        ),
      _ViewerState.ready => SizedBox.fromSize(
          size: MediaQuery.sizeOf(context),
          child: VideoViewer(
            path: _payload!,
            loopVideo: widget.loopVideo,
          ),
        ),
    };
  }
}

enum _ViewerState {
  downloading,
  ready,
  error,
}
