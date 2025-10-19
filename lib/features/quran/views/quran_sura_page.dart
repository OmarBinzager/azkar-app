import 'dart:convert';

import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
// import 'package:quran/dart';
import 'package:quran/quran.dart';
import '../globalhelpers/constants.dart';
import '../models/sura.dart';
import 'package:easy_container/easy_container.dart';
import '../views/quran_page.dart';
import 'package:string_validator/string_validator.dart';

class QuranPage extends StatefulWidget {
  var suraJsonData;

  QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/surahs.json',
    );
    var data = jsonDecode(jsonString);
    setState(() {
      widget.suraJsonData = data;
    });
  }

  bool isLoading = true;
  var searchQuery = "";
  var filteredData;
  List<Surah> surahList = [];
  var ayatFiltered;
  List pageNumbers = [];

  addFilteredData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      filteredData = widget.suraJsonData;
      isLoading = false;
    });
  }

  @override
  void initState() {
    loadJsonAsset();
    addFilteredData();
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    textEditingController.dispose();
    super.dispose();
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
          "القرآن الكريم",
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 24),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book,
                        size: 40,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحميل القرآن الكريم...',
                      style: TextStyles.medium.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  _buildSearchSection(),
                  Expanded(child: _buildContent()),
                ],
              ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(LayoutConstants.screenPadding),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        controller: textEditingController,
        focusNode: _searchFocusNode,
        onChanged: _handleSearch,
        style: TextStyles.medium.copyWith(color: AppColors.secondaryColor),
        decoration: InputDecoration(
          hintText: 'البحث في السور أو الآيات...',
          hintStyle: TextStyles.medium.copyWith(color: Colors.grey[400]),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryColor.withOpacity(0.6),
          ),
          suffixIcon:
              textEditingController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.secondaryColor.withOpacity(0.6),
                    ),
                    onPressed: () {
                      textEditingController.clear();
                      _handleSearch("");
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
    });

    if (value.isEmpty) {
      filteredData = widget.suraJsonData;
      pageNumbers = [];
      ayatFiltered = null;
      return;
    }

    // Handle page number search
    if (isInt(value) && toInt(value) < 605 && toInt(value) > 0) {
      if (!pageNumbers.contains(toInt(value))) {
        pageNumbers.add(toInt(value));
      }
    } else {
      pageNumbers.clear();
    }

    // Handle text search
    if (value.length > 2 || value.contains(" ")) {
      ayatFiltered = searchWords(value);
      filteredData =
          widget.suraJsonData.where((sura) {
            final suraName = sura['name'].toString().toLowerCase();
            final suraNameTranslated =
                getSurahNameArabic(sura["number"]).toLowerCase();
            return suraName.contains(value.toLowerCase()) ||
                suraNameTranslated.contains(value.toLowerCase());
          }).toList();
    } else {
      ayatFiltered = null;
      filteredData = widget.suraJsonData;
    }
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.screenPadding,
      ),
      children: [
        if (pageNumbers.isNotEmpty) _buildPageResults(),
        if (ayatFiltered != null) _buildAyahResults(),
        _buildSurahList(),
      ],
    );
  }

  Widget _buildPageResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'نتائج البحث في الصفحات',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        ...pageNumbers.map((pageNumber) => _buildPageCard(pageNumber)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPageCard(int pageNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              pageNumber.toString(),
              style: TextStyles.mediumBold.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
          ),
        ),
        title: Text(
          'الصفحة $pageNumber',
          style: TextStyles.mediumBold.copyWith(
            color: AppColors.secondaryColor,
          ),
        ),
        subtitle: Text(
          'سورة ${getSurahName(getPageData(pageNumber)[0]["surah"])}',
          style: TextStyles.regular.copyWith(color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.secondaryColor.withOpacity(0.6),
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (builder) => QuranViewPage(
                    shouldHighlightText: false,
                    highlightVerse: "",
                    jsonData: widget.suraJsonData,
                    pageNumber: pageNumber,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAyahResults() {
    final results = ayatFiltered["result"] as List;
    final count = results.length > 10 ? 10 : results.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'نتائج البحث في الآيات',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        ...List.generate(count, (index) => _buildAyahCard(results[index])),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAyahCard(Map<dynamic, dynamic> ayah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          "سورة ${getSurahNameArabic(ayah["surah"])} - ${getVerse(ayah["surah"], ayah["verse"], verseEndSymbol: true)}",
          textDirection: TextDirection.rtl,
          style: TextStyles.medium.copyWith(
            color: AppColors.secondaryColor,
            fontFamily: "DecoType-Thuluth2",
            height: 1.6,
          ),
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              ayah["verse"].toString(),
              style: TextStyles.regular.copyWith(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () {
          // Navigate to the specific ayah
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (builder) => QuranViewPage(
                    shouldHighlightText: true,
                    highlightVerse: "${ayah["surah"]}${ayah["verse"]}",
                    jsonData: widget.suraJsonData,
                    pageNumber: getPageNumber(ayah["surah"], ayah["verse"]),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'السور (${filteredData.length})',
              style: TextStyles.mediumBold.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
          ),
        ...List.generate(
          filteredData.length,
          (index) => _buildSurahCard(index),
        ),
      ],
    );
  }

  Widget _buildSurahCard(int index) {
    final sura = filteredData[index];
    final suraNumber = sura["number"];
    final suraName = sura["name"];
    final suraNameEnglish = sura["englishNameTranslation"];
    final ayahCount = getVerseCount(suraNumber);
    final revelationType =
        sura["revelationType"] == "Meccan" ? "مكية" : "مدنية";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (builder) => QuranViewPage(
                      shouldHighlightText: false,
                      highlightVerse: "",
                      jsonData: widget.suraJsonData,
                      pageNumber: getPageNumber(suraNumber, 1),
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Surah number circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.secondaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      suraNumber.toString(),
                      style: TextStyles.mediumBold.copyWith(
                        color: AppColors.secondaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Surah details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              suraName,
                              style: TextStyles.mediumBold.copyWith(
                                color: AppColors.secondaryColor,
                                fontSize: 18,
                                fontFamily: "DecoType-Thuluth2",
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    revelationType == "مكية"
                                        ? AppColors.secondaryColor.withOpacity(
                                          0.1,
                                        )
                                        : AppColors.primaryColor.withOpacity(
                                          0.1,
                                        ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                revelationType,
                                style: TextStyles.regular.copyWith(
                                  color:
                                      revelationType == "مكية"
                                          ? AppColors.secondaryColor
                                          : AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suraNameEnglish,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$ayahCount آية',
                        style: TextStyles.regular.copyWith(
                          color: AppColors.secondaryColor.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic name
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suraName,
                    style: const TextStyle(
                      fontFamily: "arsura",
                      fontSize: 20,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
