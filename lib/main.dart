import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/router.dart';
import 'core/services/storage_provider.dart';
import 'core/providers/version_provider.dart';
import 'core/widgets/global_top_audio_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storageClient = await ProviderContainer().read(
      storageInitProvider.future,
    );

    // Check for app updates and update data if necessary
    final container = ProviderContainer(
      overrides: [storageProvider.overrideWith((ref) => storageClient)],
    );

    try {
      await container
          .read(dataUpdateProvider.notifier)
          .checkAndUpdateIfRequired();
    } catch (e) {
      // Ignore errors during startup update check
    }
  } catch (e) {
    debugPrint('Error during app storage initialization: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
            fontFamily: 'ElMessiri',
          ),
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          builder: (context, routerChild) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: mediaQuery.textScaler.clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1.15,
                ),
              ),
              child: _Unfocus(
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => routerChild ?? const SizedBox.shrink(),
                    ),
                    OverlayEntry(
                      builder: (context) => const GlobalTopAudioPlayer(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Unfocus extends StatelessWidget {
  const _Unfocus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
