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
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
        keyboardType: TextInputType.text,
        controller: _searchController,
        focusNode: _searchFocusNode,
        textDirection: TextDirection.rtl,
        style: TextStyles.medium.copyWith(color: AppColors.secondaryColor),
        decoration: InputDecoration(
          hintText: 'ابحث في الأذكار والدعاء...',
          hintStyle: TextStyles.medium.copyWith(color: Colors.grey[400]),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryColor.withOpacity(0.6),
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.secondaryColor.withOpacity(0.6),
                    ),
                    onPressed: _clearSearch,
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

  Widget _buildSearchResults() {
    if (!_isSearching) {
      return _buildEmptyState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.screenPadding,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 60,
              color: AppColors.secondaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'البحث في الأذكار',
            style: TextStyles.bold.copyWith(
              fontSize: 20,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابحث في أسماء الأذكار أو محتواها\nللوصول السريع إلى ما تريد',
            style: TextStyles.medium.copyWith(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
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
                  size: 20,
                  color: AppColors.secondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'جرب البحث بكلمات مثل: الفجر، الاستغفار',
                  style: TextStyles.medium.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نتائج',
            style: TextStyles.bold.copyWith(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'جرب البحث بكلمات أخرى\nأو تحقق من الكتابة',
            style: TextStyles.medium.copyWith(
              fontSize: 16,
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
          onTap: () => _onResultTap(result),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            result.type == SearchResultType.header
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : AppColors.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.secondaryColor.withOpacity(0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.type == SearchResultType.header
                      ? result.header.name
                      : result.content!.text,
                  style: TextStyles.medium.copyWith(
                    color: AppColors.secondaryColor,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (result.type == SearchResultType.content) ...[
                  const SizedBox(height: 8),
                  Text(
                    'من: ${result.header.name}',
                    style: TextStyles.regular.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
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
