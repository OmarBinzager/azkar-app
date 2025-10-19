import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteProvider = Provider<List<Content>>((ref) {
  return ref
      .watch(contentsListProvider)
      .where((element) => element.isLiked)
      .toList();
});

final favoriteHeaderProvider = Provider<List<Header>>((ref) {
  final favorites = ref.watch(favoriteProvider);
  List<int> favInecies = [];
  for (var favContent in favorites) {
    favInecies.add(favContent.headerId);
  }
  return ref
      .watch(headersProvider)
      .where((element) => favInecies.contains(element.id))
      .toList();
});
