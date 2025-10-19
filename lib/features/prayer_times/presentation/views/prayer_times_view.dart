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
  String _timeRemaining = '';

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
      setState(() {
        // Timer will update the countdown
      });
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
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () => ref.refresh(prayerTimesProvider),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
      padding: const EdgeInsets.all(LayoutConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationCard(data),
          const SizedBox(height: 20),
          _buildNextPrayerCard(nextPrayer, data),
          const SizedBox(height: 24),
          _buildPrayerTimesGrid(data, nextPrayer),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PrayerTimesModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.LG,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.location_on, color: AppColors.gold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقعك الحالي',
                  style: TextStyles.medium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.city ?? 'غير محدد',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat('EEEE, d MMM yyyy,', 'ar').format(DateTime.now()),
                      style: TextStyles.regular.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text(
                      data.hijriDate!,
                      style: TextStyles.regular.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.LG,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.access_time, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: TextStyles.medium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      nextPrayer['name'] ?? '',
                      style: TextStyles.bold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الوقت المتبقي',
                style: TextStyles.medium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                nextPrayer['timeRemaining'] ?? '',
                style: TextStyles.bold.copyWith(
                  color: AppColors.gold,
                  fontSize: 20,
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
            fontSize: 20,
            color: AppColors.secondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...prayers.map((prayer) => _buildPrayerCard(prayer)),
      ],
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border:
            prayer['isNext']
                ? Border.all(color: prayer['color'], width: 2)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Could add prayer-specific actions here
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: prayer['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.mosque, color: prayer['color'], size: 24),
                ),
                const SizedBox(width: 16),
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
                              fontSize: 16,
                            ),
                          ),
                          if (prayer['isNext']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: prayer['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'القادمة',
                                style: TextStyles.regular.copyWith(
                                  color: prayer['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prayer['time'],
                        style: TextStyles.bold.copyWith(
                          color: prayer['color'],
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.secondaryColor.withOpacity(0.6),
                  size: 16,
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
        padding: const EdgeInsets.all(LayoutConstants.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off, size: 60, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'لا يمكن تحديد موقعك',
              style: TextStyles.bold.copyWith(
                fontSize: 20,
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'قم بتفعيل خدمة الموقع في جهازك\nثم اضغط على تحديث',
              style: TextStyles.medium.copyWith(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(prayerTimesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              size: 40,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل أوقات الصلاة...',
            style: TextStyles.medium.copyWith(color: AppColors.secondaryColor),
          ),
        ],
      ),
    );
  }
}
