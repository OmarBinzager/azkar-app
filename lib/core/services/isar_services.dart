import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'isar_helper.dart';

class IsarServices {
  late Future<Isar> db;

  IsarServices() {
    db = openIsar();
    initDatabase();
  }

  Future<Isar> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    Isar isar = Isar.open(
      inspector: true,
      schemas: [ContentSchema, HeaderSchema],
      directory: dir.path,
    );

    return isar;
  }

  /// call only first run
  Future initDatabase() async {
    List<Header> headers = await loadAllHeaders();
    if (headers.isEmpty) {
      await addAllHeaders();
      await addAllContents();
    }
  }

  Future addAllHeaders() async {
    final isar = await db;
    await isar.writeAsync((isar) => isar.headers.putAll(IsarHelper.headers));
  }

  Future<List<Header>> loadAllHeaders() async {
    final isar = await db;
    return isar.headers.where().findAll();
  }

  Future<List<Content>> loadAllContents() async {
    final isar = await db;
    return isar.contents.where().findAll();
  }

  Future<List<Content>> loadHeaderContents(int headerId) async {
    final isar = await db;
    return isar.contents.where().headerIdEqualTo(headerId).findAll();
  }

  Future<Header> loadHeaderById(int headerId) async {
    final isar = await db;
    return isar.headers.where().idEqualTo(headerId).findFirst() ?? Header(0, 'unknown');
  }

  Future<List<Content>> loadFavoriteContents() async {
    final isar = await db;
    return isar.contents.where().isLikedEqualTo(true).findAll();
  }

  Future changeFavoriteStats(int contentId, bool stats) async {
    final isar = await db;
    Content? content = isar.contents.where().idEqualTo(contentId).findFirst();
    content!.isLiked = stats;
    await isar.writeAsync((isar) => isar.contents.put(content));
  }

  Future addAllContents() async {
    final isar = await db;
    await isar.writeAsync((isar) => isar.contents.putAll(IsarHelper.contents));
  }

  // // for test only
  // Future addFastAccess(Header header) async {
  //   final isar = await db;
  //   FastAccess fastAccess = FastAccess(
  //     isar.fastAccess.autoIncrement(),
  //     header.name,
  //     header.id,
  //   );
  //   await isar.writeAsync((isar) => isar.fastAccess.put(fastAccess));
  // }

  // Future deleteFastAccess(int id) async {
  //   final isar = await db;
  //   await isar.writeAsync((isar) => isar.fastAccess.delete(id));
  // }

  // Future<List<FastAccess>> loadFastAccess() async {
  //   final isar = await db;
  //   return isar.fastAccess.where().findAll();
  // }

  /// Clear all data and reinitialize the database
  Future<void> updateAzkarData() async {
    final isar = await db;

    // Clear all data
    await isar.writeAsync((isar) {
      isar.headers.clear();
      isar.contents.clear();
    });

    // Reinitialize with fresh data
    await addAllHeaders();
    await addAllContents();
  }
}
