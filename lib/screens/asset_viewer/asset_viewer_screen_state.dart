import '../../immich/asset_grid/asset_grid_data_structure.dart';
import '../../models/album.dart';

class AssetViewerScreenState {
  const AssetViewerScreenState({
    required this.renderList,
    this.initialIndex = 0,
    this.heroOffset = 0,
    this.showStack = false,
    this.album,
  });

  final RenderList renderList;
  final int initialIndex;
  final int heroOffset;
  final bool showStack;
  final Album? album;

  factory AssetViewerScreenState.fromExtra(Object extra) {
    assert(extra is Map<String, dynamic>);
    extra as Map<String, dynamic>;
    return AssetViewerScreenState(
      renderList: extra['renderList'] ?? RenderList([], null, []),
      initialIndex: extra['initialIndex'] ?? 0,
      heroOffset: extra['heroOffset'] ?? 0,
      showStack: extra['showStack'] ?? false,
    );
  }

  Map<String, dynamic> toExtra() => {
        'renderList': renderList,
        'initialIndex': initialIndex,
        'heroOffset': heroOffset,
        'showStack': showStack,
      };

  AssetViewerScreenState withAlbum(Album album) {
    return AssetViewerScreenState(
      renderList: renderList,
      initialIndex: initialIndex,
      heroOffset: heroOffset,
      showStack: showStack,
      album: album,
    );
  }
}
