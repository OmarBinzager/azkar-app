class AudioItem {
  final String id;
  final String title;
  final String voiceFile;
  final int? headerId;
  final String? category;
  final Duration? duration;

  const AudioItem({
    required this.id,
    required this.title,
    required this.voiceFile,
    this.headerId,
    this.category,
    this.duration,
  });

  AudioItem copyWith({
    String? id,
    String? title,
    String? voiceFile,
    int? headerId,
    String? category,
    Duration? duration,
  }) {
    return AudioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      voiceFile: voiceFile ?? this.voiceFile,
      headerId: headerId ?? this.headerId,
      category: category ?? this.category,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          voiceFile == other.voiceFile;

  @override
  int get hashCode => id.hashCode ^ voiceFile.hashCode;
}
