import 'package:isar_community/isar.dart';

part 'content.g.dart';

@Collection()
class Content {
  final Id id;
  late String text;
  bool isLiked = false;

  final int headerId;
  bool hasVoice = false;
  String? voiceFile;

  Content(
    this.id,
    this.text,
    this.isLiked,
    this.headerId, {
    this.hasVoice = false,
    this.voiceFile,
  });
}
