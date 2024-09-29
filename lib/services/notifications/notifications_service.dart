import '../../models/asset.dart';

abstract class NotificationsService {
  Future<void> notify({
    String? title,
    required String content,
    List<Asset> assets = const [],
  });
}
