import 'package:album_share/core/utils/app_localisations.dart';
import 'package:isar/isar.dart';
import 'package:humanizer/humanizer.dart' show ApproximateTimeExtensions;

import '../core/utils/db_utils.dart';
import 'asset.dart';
import 'json_map.dart';
import 'user_detail.dart';

part 'activity.g.dart';

@Collection(accessor: 'activity')
class Activity {
  Id get isarId => fastHash(id);

  final String id;
  final String? assetId;
  final String albumId;
  final DateTime createdAt;
  final String? comment;
  @enumerated
  final ActivityType type;
  final UserDetail user;

  const Activity({
    required this.id,
    required this.assetId,
    required this.albumId,
    required this.createdAt,
    required this.comment,
    required this.type,
    required this.user,
  });

  factory Activity.fromJson(String albumId, JsonMap json) {
    return Activity(
      id: json['id'],
      assetId: json['assetId'],
      albumId: albumId,
      createdAt: DateTime.parse(json['createdAt']),
      comment: json['comment'],
      type: ActivityType.fromString(json['type']),
      user: UserDetail.fromJson(json['user']),
    );
  }

  String describe(AppLocalizations locale, Asset? asset) {
    final userName = user.name;

    if (asset == null) {
      return locale.commentedAsset(userName);
    }

    switch (type) {
      case ActivityType.comment:
        return switch (asset.type) {
          AssetType.image => locale.commentedPhoto(userName),
          AssetType.video => locale.commentedVideo(userName),
          AssetType _ => locale.commentedAsset(userName),
        };
      case ActivityType.like:
        return switch (asset.type) {
          AssetType.image => locale.likedPhoto(userName),
          AssetType.video => locale.likedVideo(userName),
          AssetType _ => locale.likedAsset(userName),
        };
    }
  }

  String approximateTimeAgo() =>
      createdAt.difference(DateTime.now()).toApproximateTime();

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Activity && other.id == id;
  }
}

enum ActivityType {
  like,
  comment,
  ;

  factory ActivityType.fromString(String value) {
    return ActivityType.values.firstWhere((e) => e.name == value);
  }
}
