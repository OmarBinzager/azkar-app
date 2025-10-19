import 'package:new_azkar_app/core/services/isar_services.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future initStorage()async{
  List<Header> headers = await IsarServices().loadAllHeaders();
  if (headers.isEmpty) {
    await IsarServices().addAllHeaders();
    await IsarServices().addAllContents();
  }
}

final storageInitProvider = FutureProvider((ref)async{
  ref.read(headersProvider);
  ref.read(contentsListProvider);
  return await initStorage();
});

final storageProvider = Provider((ref){
  final client = ref.watch(storageInitProvider).asData?.value;
  return client;
});