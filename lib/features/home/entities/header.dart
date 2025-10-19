import 'package:isar/isar.dart';
part 'header.g.dart';

@Collection()
class Header {
  final int id;
  late String name;

  Header(this.id, this.name);
}