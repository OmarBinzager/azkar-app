import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';
import '../../../core/providers/global_audio_provider.dart';
import '../globalhelpers/constants.dart';
import '../providers/quran_reciter_provider.dart';
import '../widgets/basmallah.dart';
import '../widgets/header_widget.dart';
// import 'package:wakelock/wakelock.dart';

class QuranViewPage extends ConsumerStatefulWidget {
  int pageNumber;
  var jsonData;
  var shouldHighlightText;
  var highlightVerse;
  QuranViewPage({
    Key? key,
    required this.pageNumber,
    this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
  }) : super(key: key);

  @override
  ConsumerState<QuranViewPage> createState() => _QuranViewPageState();
}

class _QuranViewPageState extends ConsumerState<QuranViewPage> {
  var highlightVerse;
  var shouldHighlightText;
  List<GlobalKey> richTextKeys = List.generate(
    604, // Replace with the number of pages in your PageView
    (_) => GlobalKey(),
  );
  setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/surahs.json',
    );
    var data = jsonDecode(jsonString);
    setState(() {
      widget.jsonData = data;
    });
  }

  int index = 0;
  late PageController _pageController;
  late Timer timer;
  String selectedSpan = "";

  highlightVerseFunction() {
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
    if (widget.jsonData == null) {
      loadJsonAsset();
    }
    setIndex();
    _pageController = PageController(initialPage: index);
    highlightVerseFunction();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder:
          (context, child) => Scaffold(
            backgroundColor: quranPagesColor,
            body: SafeArea(
              child: PageView.builder(
                reverse: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (a) {
                  setState(() {
                    selectedSpan = "";
                  });
                  index = a;
                },
                controller: _pageController,
                itemCount: totalPagesCount + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
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

                  return Container(
                    color: quranPagesColor,
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: screenSize.width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            size: 24,
                                          ),
                                        ),
                                        Text(
                                          widget?.jsonData?[getPageData(
                                                index,
                                              )[0]["surah"] -
                                              1]["name"] ?? 'تحميل...',
                                          style: const TextStyle(
                                            fontFamily: "Taha",
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final pageSurahs = getPageData(index);
                                      if (pageSurahs.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      final surahNum = pageSurahs[0]["surah"] as int;
                                      final selectedReciter = ref.watch(quranReciterProvider);
                                      final audioState = ref.watch(globalAudioProvider);
                                      final audioUrl = selectedReciter.getAudioUrl(surahNum);
                                      final isCurrent = audioState.activeSurahNumber == surahNum || audioState.audioUrl == audioUrl;
                                      final isPlaying = isCurrent && audioState.isPlaying;
                                      final isLoadingAudio = isCurrent && audioState.isLoading;

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: isPlaying ? 'إيقاف التلاوة' : 'تشغيل تلاوة السورة',
                                            icon: isLoadingAudio
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Icon(
                                                    isPlaying
                                                        ? Icons.pause_circle_filled
                                                        : Icons.play_circle_fill,
                                                    color: isPlaying ? Colors.amber[800] : Colors.black87,
                                                    size: 26,
                                                  ),
                                            onPressed: () {
                                              final surahName = widget?.jsonData?[surahNum - 1]["name"] ?? '';
                                              ref.read(globalAudioProvider.notifier).playUrlAudio(
                                                url: audioUrl,
                                                title: 'سورة $surahName (${selectedReciter.nameArabic})',
                                                surahNumber: surahNum,
                                                reciterId: selectedReciter.identifier,
                                              );
                                            },
                                          ),
                                          Text(
                                            "${"الصفحة رقم"} $index ",
                                            style: const TextStyle(
                                              fontFamily: 'aldahabi',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if ((index == 1 || index == 2))
                              SizedBox(height: (screenSize.height * .15)),
                            const SizedBox(height: 30),
                            _buildSurahContent(index),
                          ],
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

  m.Directionality _buildSurahContent(int index) {
    return Directionality(
                              textDirection: m.TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RichText(
                                    key: richTextKeys[index - 1],
                                    textDirection: m.TextDirection.rtl,
                                    textAlign:
                                        (index == 1 ||
                                                index == 2 ||
                                                index > 570)
                                            ? TextAlign.center
                                            : TextAlign.center,
                                    softWrap: true,
                                    locale: const Locale("ar"),
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: m.Colors.black,
                                        fontSize: 23.sp.toDouble(),
                                      ),
                                      children:
                                          getPageData(index).expand((e) {
                                            List<InlineSpan> spans = [];
                                            for (
                                              var i = e["start"];
                                              i <= e["end"];
                                              i++
                                            ) {
                                              // Header
                                              if (i == 1) {
                                                spans.add(
                                                  WidgetSpan(
                                                    child: HeaderWidget(
                                                      e: e,
                                                      jsonData:
                                                          widget.jsonData,
                                                    ),
                                                  ),
                                                );
                                                if (index != 187 &&
                                                    index != 1) {
                                                  spans.add(
                                                    WidgetSpan(
                                                      child: Basmallah(
                                                        index: 0,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                if (index == 187) {
                                                  spans.add(
                                                    WidgetSpan(
                                                      child: Container(
                                                        height: 10.h,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }

                                              // Verses
                                              spans.add(
                                                TextSpan(
                                                  recognizer:
                                                      LongPressGestureRecognizer()
                                                        ..onLongPress = () {
                                                          // showAyahOptionsSheet(
                                                          //     index,
                                                          //     e["surah"],
                                                          //     i);
                                                          print(
                                                            "longpressed",
                                                          );
                                                        }
                                                        ..onLongPressDown = (
                                                          details,
                                                        ) {
                                                          setState(() {
                                                            selectedSpan =
                                                                " ${e["surah"]}$i";
                                                          });
                                                        }
                                                        ..onLongPressUp = () {
                                                          setState(() {
                                                            selectedSpan = "";
                                                          });
                                                          print(
                                                            "finished long press",
                                                          );
                                                        }
                                                        ..onLongPressCancel =
                                                            () => setState(
                                                              () {
                                                                selectedSpan =
                                                                    "";
                                                              },
                                                            ),
                                                  text:
                                                      i == e["start"]
                                                          ? "${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1)}"
                                                          : getVerseQCF(
                                                            e["surah"],
                                                            i,
                                                          ).replaceAll(
                                                            ' ',
                                                            '',
                                                          ),
                                                  //  i == e["start"]
                                                  // ? "${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1).substring(0,  getVerseQCF(e["surah"], i).replaceAll(" ", "").substring(1).length - 1)}"
                                                  // :
                                                  // getVerseQCF(e["surah"], i).replaceAll(' ', '').substring(0,  getVerseQCF(e["surah"], i).replaceAll(' ', '').length - 1),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    height:
                                                        (index == 1 ||
                                                                index == 2)
                                                            ? 2.h
                                                            : 1.95.h,
                                                    letterSpacing: 0.w,
                                                    wordSpacing: 0,
                                                    fontFamily:
                                                        "QCF_P${index.toString().padLeft(3, "0")}",
                                                    fontSize:
                                                        index == 1 ||
                                                                index == 2
                                                            ? 28.sp
                                                            : index == 145 ||
                                                                index == 201
                                                            ? index == 532 ||
                                                                    index ==
                                                                        533
                                                                ? 22.5.sp
                                                                : 22.4.sp
                                                            : 23.1.sp,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  children: const <TextSpan>[
                                                    // TextSpan(
                                                    //   text: getVerseQCF(e["surah"], i).substring(getVerseQCF(e["surah"], i).length - 1),
                                                    //   style:  TextStyle(
                                                    //     color: isVerseStarred(
                                                    //                                                     e[
                                                    //                                                         "surah"],
                                                    //                                                     i)
                                                    //                                                 ? Colors
                                                    //                                                     .amber
                                                    //                                                 : secondaryColors[getValue("quranPageolorsIndex")] // Change color here
                                                    //   ),
                                                    // ),
                                                  ],
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
