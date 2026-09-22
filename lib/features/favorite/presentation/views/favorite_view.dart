import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/favorite/providers/favorite_provider.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteView extends ConsumerWidget {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Header> favoriteHeaders = ref.watch(favoriteHeaderProvider);

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'المفضلة',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(favoriteHeaders.length),
            SizedBox(height: 20.h),
            favoriteHeaders.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(favoriteHeaders, context),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int favoritesCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.LG,
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: AppColors.gold,
              size: 26.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المفضلة',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  favoritesCount == 0
                      ? 'لا توجد نصوص في المفضلة'
                      : '$favoritesCount نص مفضل',
                  style: TextStyles.medium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.error.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 40.r,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'لا توجد مفضلات',
            style: TextStyles.bold.copyWith(
              fontSize: 18.sp,
              color: AppColors.secondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اضغط على أيقونة القلب في أي نص لإضافته إلى المفضلة',
            style: TextStyles.medium.copyWith(
              fontSize: 13.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: AppColors.error.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, size: 16.r, color: AppColors.error),
                SizedBox(width: 8.w),
                Text(
                  'ابدأ بإضافة نصوصك المفضلة',
                  style: TextStyles.medium.copyWith(
                    color: AppColors.error,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    List<Header> favoriteHeaders,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${favoriteHeaders.length} مفضل',
          style: TextStyles.medium.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        ...favoriteHeaders.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildFavoriteCard(context, header, index),
          );
        }),
      ],
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Header header, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.error.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => context.pushNamed(Routes.contents, extra: header),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyles.mediumBold.copyWith(
                        color: AppColors.error,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 14.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.name,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'نص مفضل',
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.error,
                    size: 14.r,
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
