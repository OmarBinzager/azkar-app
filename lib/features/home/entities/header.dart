import 'package:isar_community/isar.dart';
part 'header.g.dart';

@Collection()
class Header {
  final Id id;
  late String name;

  Header(this.id, this.name);
}