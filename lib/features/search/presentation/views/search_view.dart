import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/widgets/item_content.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;
  List<SearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _performSearch(String query) {
    final headers = ref.read(headersProvider);
    final contents = ref.read(contentsListProvider);

    List<SearchResult> results = [];

    // Search in headers
    for (final header in headers) {
      if (header.name.toLowerCase().contains(query.toLowerCase())) {
        results.add(
          SearchResult(
            type: SearchResultType.header,
            header: header,
            content: null,
            relevance: _calculateRelevance(header.name, query),
          ),
        );
      }
    }

    // Search in contents
    for (final content in contents) {
      if (content.text.toLowerCase().contains(query.toLowerCase())) {
        final header = headers.firstWhere(
          (h) => h.id == content.headerId,
          orElse: () => Header(0, ''),
        );

        results.add(
          SearchResult(
            type: SearchResultType.content,
            header: header,
            content: content,
            relevance: _calculateRelevance(content.text, query),
          ),
        );
      }
    }

    // Sort by relevance and remove duplicates
    results.sort((a, b) => b.relevance.compareTo(a.relevance));
    results = _removeDuplicateResults(results);

    setState(() {
      _searchResults = results;
    });
  }

  double _calculateRelevance(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    // Exact match gets highest score
    if (lowerText == lowerQuery) return 100.0;

    // Starts with query gets high score
    if (lowerText.startsWith(lowerQuery)) return 90.0;

    // Contains query gets medium score
    if (lowerText.contains(lowerQuery)) return 70.0;

    // Partial match gets lower score
    int matchCount = 0;
    for (final char in lowerQuery.split('')) {
      if (lowerText.contains(char)) matchCount++;
    }

    return (matchCount / lowerQuery.length) * 50.0;
  }

  List<SearchResult> _removeDuplicateResults(List<SearchResult> results) {
    final seen = <String>{};
    return results.where((result) {
      final key =
          result.type == SearchResultType.header
              ? 'header_${result.header.id}'
              : 'content_${result.content!.id}';

      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults.clear();
      _isSearching = false;
    });
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
          'البحث في الأذكار',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18.sp),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.all(LayoutConstants.screenPadding.r),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: _searchController,
        focusNode: _searchFocusNode,
        textDirection: TextDirection.rtl,
        style: TextStyles.medium.copyWith(color: AppColors.secondaryColor, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'ابحث في الأذكار والدعاء...',
          hintStyle: TextStyles.medium.copyWith(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryColor.withOpacity(0.6),
            size: 22.r,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.secondaryColor.withOpacity(0.6),
                      size: 20.r,
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 10.h,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching) {
      return _buildEmptyState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutConstants.screenPadding.r,
        vertical: 8.h,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 45.r,
                color: AppColors.secondaryColor.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'البحث في الأذكار',
              style: TextStyles.bold.copyWith(
                fontSize: 18.sp,
                color: AppColors.secondaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'ابحث في أسماء الأذكار أو محتواها\nللوصول السريع إلى ما تريد',
                style: TextStyles.medium.copyWith(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18.r,
                    color: AppColors.secondaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'جرب البحث بكلمات مثل: الفجر، الاستغفار',
                    style: TextStyles.medium.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 40.r, color: Colors.grey[400]),
          ),
          SizedBox(height: 18.h),
          Text(
            'لا توجد نتائج',
            style: TextStyles.bold.copyWith(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جرب البحث بكلمات أخرى\nأو تحقق من الكتابة',
            style: TextStyles.medium.copyWith(
              fontSize: 13.sp,
              color: Colors.grey[500],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _onResultTap(result),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            result.type == SearchResultType.header
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : AppColors.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        result.type == SearchResultType.header
                            ? 'عنوان'
                            : 'محتوى',
                        style: TextStyles.regular.copyWith(
                          color:
                              result.type == SearchResultType.header
                                  ? AppColors.primaryColor
                                  : AppColors.secondaryColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.r,
                      color: AppColors.secondaryColor.withOpacity(0.6),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  result.type == SearchResultType.header
                      ? result.header.name
                      : result.content!.text,
                  style: TextStyles.medium.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (result.type == SearchResultType.content) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'من: ${result.header.name}',
                    style: TextStyles.regular.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onResultTap(SearchResult result) {
    if (result.type == SearchResultType.header) {
      // Navigate to header contents
      context.pushNamed(Routes.contents, extra: result.header);
    } else {
      // Navigate to content details
      context.pushNamed(Routes.contents, extra: result.header);
    }
  }
}

enum SearchResultType { header, content }

class SearchResult {
  final SearchResultType type;
  final Header header;
  final Content? content;
  final double relevance;

  SearchResult({
    required this.type,
    required this.header,
    this.content,
    required this.relevance,
  });
}
