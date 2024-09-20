import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logo_widget.dart';
import 'app_window.dart';

class DesktopWindowTitlebar extends StatelessWidget {
  const DesktopWindowTitlebar({
    this.showTitle = true,
    this.leading,
    this.header,
    this.titleBarIcons = const [],
    super.key,
  });

  final Widget? leading;

  final String? header;

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
    final theme = Theme.of(context);
    final platform = theme.platform;
    assert(desktopPlatforms.contains(platform));

    if (platform == TargetPlatform.macOS) {
      return _CupertinoWindowTitlebar(
        showTitle: showTitle,
        titleBarIcons: titleBarIcons,
        leading: leading,
        header: header,
      );
    }

    return ColoredBox(
      color: (theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface)
          .withOpacity(0.6),
      child: WindowTitleBarBox(
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
                          if (header != null) Text(header!),
                        ],
                      )
                    : null,
              ),
            ),
            ...titleBarIcons,
            MinimizeWindowButton(),
            MaximizeWindowButton(),
            CloseWindowButton(),
          ],
        ),
      ),
    );
  }
}

class _CupertinoWindowTitlebar extends StatelessWidget {
  const _CupertinoWindowTitlebar({
    required this.showTitle,
    required this.titleBarIcons,
    required this.leading,
    required this.header,
  });

  final bool showTitle;
  final List<Widget> titleBarIcons;
  final Widget? leading;
  final String? header;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CupertinoTheme.of(context).barBackgroundColor,
      child: WindowTitleBarBox(
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
                    if (header != null)
                      Expanded(
                        child: Center(
                          child: Text(header!),
                        ),
                      ),
                    Row(
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
