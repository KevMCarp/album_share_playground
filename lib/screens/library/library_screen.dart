import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/scaffold/app_navigation_scaffold.dart';
import '../../core/components/scaffold/app_scaffold.dart';
import '../../core/components/titlebar_buttons/preferences_button.dart';
import '../../core/components/titlebar_buttons/refresh_button.dart';
import '../../core/utils/app_localisations.dart';
import '../../core/utils/platform_utils.dart';
import '../../immich/asset_grid/immich_asset_grid_view.dart';
import '../../services/foreground/foreground_service_provider.dart';
import '../../services/library/library_providers.dart';
import '../../services/preferences/preferences_providers.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      showBackButton: false,
      titleBarIcons: const [MaybeRefreshButton(), PreferencesButton()],
      screens: [
        NavigationBarItem(
          builder: (_) => const _AllAssetsScreen(),
          icon: Icon(isCupertino
              ? CupertinoIcons.photo
              : Icons.photo_library_outlined),
          selectedIcon: Icon(isCupertino //
              ? CupertinoIcons.photo_fill
              : Icons.photo_library),
          label: 'Timeline',
        ),
        NavigationBarItem(
          builder: (_) => const _AlbumsScreen(),
          icon:
              Icon(isCupertino ? CupertinoIcons.folder : Icons.folder_outlined),
          selectedIcon: Icon(isCupertino //
              ? CupertinoIcons.folder_fill
              : Icons.folder),
          label: 'Albums',
        ),
      ],
    );
  }
}

class _AllAssetsScreen extends StatelessWidget {
  const _AllAssetsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) {
    return ref.read(foregroundServiceProvider.notifier).update();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Consumer(builder: (context, ref, child) {
          final syncService = ref.watch(foregroundServiceProvider);

          if (syncService.firstRun && !syncService.assets) {
          return const BuildingLibraryWidget();
          }

          final libraryProvider = ref.watch(LibraryProviders.assets);

          return libraryProvider.when(
            data: (assets) {
              final maxExtent = ref.watch(PreferencesProviders.maxExtent);
            final dynamicLayout = ref.watch(PreferencesProviders.dynamicLayout);
              final renderList = ref.watch(LibraryProviders.renderList(assets));

              return renderList.when(
                data: (renderList) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ScrollConfiguration(
                      // Remove default scroll bar
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ImmichAssetGridView(
                        alwaysVisibleScrollThumb: forPlatform(
                          desktop: () => true,
                          mobile: () => false,
                        ),
                        dynamicLayout: dynamicLayout,
                        showStack: true,
                        renderList: renderList,
                        assetMaxExtent: maxExtent,
                        onRefresh: platformValue(
                          desktop: null,
                          mobile: () => _refresh(ref),
                        ),
                      onTap: (state) {
                        AppRouter.toAssetViewer(context, state);
                      },
                      ),
                    ),
                  );
                },
                error: (e, _) => Text('$e'),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
              );
            },
            error: (e, _) {
              return Center(
                child: Text('$e'),
              );
            },
            loading: () {
              return const SizedBox();
            },
          );
        }),
    );
  }
}
class BuildingLibraryWidget extends StatelessWidget {
  const BuildingLibraryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        Text(AppLocalizations.of(context)!.buildingLibrary)
      ],
    );
  }
}
