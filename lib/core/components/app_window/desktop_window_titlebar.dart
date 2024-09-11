import 'package:album_share/services/logger/app_logger.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../logo_widget.dart';
import 'app_window.dart';

class DesktopWindowTitlebar extends StatelessWidget {
  const DesktopWindowTitlebar({
    this.showTitle = true,
    this.leading,
    this.titleBarIcons = const [],
    super.key,
  });

  final Widget? leading;

  final List<Widget> titleBarIcons;

  static void setTitle(String title) {
    appWindow.title = title;
  }

  static void openWindow(String title) {
    doWhenWindowReady(() {
      appWindow.title = title;
      appWindow.minSize = const Size(300, 500);
      appWindow.size = const Size(600, 500);
      appWindow.show();
    });
  }

  /// If true, displays the app logo and name in the top bar.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    assert(desktopPlatforms.contains(platform));

    if (platform == TargetPlatform.macOS) {
      return _CupertinoWindowTitlebar(
        showTitle: showTitle,
        titleBarIcons: titleBarIcons,
        leading: leading,
      );
    }

    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(
              child: showTitle
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: SizedBox(
                            height: 16,
                            child: LogoImage(),
                          ),
                        ),
                        const SizedBox(width: 1),
                        if (leading != null) leading!,
                      ],
                    )
                  : null,
            ),
          ),
          ...titleBarIcons,
          MinimizeWindowButton(),
          MaximizeWindowButton(),
          CloseWindowButton(
            onPressed: () async {
              AppLogger.instance.flush();
              appWindow.close();
            },
          ),
        ],
      ),
    );
  }
}

class _CupertinoWindowTitlebar extends StatelessWidget {
  const _CupertinoWindowTitlebar({
    required this.showTitle,
    required this.titleBarIcons,
    required this.leading,
  });

  final bool showTitle;
  final List<Widget> titleBarIcons;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          const SizedBox(width: 65),
          if (leading != null) leading!,
          Expanded(
            child: MoveWindow(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...titleBarIcons,
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: 16,
                      child: LogoImage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
