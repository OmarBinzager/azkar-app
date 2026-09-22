import 'package:new_azkar_app/core/services/isar_services.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> initStorage() async {
  await IsarServices().initDatabase();
}

final storageInitProvider = FutureProvider((ref) async {
  await initStorage();
  ref.read(headersProvider);
  ref.read(contentsListProvider);
});

final storageProvider = Provider((ref) {
  final client = ref.watch(storageInitProvider).asData?.value;
  return client;
});