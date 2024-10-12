import 'package:album_share/services/notifications/background_notifications/background_notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers/sidebar_listener.dart';

class TestNotificationButton extends ConsumerWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.notification_add),
      onPressed: () async {
        final noti = BackgroundNotificationsService.forPlatform();
        await noti.activity(
            title: 'New activity', content: 'Kevin liked 3 of your photos');
        await noti.assets(
            title: 'New content', content: 'Kevin added 3 new photos');
      },
      iconSize: 18,
      style: IconButton.styleFrom(
        minimumSize: const Size(25, 25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
    );
  }
}
