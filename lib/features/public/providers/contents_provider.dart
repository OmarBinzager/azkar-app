import 'package:new_azkar_app/core/services/isar_services.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentsList extends Notifier<List<Content>> {
  @override
  List<Content> build() {
    _load();
    return [];
  }

  Future _load() async {
    state = await IsarServices().loadAllContents();
  }

  Future refresh() async {
    state = [];
    await _load();
  }

  Future changeStats(int contentId, stats) async {
    await IsarServices().changeFavoriteStats(contentId, stats);
    await refresh();
  }

  List<Content> getFavorites() {
    return state.where((element) => element.isLiked).toList();
  }

  List<Content> getHeaderContents(int headerId) {
    return state.where((element) => element.headerId == headerId).toList();
  }
}

final contentsListProvider = NotifierProvider<ContentsList, List<Content>>(
  ContentsList.new,
);
