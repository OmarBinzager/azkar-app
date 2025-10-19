import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsView extends ConsumerStatefulWidget {
  const DownloadsView({super.key});

  @override
  ConsumerState<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends ConsumerState<DownloadsView> {
  final Map<String, double> _progressById = {};
  final Map<String, bool> _downloadingById = {};
  final Map<String, bool> _existsById = {};
  final Map<String, String> _nameById = {};
  final List<_DriveFile> _files = [];
  bool _loadingList = true;

  // Provided Google Drive file IDs
  static const List<String> _providedIds = [
    '1pbFtdfksbGQdHmNooxa9W4A-WrYx56zI',
    '1bI3SFC9MOw_qfbygCuMBMytCAoYNzd-a',
    '1ek2tnjJvmT3DAZMmpCtlcv1gIpsjDtdZ',
    '1ZiEN8-3aJGcZHIxrDb9UE9PDDPgSEcZJ',
    '1EUMC-ZRCeQkl-cXtS8FuwrX-FHmOzrYu',
    '1nFP2Im9h5w1YSGCn6pmbvdtETZ2hnWTl',
    '1UYE3rxVKUx2bUHlTq5L4jGKoCWawHJlQ',
    '1a2fZ1ldb2-gdAK5_oiATI8nbSE8iUWbC',
    '1mXtyEkGckwTRHpE4Il0wOhZxlNoBCB4D',
    '1dUG88heXJ_bNFGUJFVDso1L0eU-m6c07',
    '1w1AOARSdMJhQJV2HS4zSLxD_WVHremHT',
    '11bVqJXT6cjeZUxZA4wD4BlV6FmtOWxVZ',
  ];

  @override
  void initState() {
    super.initState();
    _initList();
  }

  Future<void> _initList() async {
    setState(() => _loadingList = true);
    final List<Content> allContents = ref.read(contentsListProvider);
    final Map<String, String> idToName = {};
    for (final c in allContents) {
      if (c.hasVoice &&
          c.voiceFile != null &&
          _providedIds.contains(c.voiceFile)) {
        final Header header = await ref.read(headersProvider.notifier).getHeaderById(c.headerId);
        idToName[c.voiceFile!] = header.name;
      }
    }
    final List<_DriveFile> built =
        _providedIds
            .map((id) => _DriveFile(id: id, name: idToName[id] ?? 'ملف صوتي'))
            .toList();
    await _precheckExisting(built);
    if (!mounted) return;
    setState(() {
      _files
        ..clear()
        ..addAll(built);
      _loadingList = false;
    });
    // Fetch real filenames in background
    // for (final f in _files) {
    //   _resolveAndApplyFileName(f.id);
    // }
  }

  Future<void> _resolveAndApplyFileName(String id) async {
    try {
      final name = await _fetchFileNameFromHeaders(id);
      if (name != null && name.trim().isNotEmpty) {
        _nameById[id] = name.trim();
        final idx = _files.indexWhere((e) => e.id == id);
        if (idx != -1 && mounted) {
          setState(() {
            _files[idx] = _DriveFile(id: id, name: _nameById[id]!);
          });
        }
      }
    } catch (_) {}
  }

  Future<String?> _fetchFileNameFromHeaders(String id) async {
    final Uri uri = Uri.parse(
      'https://drive.google.com/uc?export=download&id=$id',
    );
    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      // Try HEAD first
      HttpClientRequest req = await httpClient.openUrl('HEAD', uri);
      HttpClientResponse res = await req.close();
      if (res.statusCode == 405 || res.statusCode == 400) {
        // Fallback to GET (will read headers only)
        req = await httpClient.getUrl(uri);
        res = await req.close();
      }
      final cd = res.headers.value('content-disposition');
      if (cd == null) return null;
      final name = _parseFileNameFromContentDisposition(cd);
      return name;
    } finally {
      httpClient?.close(force: true);
    }
  }

  String? _parseFileNameFromContentDisposition(String cd) {
    final rfc5987 = RegExp(r"filename\*=UTF-8''([^;]+)");
    final simple = RegExp(r'filename="?([^";]+)"?');
    final m1 = rfc5987.firstMatch(cd);
    if (m1 != null) {
      return Uri.decodeFull(m1.group(1) ?? '');
    }
    final m2 = simple.firstMatch(cd);
    if (m2 != null) {
      final raw = m2.group(1) ?? '';
      try {
        return utf8.decode(raw.codeUnits);
      } catch (_) {
        return raw;
      }
    }
    return null;
  }

  Future<String> _localPathFor(String idOrName) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$idOrName.mp3';
  }

  Future<void> _precheckExisting(List<_DriveFile> files) async {
    for (final f in files) {
      final path = await _localPathFor(f.id);
      final exists = await File(path).exists();
      _existsById[f.id] = exists;
    }
  }

  Future<void> _download(String id) async {
    if (_downloadingById[id] == true) return;
    setState(() {
      _downloadingById[id] = true;
      _progressById[id] = 0.0;
    });

    final String url = 'https://drive.google.com/uc?export=download&id=$id';
    final String path = await _localPathFor(id);
    final file = File(path);

    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      final req = await httpClient.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200)
        throw HttpException('status ${res.statusCode}');

      // Update filename from headers if available
      final cd = res.headers.value('content-disposition');
      final resolved =
          cd != null ? _parseFileNameFromContentDisposition(cd) : null;
      if (resolved != null && resolved.trim().isNotEmpty) {
        _nameById[id] = resolved.trim();
        final idx = _files.indexWhere((e) => e.id == id);
        if (idx != -1 && mounted) {
          setState(() {
            _files[idx] = _DriveFile(id: id, name: _nameById[id]!);
          });
        }
      }

      final total = res.contentLength > 0 ? res.contentLength : null;
      final sink = file.openWrite();
      int received = 0;
      await for (final chunk in res) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null) {
          setState(() {
            _progressById[id] = received / total;
          });
        }
      }
      await sink.close();

      setState(() {
        _downloadingById[id] = false;
        _progressById[id] = 1.0;
        _existsById[id] = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم تنزيل الملف الصوتي')));
      }
    } catch (e) {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
      setState(() {
        _downloadingById[id] = false;
        _progressById[id] = 0.0;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل تنزيل الملف الصوتي')));
      }
    } finally {
      httpClient?.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'التحميلات',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body:
          _loadingList
              ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondaryColor,
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(LayoutConstants.screenPadding),
                child:
                    _files.isEmpty
                        ? Center(
                          child: Text(
                            'لا توجد ملفات صوتية',
                            style: TextStyles.medium.copyWith(
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _files.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final f = _files[index];
                            final downloading = _downloadingById[f.id] == true;
                            final progress = _progressById[f.id] ?? 0.0;
                            final exists = _existsById[f.id] == true;
                            final displayName = _nameById[f.id] ?? f.name;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.mediumBold.copyWith(
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'ملف صوتي',
                                      style: TextStyles.regular.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (downloading) ...[
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value:
                                            progress > 0 && progress < 1.0
                                                ? progress
                                                : null,
                                        backgroundColor: Colors.grey[200],
                                        color: AppColors.secondaryColor,
                                        minHeight: 6,
                                      ),
                                    ],
                                    if (exists && !downloading) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'محمل محلياً',
                                        style: TextStyles.regular.copyWith(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing:
                                    downloading
                                        ? Icon(
                                          Icons.downloading,
                                          color: AppColors.secondaryColor,
                                        )
                                        : exists
                                        ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green[700],
                                        )
                                        : IconButton(
                                          icon: Icon(
                                            Icons.download,
                                            color: AppColors.secondaryColor,
                                          ),
                                          onPressed: () => _download(f.id),
                                        ),
                                onTap:
                                    exists || downloading
                                        ? null
                                        : () => _download(f.id),
                              ),
                            );
                          },
                        ),
              ),
    );
  }

  String _extractTitleFromContent(String text) {
    final cleaned = text.replaceAll('\n', ' ').trim();
    if (cleaned.length <= 50) return cleaned;
    return '${cleaned.substring(0, 50)}...';
  }
}

class _DriveFile {
  final String id;
  final String name;
  _DriveFile({required this.id, required this.name});
}
