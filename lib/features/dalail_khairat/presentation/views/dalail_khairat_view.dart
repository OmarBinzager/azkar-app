import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/features/dalail_khairat/presentation/widgets/dalail_arch_card.dart';
import 'package:new_azkar_app/features/public/presentation/views/pdf_content_details_view.dart';
import 'package:new_azkar_app/core/providers/settings_provider.dart';

class DalailItem {
  final String title;
  final String? subtitle;
  final String pdfUrl;
  final String? voiceFile;
  final bool isIntro;

  const DalailItem({
    required this.title,
    this.subtitle,
    required this.pdfUrl,
    this.voiceFile,
    this.isIntro = false,
  });
}

class DalailKhairatView extends ConsumerStatefulWidget {
  const DalailKhairatView({super.key});

  // 9 Ahzab items matching the reference image grid
  static const List<DalailItem> dalailItems = [
    DalailItem(
      title: 'المُقَدِّمَةُ',
      subtitle: '',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1sOTEy5wmd52PXOFA6ckyZLn9pha90Z32',
      isIntro: true,
      // voiceFile: '11bVqJXT6cjeZUxZA4wD4BlV6FmtOWxVZ',
    ),
    DalailItem(
      title: 'الحِزْبُ الأَوَّلُ',
      subtitle: 'يَوْمُ الإثْنَيْنِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1MQmnZWYQHKu30eoKosI8VYMOzzG_BCJV',
      voiceFile: '1hlV-BfFY5GNeu7Wc_wdA9BCY2n4ouLhl',
    ),
    DalailItem(
      title: 'الحِزْبُ الثَّانِي',
      subtitle: 'يَوْمُ الثُّلَاثَاءِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1W7ChIfA8QhbJuVzHD5VRnuM4rxD2xvzG',
      voiceFile: '1NqgD6xoQTTZtRAbLzvr58fATakXo6iE2',
    ),
    DalailItem(
      title: 'الحِزْبُ الثَّالِثُ',
      subtitle: 'يَوْمُ الأَرْبِعَاءِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1i97wqMF9jSUMA3qxJIGIueVKBy-_kUQN',
      voiceFile: '1w9uuN6fh-lpM5OWQxM-2uobJzvVjjZba',
    ),
    DalailItem(
      title: 'الحِزْبُ الرَّابِعُ',
      subtitle: 'يَوْمُ الخَمِيسِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1Jk6M58I8mEm0Jcdiz8Xf9C3LjXOEKxmu',
      voiceFile: '1iD7aCuWjyRhHBpOinLNj9idvTVDXpwUE',
    ),
    DalailItem(
      title: 'الحِزْبُ الخَامِسُ',
      subtitle: 'يَوْمُ الجُمُعَةِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=11LQ_sGVYTlW3VLlGEPfDWs75hgL83-RX',
      voiceFile: '1SJ-Fbr5fAFWl-mhkbQv8xisYxBeTiBht',
    ),
    DalailItem(
      title: 'الحِزْبُ السَّادِسُ',
      subtitle: 'يَوْمُ السَّبْتِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1JnBW0yh5q8jWixMLJIoxBx7PJ4BIJeIp',
      voiceFile: '1G6SfAVUAeCnYGvcNpTi2EckSXgrWJ1sQ',
    ),
    DalailItem(
      title: 'الحِزْبُ السَّابِعُ',
      subtitle: 'يَوْمُ الأَحَدِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1RO8q50U889RiNQQJGh_WIH32EGNt4pGw',
      voiceFile: '1FlBbPwqR9SQwFn0aDfS3bpXa7JAlXS7h',
    ),
    DalailItem(
      title: 'الحِزْبُ الثَّامِنُ',
      subtitle: 'يَوْمُ الإثْنَيْنِ',
      pdfUrl:
          'https://drive.google.com/uc?export=download&id=1B_2hs2GkMtHULbJ34wg5UgXULCNbclzi',
      voiceFile: '1FlBbPwqR9SQwFn0aDfS3bpXa7JAlXS7h',
    ),
  ];

  static DalailItem? getDalailItem({int? headerId, String? text}) {
    if (headerId != null) {
      switch (headerId) {
        case 85:
          return dalailItems[0];
        case 87:
          return dalailItems[1];
        case 88:
          return dalailItems[2];
        case 89:
          return dalailItems[3];
        case 90:
          return dalailItems[4];
        case 91:
          return dalailItems[5];
        case 92:
          return dalailItems[6];
        case 93:
          return dalailItems[7];
      }
    }
    if (text != null && text.contains('دلائل الخيرات')) {
      if (text.contains('الجمعة')) return dalailItems[5];
      if (text.contains('السبت')) return dalailItems[6];
      if (text.contains('الأحد') || text.contains('الاحد'))
        return dalailItems[7];
      if (text.contains('الثلاثاء')) return dalailItems[2];
      if (text.contains('الأربعاء') || text.contains('الاربعاء'))
        return dalailItems[3];
      if (text.contains('الخميس')) return dalailItems[4];
      if (text.contains('الاثنين') || text.contains('الإثنين'))
        return dalailItems[1];
    }
    return null;
  }

  @override
  ConsumerState<DalailKhairatView> createState() => _DalailKhairatViewState();
}

class _DalailKhairatViewState extends ConsumerState<DalailKhairatView> {
  List<DalailItem> get items => DalailKhairatView.dalailItems;

  void _openPdf(DalailItem item) {
    context.pushNamed(
      Routes.pdfContentDetails,
      extra: PdfContentDetailsParams(
        title:
            item.subtitle != null && item.subtitle!.isNotEmpty
                ? '${item.title} - ${item.subtitle}'
                : item.title,
        pdfPath: item.pdfUrl,
        voiceFile: item.voiceFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    const goldHeaderColor = Color(0xFFC8B282);
    const goldTitleColor = Color(0xFFFBF7EE);
    const bgColor = Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: settings.nightMode ? const Color(0xFF1E1C1A) : bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: goldHeaderColor,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: goldTitleColor,
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: Text(
            'دَلَائِلُ الخَيْرَاتِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: goldTitleColor,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort_rounded, color: goldTitleColor),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return DalailArchCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        isIntro: item.isIntro,
                        onTap: () => _openPdf(item),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Page Dots Indicator (Matching bottom of reference screenshot)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC5A880),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A880).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A880).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
