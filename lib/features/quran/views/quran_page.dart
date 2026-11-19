import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/global_audio_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../globalhelpers/constants.dart';
import '../models/reciter.dart';
import '../providers/quran_reciter_provider.dart';
import '../widgets/basmallah.dart';
import '../widgets/header_widget.dart';
import '../widgets/medina_mushaf_frame.dart';

class QuranViewPage extends ConsumerStatefulWidget {
  final int pageNumber;
  final dynamic jsonData;
  final bool shouldHighlightText;
  final String highlightVerse;

  const QuranViewPage({
    super.key,
    required this.pageNumber,
    this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
  });

  @override
  ConsumerState<QuranViewPage> createState() => _QuranViewPageState();
}

class _QuranViewPageState extends ConsumerState<QuranViewPage> {
  String highlightVerse = "";
  bool shouldHighlightText = false;
  bool _showControls = false;
  int index = 0;
  late PageController _pageController;
  String selectedSpan = "";
  dynamic _jsonData;

  dynamic get activeJsonData => _jsonData ?? widget.jsonData;

  final List<GlobalKey> richTextKeys = List.generate(
    604,
    (_) => GlobalKey(),
  );

  void setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  Future<void> loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/surahs.json',
    );
    final data = jsonDecode(jsonString);
    if (mounted) {
      setState(() {
        _jsonData = data;
      });
    }
  }

  void highlightVerseFunction() {
    setState(() {
      shouldHighlightText = widget.shouldHighlightText;
    });
    if (widget.shouldHighlightText) {
      setState(() {
        highlightVerse = widget.highlightVerse;
      });

      Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted) {
          setState(() {
            shouldHighlightText = false;
          });
        }
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              shouldHighlightText = true;
            });
          }
          if (timer.tick == 4) {
            if (mounted) {
              setState(() {
                highlightVerse = "";
                shouldHighlightText = false;
              });
            }
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.jsonData == null) {
      loadJsonAsset();
    }
    setIndex();
    _pageController = PageController(initialPage: widget.pageNumber);
    highlightVerseFunction();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showReciterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fourthColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentReciter = ref.watch(quranReciterProvider);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'اختر القارئ (التلاوة الصوتية)',
                style: TextStyles.bold.copyWith(
                  color: AppColors.secondaryColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: defaultQuranReciters.length,
                  itemBuilder: (context, idx) {
                    final reciter = defaultQuranReciters[idx];
                    final isSelected =
                        reciter.identifier == currentReciter.identifier;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppColors.secondaryColor,
                        ),
                        title: Text(
                          reciter.nameArabic,
                          style: TextStyles.mediumBold.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        subtitle: Text(
                          reciter.nameEnglish,
                          style: TextStyles.regular.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(quranReciterProvider.notifier)
                              .selectReciter(reciter);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTextSizeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentScale = ref.watch(settingsProvider).quranTextScale;
            final percentage = (currentScale * 100).round();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_size_rounded,
                            color: AppColors.secondaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'حجم خط المصحف الشريف',
                            style: TextStyles.bold.copyWith(
                              color: AppColors.secondaryColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          percentage == 100
                              ? '١٠٠٪ (ملء الشاشة)'
                              : '${toArabicDigits(percentage)}٪',
                          style: TextStyles.bold.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'تصغير الخط',
                        icon: Text(
                          'A-',
                          style: TextStyle(
                            color: currentScale > 0.9
                                ? AppColors.secondaryColor
                                : Colors.grey[400],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: currentScale > 0.9
                            ? () {
                                final newScale =
                                    ((currentScale - 0.1) * 10).round() / 10;
                                ref
                                    .read(settingsProvider.notifier)
                                    .setQuranTextScale(newScale.clamp(0.9, 1.8));
                              }
                            : null,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            activeTrackColor: AppColors.secondaryColor,
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: AppColors.secondaryColor,
                            overlayColor: AppColors.secondaryColor
                                .withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            value: currentScale.clamp(0.9, 1.8),
                            min: 0.9,
                            max: 1.8,
                            divisions: 9,
                            onChanged: (val) {
                              final roundedVal = (val * 10).round() / 10;
                              ref
                                  .read(settingsProvider.notifier)
                                  .setQuranTextScale(roundedVal);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'تكبير الخط',
                        icon: Text(
                          'A+',
                          style: TextStyle(
                            color: currentScale < 1.8
                                ? AppColors.secondaryColor
                                : Colors.grey[400],
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: currentScale < 1.8
                            ? () {
                                final newScale =
                                    ((currentScale + 0.1) * 10).round() / 10;
                                ref
                                    .read(settingsProvider.notifier)
                                    .setQuranTextScale(newScale.clamp(0.9, 1.8));
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: AppColors.secondaryColor,
                        ),
                        label: Text(
                          'إعادة ضبط (١٠٠٪ ملء الشاشة)',
                          style: TextStyles.mediumBold.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(settingsProvider.notifier)
                              .setQuranTextScale(1.0);
                        },
                      ),
                      Text(
                        '💡 يمكنك التكبير بالإصبعين',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current page info for overlay
    final effectivePage = index > 0 && index <= totalPagesCount ? index : 1;
    final currentPageData = getPageData(effectivePage);
    final currentSurahNum =
        currentPageData.isNotEmpty ? currentPageData[0]["surah"] as int : 1;
    final currentFirstVerse =
        currentPageData.isNotEmpty ? currentPageData[0]["start"] as int : 1;
    final currentJuzNum = getJuzNumber(currentSurahNum, currentFirstVerse);
    final currentSurahName = (activeJsonData != null &&
            currentSurahNum <= (activeJsonData as List).length)
        ? activeJsonData[currentSurahNum - 1]["name"] ?? ''
        : '';

    final selectedReciter = ref.watch(quranReciterProvider);
    final audioState = ref.watch(globalAudioProvider);
    final quranTextScale = ref.watch(settingsProvider).quranTextScale;
    final audioUrl = selectedReciter.getAudioUrl(currentSurahNum);
    final isCurrent = audioState.activeSurahNumber == currentSurahNum ||
        audioState.audioUrl == audioUrl;
    final isPlaying = isCurrent && audioState.isPlaying;
    final isLoadingAudio = isCurrent && audioState.isLoading;

    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder: (context, child) => Scaffold(
        backgroundColor: quranPagesColor,
        body: Stack(
          children: [
            // 1. Full-bleed Corner-to-Corner PageView with Medina Mushaf Frame
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: PageView.builder(
                reverse: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (a) {
                  setState(() {
                    selectedSpan = "";
                    index = a;
                  });
                },
                controller: _pageController,
                itemCount: totalPagesCount + 1,
                itemBuilder: (context, pageIdx) {
                  if (pageIdx == 0) {
                    return Container(
                      color: const Color(0xffFFFCE7),
                      child: Center(
                        child: Text(
                          "القرآن الكريم",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontFamily: "Taha",
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }

                  final pageData = getPageData(pageIdx);
                  final surahNum =
                      pageData.isNotEmpty ? pageData[0]["surah"] as int : 1;
                  final firstVerse =
                      pageData.isNotEmpty ? pageData[0]["start"] as int : 1;
                  final juzNum = getJuzNumber(surahNum, firstVerse);
                  final surahName = (activeJsonData != null &&
                          surahNum <= (activeJsonData as List).length)
                      ? activeJsonData[surahNum - 1]["name"] ?? ''
                      : '';

                  return _QuranPageItem(
                    key: ValueKey(pageIdx),
                    pageIdx: pageIdx,
                    surahName: surahName,
                    juzNum: juzNum,
                    textScale: quranTextScale,
                    content: SizedBox(
                      width: 370,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pageIdx == 1 || pageIdx == 2)
                            SizedBox(height: 12.h),
                          _buildSurahContent(pageIdx),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Animated Floating Top Controls Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: _showControls ? 0 : -120,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    // Title info (Surah & Juz)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentSurahName.isNotEmpty
                                ? 'سورة $currentSurahName'
                                : 'القرآن الكريم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "Amiri",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'الجزء ${toArabicDigits(currentJuzNum)} • ص ${toArabicDigits(effectivePage)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "Amiri",
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Reciter selector button
                    GestureDetector(
                      onTap: () => _showReciterBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mic,
                              size: 13,
                              color: Colors.amberAccent,
                            ),
                            const SizedBox(width: 3),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 60),
                              child: Text(
                                selectedReciter.nameArabic.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // Text Size button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: 'حجم خط المصحف والتكبير',
                      icon: const Icon(
                        Icons.format_size_rounded,
                        color: Colors.amberAccent,
                        size: 22,
                      ),
                      onPressed: () => _showTextSizeBottomSheet(context),
                    ),
                    const SizedBox(width: 2),
                    // Audio Play / Pause
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: isPlaying
                          ? 'إيقاف التلاوة'
                          : 'تشغيل تلاوة السورة',
                      icon: isLoadingAudio
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.amberAccent,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.amberAccent,
                              size: 30,
                            ),
                      onPressed: () {
                        ref.read(globalAudioProvider.notifier).playUrlAudio(
                          url: audioUrl,
                          title:
                              'سورة $currentSurahName (${selectedReciter.nameArabic})',
                          surahNumber: currentSurahNum,
                          reciterId: selectedReciter.identifier,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. Animated Floating Bottom Page Jumper Slider
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: _showControls ? 0 : -110,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  left: 20,
                  right: 20,
                  top: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'صفحة ٦٠٤',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontFamily: 'Amiri',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'صفحة ${toArabicDigits(effectivePage)} من ٦٠٤',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                        Text(
                          'صفحة ١',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: Colors.amberAccent,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.amberAccent,
                        overlayColor:
                            Colors.amberAccent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: effectivePage.toDouble(),
                        min: 1,
                        max: 604,
                        divisions: 603,
                        onChanged: (val) {
                          final newPage = val.round();
                          setState(() {
                            index = newPage;
                          });
                          _pageController.jumpToPage(newPage);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  m.Directionality _buildSurahContent(int pageIndex) {
    return Directionality(
      textDirection: m.TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SizedBox(
          width: double.infinity,
          child: RichText(
            key: richTextKeys[pageIndex - 1],
            textDirection: m.TextDirection.rtl,
            textAlign: (pageIndex == 1 || pageIndex == 2 || pageIndex > 570)
                ? TextAlign.center
                : TextAlign.center,
            softWrap: true,
            locale: const Locale("ar"),
            text: TextSpan(
              style: TextStyle(
                color: m.Colors.black,
                fontSize: 23.sp.toDouble(),
              ),
              children: getPageData(pageIndex).expand((e) {
                List<InlineSpan> spans = [];
                for (var i = e["start"]; i <= e["end"]; i++) {
                  // Surah Header Banner
                  if (i == 1) {
                    spans.add(
                      WidgetSpan(
                        child: HeaderWidget(
                          e: e,
                          jsonData: activeJsonData,
                        ),
                      ),
                    );
                    if (pageIndex != 187 && pageIndex != 1) {
                      spans.add(
                        const WidgetSpan(
                          child: Basmallah(index: 0),
                        ),
                      );
                    }
                    if (pageIndex == 187) {
                      spans.add(
                        WidgetSpan(
                          child: Container(
                            height: 10.h,
                          ),
                        ),
                      );
                    }
                  }

                  // Verses TextSpan with QCF Fonts
                  spans.add(
                    TextSpan(
                      recognizer: LongPressGestureRecognizer()
                        ..onLongPress = () {
                          // Long press handler for verse
                        }
                        ..onLongPressDown = (details) {
                          setState(() {
                            selectedSpan = " ${e["surah"]}$i";
                          });
                        }
                        ..onLongPressUp = () {
                          setState(() {
                            selectedSpan = "";
                          });
                        }
                        ..onLongPressCancel = () => setState(() {
                          selectedSpan = "";
                        }),
                      text: i == e["start"]
                          ? "${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                          : getVerseQCF(
                              e["surah"],
                              i,
                            ).replaceAll(' ', ''),
                      style: TextStyle(
                        color: Colors.black,
                        height: (pageIndex == 1 || pageIndex == 2) ? 2.h : 1.95.h,
                        letterSpacing: 0.w,
                        wordSpacing: 0,
                        fontFamily:
                            "QCF_P${pageIndex.toString().padLeft(3, "0")}",
                        fontSize: pageIndex == 1 || pageIndex == 2
                            ? 28.sp
                            : pageIndex == 145 || pageIndex == 201
                                ? pageIndex == 532 || pageIndex == 533
                                    ? 22.5.sp
                                    : 22.4.sp
                                : 23.1.sp,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                }
                return spans;
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// A stateful page item that renders the authentic Medina Mushaf frame and
/// supports interactive text resizing via both pinch-to-zoom and the persistent text scale setting.
class _QuranPageItem extends StatefulWidget {
  final int pageIdx;
  final String surahName;
  final int juzNum;
  final double textScale;
  final Widget content;

  const _QuranPageItem({
    super.key,
    required this.pageIdx,
    required this.surahName,
    required this.juzNum,
    required this.textScale,
    required this.content,
  });

  @override
  State<_QuranPageItem> createState() => _QuranPageItemState();
}

class _QuranPageItemState extends State<_QuranPageItem> {
  late TransformationController _controller;
  bool _isZoomed = false;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void didUpdateWidget(_QuranPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textScale != widget.textScale && _lastSize != null) {
      _applyScale(widget.textScale, _lastSize!);
    }
  }

  void _applyScale(double scale, Size size) {
    if (scale <= 1.02) {
      _controller.value = Matrix4.identity();
      if (_isZoomed) {
        setState(() => _isZoomed = false);
      }
    } else {
      final dx = (1.0 - scale) * size.width / 2;
      final dy = (1.0 - scale) * size.height / 2;
      _controller.value = Matrix4.diagonal3Values(scale, scale, 1.0)
        ..setTranslationRaw(dx, dy, 0.0);
      if (!_isZoomed) {
        setState(() => _isZoomed = true);
      }
    }
  }

  void _onDoubleTap() {
    if (_lastSize == null) return;
    setState(() {
      if (_isZoomed || widget.textScale > 1.05) {
        _controller.value = Matrix4.identity();
        _isZoomed = false;
      } else {
        const scale = 1.4;
        final dx = (1.0 - scale) * _lastSize!.width / 2;
        final dy = (1.0 - scale) * _lastSize!.height / 2;
        _controller.value = Matrix4.diagonal3Values(scale, scale, 1.0)
          ..setTranslationRaw(dx, dy, 0.0);
        _isZoomed = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: quranPagesColor,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        top: true,
        bottom: true,
        left: false,
        right: false,
        child: MedinaMushafFrame(
          pageNumber: widget.pageIdx,
          surahName: widget.surahName,
          juzNumber: widget.juzNum,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              if (_lastSize != size) {
                _lastSize = size;
                if (widget.textScale > 1.02) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _applyScale(widget.textScale, size);
                  });
                }
              }

              return ClipRect(
                child: GestureDetector(
                  onDoubleTap: _onDoubleTap,
                  behavior: HitTestBehavior.translucent,
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.9,
                    maxScale: 3.0,
                    panEnabled: _isZoomed,
                    scaleEnabled: true,
                    onInteractionUpdate: (details) {
                      final currentScale = _controller.value.getMaxScaleOnAxis();
                      final zoomed = currentScale > 1.05;
                      if (zoomed != _isZoomed) {
                        setState(() {
                          _isZoomed = zoomed;
                        });
                      }
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: widget.content,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

