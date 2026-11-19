import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MushafImageService {
  static final Map<int, Future<File?>> _inFlight = {};

  static Future<File?> getPageImage(int pageIndex) {
    if (pageIndex < 1 || pageIndex > 604) return Future.value(null);
    return _inFlight.putIfAbsent(pageIndex, () async {
      try {
        final baseDir = await getApplicationDocumentsDirectory();
        final dir = Directory('${baseDir.path}/mushaf_pages');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/page_$pageIndex.png');
        if (await file.exists() && await file.length() > 1000) {
          return file;
        }

        final pageStr = pageIndex.toString().padLeft(3, '0');
        final url =
            'https://files.quran.app/hafs/madani/width_1024/page$pageStr.png';
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode != 200) {
          client.close();
          return null;
        }
        final sink = file.openWrite();
        await response.pipe(sink);
        client.close();
        return file;
      } catch (_) {
        return null;
      } finally {
        _inFlight.remove(pageIndex);
      }
    });
  }

  static void prefetchAdjacent(int pageIndex) {
    if (pageIndex + 1 <= 604) getPageImage(pageIndex + 1);
    if (pageIndex - 1 >= 1) getPageImage(pageIndex - 1);
  }
}
