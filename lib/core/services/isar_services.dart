import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:path_provider/path_provider.dart';
import 'isar_helper.dart';

class IsarServices {
  static final IsarServices _instance = IsarServices._internal();
  factory IsarServices() => _instance;

  Future<Isar>? _dbFuture;
  Future<void>? _initFuture;

  IsarServices._internal();

  Future<Isar> get db => openIsar();

  Future<Isar> openIsar() async {
    if (Isar.getInstance() != null) {
      return Isar.getInstance()!;
    }
    _dbFuture ??= _openIsarInternal();
    return _dbFuture!;
  }

  Future<Isar> _openIsarInternal() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.getInstance() != null) {
      return Isar.getInstance()!;
    }
    return await Isar.open(
      [ContentSchema, HeaderSchema],
      inspector: kDebugMode,
      directory: dir.path,
    );
  }

  /// Initialize database or update data if seed data changed
  Future<void> initDatabase() async {
    if (_initFuture != null) return _initFuture!;
    _initFuture = _initDatabaseInternal();
    return _initFuture!;
  }

  Future<void> _initDatabaseInternal() async {
    final isar = await db;
    final headerCount = await isar.headers.count();
    final contentCount = await isar.contents.count();
    if (headerCount == 0 ||
        headerCount != IsarHelper.headers.length ||
        contentCount == 0 ||
        contentCount != IsarHelper.contents.length) {
      debugPrint(
        'Content & Headers out of date or empty. Syncing database with IsarHelper...',
      );
      await updateAzkarData();
    }
  }

  Future addAllHeaders() async {
    final isar = await db;
    await isar.writeTxn(() => isar.headers.putAll(IsarHelper.headers));
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
    return isar.contents.filter().idEqualTo(headerId).findAll();
  }

  Future<Header> loadHeaderById(int headerId) async {
    final isar = await db;
    return isar.headers.getSync(headerId) ?? Header(0, 'unknown');
  }

  Future<List<Content>> loadFavoriteContents() async {
    final isar = await db;
    return isar.contents.filter().isLikedEqualTo(true).findAll();
  }

  Future changeFavoriteStats(int contentId, bool stats) async {
    final isar = await db;
    await isar.writeTxn(() async {
      Content? content =
          await isar.contents.where().idEqualTo(contentId).findFirst();
      if (content != null) {
        content.isLiked = stats;
        await isar.contents.put(content);
      }
    });
  }

  Future addAllContents() async {
    final isar = await db;
    await isar.writeTxn(() => isar.contents.putAll(IsarHelper.contents));
  }

  /// Clear all data and reinitialize the database while preserving user favorites
  Future<void> updateAzkarData() async {
    final isar = await db;

    // 1. Preserve existing favorite contents before clearing
    List<Content> favoriteContents =
        await isar.contents.filter().isLikedEqualTo(true).findAll();

    final Set<int> favoriteIds = favoriteContents.map((e) => e.id).toSet();
    final Set<String> favoriteHeaderAndText = favoriteContents
        .map((e) => '${e.headerId}___${e.text.trim()}')
        .toSet();
    final Set<String> favoriteTexts =
        favoriteContents.map((e) => e.text.trim()).toSet();

    // 2. Prepare fresh contents with preserved isLiked status
    List<Content> freshContents = IsarHelper.contents.map((seedContent) {
      bool isLiked = favoriteIds.contains(seedContent.id) ||
          favoriteHeaderAndText.contains(
              '${seedContent.headerId}___${seedContent.text.trim()}') ||
          favoriteTexts.contains(seedContent.text.trim());

      return Content(
        seedContent.id,
        seedContent.text,
        isLiked,
        seedContent.headerId,
        hasVoice: seedContent.hasVoice,
        voiceFile: seedContent.voiceFile,
      );
    }).toList();

    // 3. Clear and reinitialize tables in a single async transaction
    await isar.writeTxn(() async {
      await isar.headers.clear();
      await isar.contents.clear();
      await isar.headers.putAll(IsarHelper.headers);
      await isar.contents.putAll(freshContents);
    });
    debugPrint('Database sync with IsarHelper completed.');
  }
}
