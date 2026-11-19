import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Experimental service for downloading and dynamically loading QCF2 Mushaf
/// page fonts on demand instead of bundling all 604+ font files in assets.
class QcfFontService {
  static final Set<String> _loadedFamilies = {};
  static final Map<String, Future<bool>> _inFlight = {};

  static String familyNameForPage(int pageIndex) =>
      'QCF_P${pageIndex.toString().padLeft(3, '0')}';

  static Future<bool> ensurePageFontLoaded(int pageIndex) {
    final pageStr = pageIndex.toString().padLeft(3, '0');
    final family = 'QCF_P$pageStr';
    if (_loadedFamilies.contains(family)) {
      return Future.value(true);
    }
    return _inFlight.putIfAbsent(family, () async {
      try {
        final baseDir = await getApplicationDocumentsDirectory();
        final fontsDir = Directory('${baseDir.path}/qcf_fonts');
        if (!await fontsDir.exists()) {
          await fontsDir.create(recursive: true);
        }
        final file = File('${fontsDir.path}/QCF2$pageStr.ttf');

        if (!await file.exists() || await file.length() < 1000) {
          final url =
              'https://cdn.jsdelivr.net/gh/nuqayah/qpc-fonts@master/mushaf-v2/QCF2$pageStr.ttf';
          final client = HttpClient();
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close();
          if (response.statusCode != 200) {
            client.close();
            return false;
          }
          final sink = file.openWrite();
          await response.pipe(sink);
          client.close();
        }

        final bytes = await file.readAsBytes();
        final loader = FontLoader(family);
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
        await loader.load();
        _loadedFamilies.add(family);
        return true;
      } catch (_) {
        return false;
      } finally {
        _inFlight.remove(family);
      }
    });
  }
}
