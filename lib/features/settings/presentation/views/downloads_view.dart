import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/models/audio_item.dart';
import 'package:new_azkar_app/core/providers/global_audio_provider.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
import 'package:new_azkar_app/features/public/presentation/views/pdf_content_details_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DownloadsView extends ConsumerStatefulWidget {
  const DownloadsView({super.key});

  @override
  ConsumerState<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends ConsumerState<DownloadsView> {
  final Map<String, double> _progressById = {};
  final Map<String, bool> _downloadingById = {};
  final Map<String, bool> _existsById = {};
  final Map<String, int> _sizeById = {};

  List<AudioItem> _allAudios = [];
  List<AudioItem> _filteredAudios = [];
  String _searchQuery = '';
  String? _selectedCategory;
  bool _loading = true;
  bool _isBulkDownloading = false;
  bool _cancelBulk = false;

  // PDF Book State
  static const String _bookFileId = '18us5NUdQQJ_dZQg8BHd5Nk7b9wXKX0M2';
  static const String _bookUrl =
      'https://drive.google.com/file/d/18us5NUdQQJ_dZQg8BHd5Nk7b9wXKX0M2/view?usp=sharing';
  bool _pdfExists = false;
  int _pdfSize = 0;
  bool _isDownloadingPdf = false;
  double _pdfProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    setState(() => _loading = true);
    final audios = IsarHelper.getAllAudioItems();
    await _checkLocalStatus(audios);
    await _checkPdfStatus();

    if (!mounted) return;
    setState(() {
      _allAudios = audios;
      _applyFilter();
      _loading = false;
    });
  }

  Future<String> _getPdfLocalPath() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory pdfDir = Directory('${baseDir.path}/pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return '${pdfDir.path}/$_bookFileId.pdf';
  }

  Future<void> _checkPdfStatus() async {
    final path = await _getPdfLocalPath();
    final file = File(path);
    if (await file.exists() && await file.length() > 100) {
      try {
        final header = await file.openRead(0, 5).first;
        if (String.fromCharCodes(header).startsWith('%PDF')) {
          _pdfExists = true;
          _pdfSize = await file.length();
          return;
        }
      } catch (_) {}
      // Delete corrupted/non-PDF file
      try {
        await file.delete();
      } catch (_) {}
    }
    _pdfExists = false;
    _pdfSize = 0;
  }

  Future<void> _downloadPdf() async {
    if (_isDownloadingPdf) return;
    setState(() {
      _isDownloadingPdf = true;
      _pdfProgress = 0.0;
    });

    try {
      final path = await _getPdfLocalPath();
      final file = File(path);
      final downloadUrl =
          'https://drive.usercontent.google.com/download?id=$_bookFileId&export=download&confirm=t';

      final client = HttpClient();
      client.autoUncompress = true;

      Uri currentUri = Uri.parse(downloadUrl);
      HttpClientResponse? response;
      int redirectCount = 0;

      while (redirectCount < 5) {
        final request = await client.getUrl(currentUri);
        request.followRedirects = false;
        response = await request.close();
        if (response.statusCode >= 300 &&
            response.statusCode < 400 &&
            response.headers.value('location') != null) {
          currentUri = currentUri.resolve(response.headers.value('location')!);
          redirectCount++;
        } else {
          break;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('HTTP ${response?.statusCode}');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final sink = file.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && mounted) {
          setState(() {
            _pdfProgress = receivedBytes / totalBytes;
          });
        }
      }
      await sink.flush();
      await sink.close();
      client.close();

      await _checkPdfStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحميل كتاب عمل اليوم والليلة وحفظه محلياً'),
            backgroundColor: AppColors.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تحميل الكتاب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  Future<void> _deletePdf() async {
    final path = await _getPdfLocalPath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _checkPdfStatus();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الكتاب من التخزين المحلي'),
          backgroundColor: AppColors.secondaryColor,
        ),
      );
    }
  }

  Future<String> _getLocalPath(String voiceFile) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$voiceFile.mp3';
  }

  Future<void> _checkLocalStatus(List<AudioItem> audios) async {
    for (final item in audios) {
      final path = await _getLocalPath(item.voiceFile);
      final file = File(path);
      final exists = await file.exists();
      _existsById[item.voiceFile] = exists;
      if (exists) {
        try {
          _sizeById[item.voiceFile] = await file.length();
        } catch (_) {
          _sizeById[item.voiceFile] = 0;
        }
      } else {
        _sizeById[item.voiceFile] = 0;
      }
    }
  }

  void _applyFilter() {
    var list = _allAudios;
    if (_selectedCategory != null && _selectedCategory != 'الكل') {
      list = list.where((item) => item.category == _selectedCategory).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list
          .where((item) =>
              item.title.toLowerCase().contains(query) ||
              (item.category ?? '').toLowerCase().contains(query))
          .toList();
    }
    _filteredAudios = list;
  }

  int get _downloadedCount =>
      _allAudios.where((a) => _existsById[a.voiceFile] == true).length;

  int get _totalBytesUsed =>
      _sizeById.values.fold(0, (sum, size) => sum + size) + _pdfSize;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 ميجابايت';
    final mb = bytes / (1024 * 1024);
    if (mb < 1.0) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} كيلوبايت';
    }
    return '${mb.toStringAsFixed(1)} ميجابايت';
  }

  Future<void> _downloadSingle(String voiceFile, {bool silent = false}) async {
    if (_downloadingById[voiceFile] == true) return;

    setState(() {
      _downloadingById[voiceFile] = true;
      _progressById[voiceFile] = 0.0;
    });

    final String url =
        'https://drive.google.com/uc?export=download&id=$voiceFile&confirm=t';
    final String path = await _getLocalPath(voiceFile);
    final file = File(path);

    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      final req = await httpClient.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('status ${res.statusCode}');
      }

      final total = res.contentLength > 0 ? res.contentLength : null;
      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in res) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null && mounted) {
          setState(() {
            _progressById[voiceFile] = received / total;
          });
        }
      }
      await sink.close();

      final length = await file.length();
      if (mounted) {
        setState(() {
          _downloadingById[voiceFile] = false;
          _progressById[voiceFile] = 1.0;
          _existsById[voiceFile] = true;
          _sizeById[voiceFile] = length;
        });

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تنزيل الملف الصوتي بنجاح'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _downloadingById[voiceFile] = false;
          _progressById[voiceFile] = 0.0;
        });

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر تنزيل الملف الصوتي، يرجى المحاولة لاحقاً'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      httpClient?.close(force: true);
    }
  }

  Future<void> _deleteAudio(String voiceFile) async {
    try {
      final path = await _getLocalPath(voiceFile);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        setState(() {
          _existsById[voiceFile] = false;
          _sizeById[voiceFile] = 0;
          _progressById[voiceFile] = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الملف الصوتي من الذاكرة'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _downloadAll() async {
    final toDownload = _allAudios
        .where((a) => _existsById[a.voiceFile] != true && _downloadingById[a.voiceFile] != true)
        .toList();

    if (toDownload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جميع الملفات الصوتية محملة بالفعل')),
      );
      return;
    }

    setState(() {
      _isBulkDownloading = true;
      _cancelBulk = false;
    });

    for (int i = 0; i < toDownload.length; i++) {
      if (_cancelBulk) break;
      await _downloadSingle(toDownload[i].voiceFile, silent: true);
    }

    if (mounted) {
      setState(() {
        _isBulkDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتملت عملية التنزيل الجماعي')),
      );
    }
  }

  Future<void> _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف جميع الصوتيات',
          style: TextStyles.bold.copyWith(color: AppColors.primaryColor),
        ),
        content: Text(
          'هل أنت متأكد من حذف جميع الملفات الصوتية المحملة؟ يمكنك إعادة تنزيلها في أي وقت.',
          style: TextStyles.regular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (final item in _allAudios) {
      if (_existsById[item.voiceFile] == true) {
        final path = await _getLocalPath(item.voiceFile);
        final file = File(path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    }

    if (mounted) {
      setState(() {
        for (final item in _allAudios) {
          _existsById[item.voiceFile] = false;
          _sizeById[item.voiceFile] = 0;
          _progressById[item.voiceFile] = 0.0;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف جميع الملفات الصوتية')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...{
      for (final a in _allAudios)
        if (a.category != null && a.category!.isNotEmpty) a.category!
    }];

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'إدارة التنزيلات',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryColor),
            )
          : Column(
              children: [
                _buildStorageHeaderCard(),
                _buildPdfBookCard(),
                _buildSearchAndFilters(categories),
                Expanded(
                  child: _filteredAudios.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد ملفات صوتية مطابقة',
                            style: TextStyles.medium.copyWith(
                              color: AppColors.secondaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: LayoutConstants.screenPadding.r,
                            vertical: 8.h,
                          ),
                          itemCount: _filteredAudios.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final audio = _filteredAudios[index];
                            return _buildAudioCard(audio);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPdfBookCard() {
    final sizeMb = (_pdfSize / (1024 * 1024)).toStringAsFixed(1);
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: LayoutConstants.screenPadding.r,
        vertical: 4.h,
      ),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.secondaryColor,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كتاب عمل اليوم والليلة الكامل (PDF)',
                  style: TextStyles.bold.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _isDownloadingPdf
                      ? 'جاري التحميل... ${(_pdfProgress * 100).toInt()}%'
                      : _pdfExists
                          ? 'محفوظ محلياً • $sizeMb MB'
                          : 'غير محمّل (متاح للقراءة والتحميل)',
                  style: TextStyles.regular.copyWith(
                    color: _pdfExists
                        ? Colors.green.shade700
                        : AppColors.secondaryColor.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (_isDownloadingPdf)
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: CircularProgressIndicator(
                value: _pdfProgress > 0 ? _pdfProgress : null,
                strokeWidth: 2.5,
                color: AppColors.secondaryColor,
              ),
            )
          else if (_pdfExists) ...[
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded,
                  color: AppColors.secondaryColor),
              tooltip: 'قراءة الكتاب',
              onPressed: () {
                context.pushNamed(
                  Routes.pdfContentDetails,
                  extra: PdfContentDetailsParams(
                    title: 'كتاب عمل اليوم والليلة',
                    pdfPath: _bookUrl,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: 'حذف من التخزين المحلي',
              onPressed: _deletePdf,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.download_rounded,
                  color: AppColors.secondaryColor),
              tooltip: 'تحميل وحفظ محلياً',
              onPressed: _downloadPdf,
            ),
        ],
      ),
    );
  }

  Widget _buildStorageHeaderCard() {
    return Container(
      margin: EdgeInsets.all(LayoutConstants.screenPadding.r),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondaryColor, AppColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.cloud_download_rounded, color: AppColors.gold, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الملفات المحملة: $_downloadedCount من إجمالي ${_allAudios.length}',
                      style: TextStyles.bold.copyWith(color: Colors.white, fontSize: 14.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'المساحة المستخدمة: ${_formatBytes(_totalBytesUsed)}',
                      style: TextStyles.regular.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  onPressed: _isBulkDownloading
                      ? () => setState(() => _cancelBulk = true)
                      : _downloadAll,
                  icon: Icon(_isBulkDownloading ? Icons.stop_rounded : Icons.download_rounded, size: 18.r),
                  label: Text(
                    _isBulkDownloading ? 'إيقاف التحميل' : 'تحميل الكل (${_allAudios.length - _downloadedCount})',
                    style: TextStyles.bold.copyWith(fontSize: 12.sp),
                  ),
                ),
              ),
              if (_downloadedCount > 0) ...[
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[300],
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  ),
                  onPressed: _deleteAll,
                  icon: Icon(Icons.delete_outline_rounded, size: 16.r),
                  label: Text('حذف الكل', style: TextStyles.bold.copyWith(fontSize: 12.sp)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(List<String> categories) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: LayoutConstants.screenPadding.r),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
                _applyFilter();
              });
            },
            decoration: InputDecoration(
              hintText: 'بحث عن صوتية...',
              hintStyle: TextStyles.regular.copyWith(color: Colors.grey[500], fontSize: 13.sp),
              prefixIcon: Icon(Icons.search, color: AppColors.primaryColor, size: 20.r),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: LayoutConstants.screenPadding.r),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = (_selectedCategory == null && cat == 'الكل') ||
                  _selectedCategory == cat;
              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyles.medium.copyWith(
                    color: isSelected ? Colors.white : AppColors.secondaryColor,
                    fontSize: 11.sp,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.secondaryColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: isSelected ? AppColors.secondaryColor : Colors.grey[300]!,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = cat == 'الكل' ? null : cat;
                    _applyFilter();
                  });
                },
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildAudioCard(AudioItem audio) {
    final downloading = _downloadingById[audio.voiceFile] == true;
    final progress = _progressById[audio.voiceFile] ?? 0.0;
    final exists = _existsById[audio.voiceFile] == true;
    final sizeBytes = _sizeById[audio.voiceFile] ?? 0;
    final currentPlaying = ref.watch(globalAudioProvider).voiceFile == audio.voiceFile;
    final isPlaying = currentPlaying && ref.watch(globalAudioProvider).isPlaying;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: currentPlaying
              ? AppColors.gold
              : AppColors.secondaryColor.withOpacity(0.1),
          width: currentPlaying ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        leading: GestureDetector(
          onTap: () {
            ref.read(globalAudioProvider.notifier).playAudio(
                  voiceFile: audio.voiceFile,
                  title: audio.title,
                );
          },
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: currentPlaying
                  ? AppColors.gold.withOpacity(0.2)
                  : AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: currentPlaying ? AppColors.gold : AppColors.primaryColor,
              size: 22.r,
            ),
          ),
        ),
        title: Text(
          audio.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.mediumBold.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 13.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                if (audio.category != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      audio.category!,
                      style: TextStyles.regular.copyWith(
                        color: AppColors.secondaryColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  exists ? _formatBytes(sizeBytes) : 'غير محمل',
                  style: TextStyles.regular.copyWith(
                    color: exists ? Colors.green[700] : Colors.grey[500],
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            if (downloading) ...[
              SizedBox(height: 6.h),
              LinearProgressIndicator(
                value: progress > 0 && progress < 1.0 ? progress : null,
                backgroundColor: Colors.grey[200],
                color: AppColors.secondaryColor,
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (downloading)
              SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else if (exists) ...[
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20.r),
                tooltip: 'حذف من الذاكرة',
                onPressed: () => _deleteAudio(audio.voiceFile),
              ),
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20.r),
            ] else
              IconButton(
                icon: Icon(Icons.download_rounded, color: AppColors.primaryColor, size: 22.r),
                tooltip: 'تنزيل للاستماع أوفلاين',
                onPressed: () => _downloadSingle(audio.voiceFile),
              ),
          ],
        ),
      ),
    );
  }
}
