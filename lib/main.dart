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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(child: const MyApp())
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        fontFamily: 'ElMessiri',
      ),
      //home: const HomeView(),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      builder: (_, child) {
        return _Unfocus(child: child!);
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
