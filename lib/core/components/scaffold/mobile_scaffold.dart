import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers/app_bar_listener.dart';
import '../logo_widget.dart';
import '../navigation_bar/material_navigation_bar.dart';
import '../titlebar_buttons/titlebar_back_button.dart';

class MobileScaffold extends ConsumerWidget {
  const MobileScaffold({
    required this.showTitleBar,
    this.titleBarIcons = const [],
    this.header,
    this.showBackButton = false,
    required this.body,
    this.bottomNavigationBar,
    super.key,
  });

  /// Display the title, logo and menu icon.
  final bool showTitleBar;

  /// title bar icons will only be shown if showTitleBar is set to true.
  final List<Widget> titleBarIcons;

  final String? header;

  /// If [showTitleBar] and [showBackButton] are true, the back button
  /// will be shown on the title bar.
  final bool showBackButton;

  final Widget body;

  final Widget? bottomNavigationBar;

  static double appBarHeight(BuildContext context) =>
      kToolbarHeight + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarVisible = ref.watch(appBarListenerProvider);
    final appBarHeight = MobileScaffold.appBarHeight(context);

    final theme = Theme.of(context);

    final appBarColor =
        (theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface)
            .withOpacity(0.7);

    return Scaffold(
      body: Stack(
        children: [
          body,
          if (showTitleBar)
            AnimatedPositioned(
              duration: kThemeAnimationDuration,
              left: 0,
              right: 0,
              top: appBarVisible ? 0 : -appBarHeight,
              child: Container(
                height: appBarHeight,
                color: appBarColor,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: showBackButton ? const TitlebarBackButton() : null,
                  automaticallyImplyLeading: false,
                  actions: titleBarIcons,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 25, child: LogoImage()),
                      const SizedBox(width: 5),
                      const LogoText(tagLine: false),
                      if (header != null)
                        Text(
                          ' - $header',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (bottomNavigationBar != null)
            AnimatedPositioned(
              duration: kThemeAnimationDuration,
              left: 0,
              right: 0,
              bottom: appBarVisible ? 0 : -kBottomNavBarHeight,
              child: bottomNavigationBar!,
            ),
        ],
      ),
    );
  }
}
