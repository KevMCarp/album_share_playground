import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

import 'core/main/app_lifecycle_scope.dart';
import 'core/main/locale_scope.dart';
import 'core/main/main_app.dart';
import 'core/utils/platform_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayer.ensureInitialized();
  forDesktop(windowManager.ensureInitialized);

  runApp(
    const ProviderScope(
      child: LocaleScope(
        child: AppLifecycleScope(
          child: MainApp(),
        ),
      ),
    ),
  );
}
