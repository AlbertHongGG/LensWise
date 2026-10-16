class StreamingSnapshot<T> {
  final T data;
  final bool isComplete;
  final String? rawChunk;

  const StreamingSnapshot({
    required this.data,
    this.isComplete = false,
    this.rawChunk,
  });

  @override
  String toString() => 'StreamingSnapshot(data: $data, isComplete: $isComplete)';
}
