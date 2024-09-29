import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../immich/extensions/build_context_extensions.dart';
import '../../../models/activity.dart';
import '../../../models/album.dart';
import '../../../models/asset.dart';
import '../../../services/activity/activity_providers.dart';
import '../../utils/extension_methods.dart';
import '../user_avatar.dart';
import 'app_sidebar.dart';

class ActivitySidebar extends AppSidebar {
  const ActivitySidebar({
    required this.asset,
    required this.album,
    super.key,
  }) : super(reverse: true);

  final Album album;
  final Asset asset;

  @override
  AutoDisposeStreamProvider providerBuilder() {
    return ActivityProviders.assetInAlbum((album: album, asset: asset));
  }

  @override
  Widget? bottomItemBuilder(BuildContext context) =>
      _SendMessageWidget(albumId: album.id, assetId: asset.id);

  @override
  Widget itemBuilder(BuildContext context, Activity activity) {
    final theme = Theme.of(context);
    const size = 34.0;
    return ListTile(
      leading: SizedBox(
        width: size,
        height: size,
        child: UserAvatar(
          user: activity.user,
          radius: size / 2,
          size: size,
        ),
      ),
      title: Text(activity.user.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.comment != null)
            Text(
              activity.comment!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            const Icon(
              Icons.favorite,
              size: 18,
              color: Colors.red,
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              activity.approximateTimeAgo(),
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
      titleTextStyle: theme.textTheme.labelMedium,
      subtitleTextStyle: theme.textTheme.bodySmall,
    );
  }
}

class _SendMessageWidget extends ConsumerStatefulWidget {
  const _SendMessageWidget({
    required this.albumId,
    required this.assetId,
    super.key,
  });

  final String albumId;
  final String assetId;

  @override
  ConsumerState<_SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends ConsumerState<_SendMessageWidget> {
  final TextEditingController _controller = TextEditingController();

  Timer? _timer;

  void _updateButtonVisibility() {
    if (_timer == null) {
      setState(() {});
    } else {
      _timer?.cancel();
    }

    _timer = Timer(
      500.milliseconds,
      () => setState(() => _timer = null),
    );
  }

  void _saveMessage() async {
    await ref
        .read(ActivityProviders.uploadService)
        .uploadComment(widget.albumId, widget.assetId, _controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.isDarkTheme ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
              onChanged: (_) => _updateButtonVisibility(),
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Message', //TODO locale
                constraints: const BoxConstraints(minHeight: 40),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                contentPadding: const EdgeInsets.fromLTRB(5, 4, 4, 2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: _controller.text.isEmpty ? null : _saveMessage,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
