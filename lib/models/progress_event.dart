class ProgressEvent {
  const ProgressEvent(this.count, this.total);

  /// Bytes loaded.
  final int count;

  /// Expected total bytes;
  final int? total;

  /// A value between 0 and 1 to describe the current progress.
  ///
  /// If the total number of bytes is not known, this will be null.
  double? get value => total == null ? null : count / total!;
}
