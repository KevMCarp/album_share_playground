import 'package:flutter/material.dart';

import '../../../screens/auth/auth_listener.dart';
import '../../utils/platform_utils.dart';
import 'desktop_scaffold.dart';
import 'mobile_scaffold.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.showTitleBar,
    this.titleBarIcons = const [],
    this.header,
    this.showBackButton = false,
    required this.body,
    super.key,
  });

  /// Display the title, logo and menu icon.
  final bool showTitleBar;

  /// title bar icons will only be shown if showTitleBar is set to true.
  final List<Widget> titleBarIcons;

  /// A replacement for the app title.
  final String? header;

  /// If [showTitleBar] and [showBackButton] are true, the back button
  /// will be shown on the title bar.
  final bool showBackButton;

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return forPlatform(
      desktop: () {
        return DesktopScaffold(
          showTitleBar: showTitleBar,
          titleBarIcons: titleBarIcons,
          showBackButton: showBackButton,
          body: AuthListener(child: body),
          header: header,
        );
      },
      mobile: () {
        return MobileScaffold(
          showTitleBar: showTitleBar,
          titleBarIcons: titleBarIcons,
          showBackButton: showBackButton,
          body: AuthListener(child: body),
          header: header,
        );
      },
    );
  }

  static double appBarHeight(BuildContext context) {
    return forPlatform(
      desktop: () => DesktopScaffold.appBarHeight(),
      mobile: () => MobileScaffold.appBarHeight(context),
    );
  }
}
