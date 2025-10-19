// import 'package:new_azkar_app/core/services/isar_services.dart';
// import 'package:new_azkar_app/features/home/entities/fast_access.dart';
// import 'package:new_azkar_app/features/home/entities/header.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FastAccessList extends Notifier<List<FastAccess>> {
//   IsarServices isarService = IsarServices();

//   @override
//   List<FastAccess> build() {
//     _load();
//     return [];
//   }

//   Future _load() async {
//     state = await isarService.loadFastAccess();
//   }

//   Future refresh()async{
//     state = [];
//     state = await isarService.loadFastAccess();
//   }
  
//   Future addFastAccess(Header header)async{
//    await IsarServices().addFastAccess(header);
//    refresh();
//   }

//   Future deleteFastAccess(int id)async{
//     await IsarServices().deleteFastAccess(id);
//     refresh();
//   }
// }

// final fastAccessListProvider =
//     NotifierProvider<FastAccessList, List<FastAccess>>(FastAccessList.new);
