import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/asset.dart';
import 'database_service.dart';

abstract class DatabaseProviders {
  static final service = Provider((ref) => DatabaseService.instance);

  static final asset =
      FutureProvider.autoDispose.family<Asset?, String>((ref, String id) {
    return ref.watch(service).asset(id: id);
  });
}
