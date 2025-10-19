import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/features/public/models/header_of_header_model.dart';
import 'package:new_azkar_app/features/quran/views/quran_page.dart';
import 'package:new_azkar_app/features/quran/views/quran_sura_page.dart';
import 'package:new_azkar_app/features/search/presentation/views/search_view.dart';
import 'package:new_azkar_app/features/compass/presentation/views/compass_view.dart';
import 'package:new_azkar_app/features/everyday_etiquette/presentation/views/everyday_etiquette_view.dart';
import 'package:new_azkar_app/features/favorite/presentation/views/favorite_view.dart';
import 'package:new_azkar_app/features/friday_night/presentation/views/friday_night_view.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/home/presentation/views/home_view.dart';
import 'package:new_azkar_app/features/necklace/views/necklace_view.dart';
import 'package:new_azkar_app/features/prayer_times/presentation/views/prayer_times_view.dart';
import 'package:new_azkar_app/features/prayers/presentation/views/prayers_view.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:new_azkar_app/features/public/presentation/views/content_details_view.dart';
import 'package:new_azkar_app/features/public/presentation/views/contents_view.dart';
import 'package:new_azkar_app/features/public/presentation/views/headers_viewer.dart';
import 'package:new_azkar_app/features/public/presentation/views/headers_of_headers_viewer.dart';
import 'package:new_azkar_app/features/settings/presentation/views/downloads_view.dart';
import 'package:new_azkar_app/features/splash/views/splash_view.dart';
import 'package:new_azkar_app/features/the_supplications/presentation/views/the_supplications_view.dart';
import 'package:new_azkar_app/features/tips_and_etiquette/presentation/views/tips_and_etiquette_view.dart';
import 'package:new_azkar_app/features/settings/presentation/views/settings_view.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: Routes.splash,
      path: '/',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      name: Routes.home,
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: Routes.favorite,
      path: '/favorite',
      builder: (context, state) => const FavoriteView(),
    ),
    GoRoute(
      name: Routes.search,
      path: '/search',
      builder: (context, state) => const SearchView(),
    ),
    GoRoute(
      name: Routes.quran,
      path: '/quran',
      builder: (context, state) => QuranPage(),
    ),
    GoRoute(
      name: Routes.contents,
      path: '/contents',
      builder: (context, state) => ContentsView(header: state.extra as Header),
    ),
    GoRoute(
      name: Routes.contentDetails,
      path: '/contentDetails',
      builder:
          (context, state) =>
              ContentDetailsView(content: state.extra as Content),
    ),
    GoRoute(
      name: Routes.headersViewer,
      path: '/headersViewer',
      builder:
          (context, state) =>
              HeadersViewer(headerModel: state.extra as HeaderModel),
    ),
    GoRoute(
      name: Routes.headersOfHeadersViewer,
      path: '/headersOfHeadersViewer',
      builder:
          (context, state) => HeadersOfHeadersViewer(
            headerList: state.extra as HeaderOfHeaderModel,
          ),
    ),
    GoRoute(
      name: Routes.prayers,
      path: '/prayers',
      builder: (context, state) => const PrayersView(),
    ),
    GoRoute(
      name: Routes.everydayEtiquette,
      path: '/everydayEtiquette',
      builder: (context, state) => const EverydayEtiquetteView(),
    ),
    GoRoute(
      name: Routes.theSupplications,
      path: '/theSupplications',
      builder: (context, state) => const TheSupplicationsView(),
    ),
    GoRoute(
      name: Routes.fridayNight,
      path: '/fridayNight',
      builder: (context, state) => const FridayNightView(),
    ),
    GoRoute(
      name: Routes.tipsAndEtiquette,
      path: '/tipsAndEtiquette',
      builder: (context, state) => const TipsAndEtiquetteView(),
    ),
    GoRoute(
      name: Routes.necklace,
      path: '/necklace',
      builder: (context, state) => const NecklaceView(),
    ),
    GoRoute(
      name: Routes.prayerTimes,
      path: '/prayerTimes',
      builder: (context, state) => const PrayerTimesView(),
    ),
    GoRoute(
      name: Routes.compass,
      path: '/compass',
      builder: (context, state) => const CompassView(),
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
  ],
);
