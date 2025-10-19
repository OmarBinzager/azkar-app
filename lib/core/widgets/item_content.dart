import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ItemContent extends ConsumerWidget {
  final Content content;

  const ItemContent({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isHasMore =
        getLineCount(
          text: content.text,
          style: TextStyles.regular,
          maxWidth: MediaQuery.of(context).size.width,
        ) >=
        3;
    final favorite = ref.read(contentsListProvider.notifier);
    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.contentDetails, extra: content);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        padding: EdgeInsets.all(LayoutConstants.containerPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.text.trim(),
              style: TextStyles.regular,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder:
                  (context, setState) => Row(
                    children: [
                      Visibility(
                        visible: isHasMore,
                        child: Text(
                          'إضغط لقراءة المزيد',
                          style: TextStyle(color: AppColors.warring.shade600),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => onCopy(context),
                        child: Icon(
                          Icons.copy_all_outlined,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      content.isLiked
                          ? GestureDetector(
                            onTap: () async {
                              await favorite.changeStats(content.id, false);
                              content.isLiked = false;
                              setState(() {});
                            },
                            child: Icon(Icons.favorite, color: AppColors.error),
                          )
                          : GestureDetector(
                            onTap: () async {
                              await favorite.changeStats(content.id, true);
                              content.isLiked = true;
                              setState(() {});
                            },
                            child: Icon(
                              Icons.favorite_border,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onShare,
                        child: Icon(
                          Icons.share,
                          color: AppColors.secondaryColor,
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

  int getLineCount({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: null, // Allow unlimited lines
    );
    tp.layout(maxWidth: maxWidth);
    return tp.computeLineMetrics().length;
  }

  onShare() {
    String message = content.text;

    message +=
        '\n\n تمت مشاركة النص بواسطة تطبيق عمل اليوم والليلة\n'
        'URl in google ply';

    SharePlus.instance.share(ShareParams(text: message));
  }

  onCopy(BuildContext context) async {
    String message = content.text;

    message +=
        '\n\n تم نسخ النص بواسطة تطبيق عمل اليوم والليلة\n'
        'URl in google ply';

    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم نسخ النص')));
    }
  }
}
