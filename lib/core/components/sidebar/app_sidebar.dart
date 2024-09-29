import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/activity.dart';

abstract class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, this.reverse = false});

  static const width = 300.0;

  final bool reverse;

  AutoDisposeStreamProvider providerBuilder();

  Widget itemBuilder(BuildContext context, Activity activity);

  Widget? bottomItemBuilder(BuildContext context) {
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(providerBuilder());
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.5),
      width: AppSidebar.width,
      child: provider.when(
        data: (a) {
          final bottomWidget = bottomItemBuilder(context);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: reverse,
                  itemCount: a.length,
                  itemBuilder: (context, index) {
                    return itemBuilder(context, a[index]);
                  },
                ),
              ),
              if (bottomWidget != null) bottomWidget,
            ],
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
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
      ),
    );
  }
}
