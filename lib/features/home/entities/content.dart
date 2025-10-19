import 'package:isar/isar.dart';
part 'content.g.dart';

@Collection()
class Content {
  final int id;
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
