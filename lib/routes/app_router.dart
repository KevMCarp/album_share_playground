import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/album.dart';
import '../screens/album/album_screen.dart';
import '../screens/asset_viewer/asset_viewer_screen.dart';
import '../screens/asset_viewer/asset_viewer_screen_state.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/preferences/preferences_screen.dart';
import '../services/auth/auth_service.dart';

const _kLibraryRoute = '/';
const _kLoginRoute = '/login';
const _kPreferencesRoute = 'preferences';
const _kAssetViewerRoute = 'assets';
const _kAlbumRote = 'album';

class AppRouter {
  AppRouter(this._auth);

  final AuthService _auth;

  final key = GlobalKey();
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<String?> _authRedirect(bool authRequired) async {
    final authenticated = await _auth.checkAuthStatus();

    if (authenticated && !authRequired) {
      return _kLibraryRoute;
    }

    if (!authenticated && authRequired) {
      return _kLoginRoute;
    }

    return null;
  }

  GoRouter routerConfig({List<NavigatorObserver>? observers}) => GoRouter(
        routes: routes,
        navigatorKey: navigatorKey,
        restorationScopeId: 'router_config_scope',
        observers: observers,
      );

  List<GoRoute> get routes => [
        GoRoute(
          path: _kLibraryRoute,
          builder: (_, __) => const LibraryScreen(),
          redirect: (_, __) => _authRedirect(true),
          routes: [
            GoRoute(
              path: _kPreferencesRoute,
              builder: (_, __) => const PreferencesScreen(),
            ),
            GoRoute(
              path: _kAssetViewerRoute,
              builder: (_, state) => AssetViewerScreen(
                viewerState:
                    AssetViewerScreenState.fromExtra(state.extra ?? {}),
              ),
            ),
          ],
        ),
        GoRoute(
          path: _kLoginRoute,
          builder: (_, __) => const AuthScreen(),
          redirect: (_, __) => _authRedirect(false),
        ),
      ];

  static void to(String route, BuildContext context) =>
      GoRouter.of(context).go(route.startsWith('/') ? route : '/$route');

  static void back(BuildContext context) {
    try {
      GoRouter.of(context).pop();
    } on GoError {
      // GoRouter throws on macOS when calling pop.
    }
  }

  static void toLibrary(BuildContext context) => to(_kLibraryRoute, context);
  static void toPreferences(BuildContext context) =>
      to(_kPreferencesRoute, context);
  static void toLogin(BuildContext context) => to(_kLoginRoute, context);
  static void toAlbum(BuildContext context, Album album) =>
      to(_kAlbumRote, context, album);
  static void toAssetViewer(
    BuildContext context,
    AssetViewerScreenState viewerState,
  ) =>
      GoRouter.of(context).go(
        '/$_kAssetViewerRoute',
        extra: viewerState.toExtra(),
      );
}
