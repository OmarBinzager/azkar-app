import 'package:new_azkar_app/features/search/presentation/views/search_view.dart';
import 'package:new_azkar_app/features/settings/presentation/views/settings_view.dart';
import 'package:go_router/go_router.dart';
import 'package:new_azkar_app/features/settings/presentation/views/downloads_view.dart';

class Routes {
  static const compass = 'compass';
  static const zkatCalculator = 'zkat_calculator';
  static const home = 'home';
  static const quran = 'quran';
  static const quran_page = 'quran';
  static const prayers = 'prayers';
  static const favorite = 'favorite';
  static const contents = 'contents';
  static const contentDetails = 'contentDetails';
  static const headersViewer = 'headersViewer';
  static const headersOfHeadersViewer = 'headersOfHeadersViewer';
  static const everydayEtiquette = 'everydayEtiquette';
  static const theSupplications = 'theSupplications';
  static const fridayNight = 'fridayNight';
  static const tipsAndEtiquette = 'tipsAndEtiquette';
  static const splash = 'splash';
  static const necklace = 'necklace';
  static const prayerTimes = 'prayerTimes';
  static const search = 'search';
  static const settings = 'settings';
  static const downloads = 'downloads';
}

final routes = [
  GoRoute(
    name: Routes.search,
    path: '/search',
    builder: (context, state) => const SearchView(),
  ),
  GoRoute(
    name: Routes.settings,
    path: '/settings',
    builder: (context, state) => const SettingsView(),
  ),
  GoRoute(
    name: Routes.downloads,
    path: '/downloads',
    builder: (context, state) => const DownloadsView(),
  ),
];
