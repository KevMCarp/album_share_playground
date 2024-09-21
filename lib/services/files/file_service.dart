import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/asset.dart';

class FileService {
  static final provider = Provider.autoDispose((ref) => FileService());

  Future<Uint8List> fetch(Asset asset, {bool preview = false}) {
    throw UnimplementedError();
  }
}
