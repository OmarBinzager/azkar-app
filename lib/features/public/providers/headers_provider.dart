import 'package:new_azkar_app/core/services/isar_services.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadersList extends Notifier<List<Header>> {
  @override
  List<Header> build() {
    _load();
    return [];
  }

  Future _load() async {
    state = await IsarServices().loadAllHeaders();
  }

  Future<Header> getHeaderById(int headerId) async {
    return await IsarServices().loadHeaderById(headerId);
  }
}

final headersProvider = NotifierProvider<HeadersList, List<Header>>(
  HeadersList.new,
);
