import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/prayer_times/model/prayer_times_model.dart';
import 'package:new_azkar_app/features/prayer_times/presentation/widgets/prayer_time_card.dart';
import 'package:new_azkar_app/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PrayerTimesView extends ConsumerStatefulWidget {
  const PrayerTimesView({super.key});

  @override
  ConsumerState<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends ConsumerState<PrayerTimesView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimes = ref.watch(prayerTimesProvider);

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'أوقات الصلاة',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.gold, size: 22.r),
            onPressed: () => ref.refresh(prayerTimesProvider),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: prayerTimes.when(
        data: (data) => _buildPrayerTimesContent(context, data, ref),
        error: (error, stackTrace) => _buildErrorState(context, ref),
        loading: () => _buildLoadingState(),
      ),
    );
  }

  Widget _buildPrayerTimesContent(BuildContext context, PrayerTimesModel data, WidgetRef ref) {
    final now = DateTime.now();
    final nextPrayer = data.getNextPrayerInfo(now);

    return SingleChildScrollView(
      padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationCard(data),
          SizedBox(height: 16.h),
          _buildNextPrayerCard(nextPrayer, data),
          SizedBox(height: 20.h),
          _buildPrayerTimesGrid(data, nextPrayer),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PrayerTimesModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withOpacity(0.8),
          ],
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
            child: Icon(Icons.location_on, color: AppColors.gold, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقعك الحالي',
                  style: TextStyles.medium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  data.city ?? 'غير محدد',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 6.w,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMM yyyy,', 'ar').format(DateTime.now()),
                      style: TextStyles.regular.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                    if (data.hijriDate != null)
                      Text(
                        data.hijriDate!,
                        style: TextStyles.regular.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(Map<String, dynamic> nextPrayer, data) {
    if (nextPrayer.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.LG,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.access_time, color: AppColors.gold, size: 22.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: TextStyles.medium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      nextPrayer['name'] ?? '',
                      style: TextStyles.bold.copyWith(
                        color: Colors.white,
                        fontSize: 17.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الوقت المتبقي',
                style: TextStyles.medium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                ),
              ),
              Text(
                nextPrayer['timeRemaining'] ?? '',
                style: TextStyles.bold.copyWith(
                  color: AppColors.gold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesGrid(PrayerTimesModel data, Map<String, dynamic> nextPrayer) {
    final prayers = [
      {
        'name': 'الفجر',
        'time': data.fajrAsString.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.primaryColor,
        'isNext': nextPrayer['name'] == 'الفجر',
      },
      {
        'name': 'الشروق',
        'time': data.sunriseAsString!.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.warring,
        'isNext': nextPrayer['name'] == 'الشروق',
      },
      {
        'name': 'الظهر',
        'time': data.dhuhrAsString.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.warring,
        'isNext': nextPrayer['name'] == 'الظهر',
      },
      {
        'name': 'العصر',
        'time': data.asrAsString.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.warring,
        'isNext': nextPrayer['name'] == 'العصر',
      },
      {
        'name': 'المغرب',
        'time': data.maghribAsString.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.primaryColor,
        'isNext': nextPrayer['name'] == 'المغرب',
      },
      {
        'name': 'العشاء',
        'time': data.ishaAsString.replaceAll('AM', '').replaceAll('PM', ''),
        'icon': 'pray.svg',
        'color': AppColors.primaryColor,
        'isNext': nextPrayer['name'] == 'العشاء',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أوقات الصلاة',
          style: TextStyles.bold.copyWith(
            fontSize: 18.sp,
            color: AppColors.secondaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        ...prayers.map((prayer) => _buildPrayerCard(prayer)),
      ],
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border:
            prayer['isNext']
                ? Border.all(color: prayer['color'], width: 2)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: prayer['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.mosque, color: prayer['color'], size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prayer['name'],
                            style: TextStyles.mediumBold.copyWith(
                              color: AppColors.secondaryColor,
                              fontSize: 15.sp,
                            ),
                          ),
                          if (prayer['isNext']) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: prayer['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'القادمة',
                                style: TextStyles.regular.copyWith(
                                  color: prayer['color'],
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        prayer['time'],
                        style: TextStyles.bold.copyWith(
                          color: prayer['color'],
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.secondaryColor.withOpacity(0.6),
                  size: 15.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off, size: 45.r, color: AppColors.error),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا يمكن تحديد موقعك',
              style: TextStyles.bold.copyWith(
                fontSize: 18.sp,
                color: AppColors.secondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'قم بتفعيل خدمة الموقع في جهازك\nثم اضغط على تحديث',
              style: TextStyles.medium.copyWith(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(prayerTimesProvider),
              icon: Icon(Icons.refresh, size: 18.r),
              label: Text('تحديث', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.access_time,
              color: AppColors.secondaryColor,
              size: 36.r,
            ),
          ),
          SizedBox(height: 20.h),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل أوقات الصلاة...',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
