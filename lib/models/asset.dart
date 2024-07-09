import 'package:isar/isar.dart';

import '../core/utils/db_utils.dart';
import 'json_map.dart';

part 'asset.g.dart';

@collection
class Asset {
  const Asset({
    required this.id,
    required this.albumId,
    required this.type,
    required this.createdAt,
    required this.fileName,
    this.width,
    this.height,
    this.duration = Duration.zero,
    this.stackCount = 0,
    this.thumbHash,
  });

  Id get isarId => fastHash(id);

  final String id;
  final String albumId;
  @enumerated
  final AssetType type;
  final DateTime createdAt;
  final String fileName;

  //TODO:
  final int? width;
  final int? height;
  final Duration duration;
  final int? stackCount;
  final String? thumbHash;

  factory Asset.fromJson(String albumId, JsonMap json) {
    return Asset(
      id: json['id'],
      albumId: albumId,
      type: AssetType.fromString(json['type']),
      createdAt: DateTime.parse(json['fileCreatedAt']),
      fileName: json['originalFileName'],
    );
  }

  @ignore
  bool get isImage => type == AssetType.image;

  @ignore
  int get stackChildrenCount => stackCount ?? 0;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Asset && other.id == id && other.type == type;
  }
}

enum AssetType {
  image,
  video,
  audio,
  other;

  factory AssetType.fromString(String value) {
    return AssetType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
    );
  }
}
