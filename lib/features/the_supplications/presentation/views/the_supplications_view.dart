import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/app_tile.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_azkar_app/features/public/models/header_of_header_model.dart';

class TheSupplicationsView extends ConsumerWidget {
  const TheSupplicationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'الأذكار',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LayoutConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSupplicationCard(
              icon: Icons.auto_awesome,
              title: 'أذكار وأوراد اليومية',
              subtitle: 'أذكار وأوراد يومية متنوعة',
              color: AppColors.secondaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersOfHeadersViewer,
                    extra: HeaderOfHeaderModel(
                      label: 'أذكار وأوراد اليومية',
                      headers: [
                        HeaderModel(
                          label:
                              'أذكار وأوراد تقرأ صباحًا (من نصف  الليل إلى الزوال)',
                          headers: [93, 94, 95, 96, 97, 98, 110, 111, 112],
                        ),
                        HeaderModel(
                          label:
                              'أذكار وأوراد تقرأ مساء (من الزوال إلى نصف  الليل)',
                          headers: [
                            99,
                            100,
                            101,
                            102,
                            103,
                            104,
                            105,
                            110,
                            111,
                            112,
                            106,
                            107,
                            108,
                            109,
                          ],
                        ),
                        HeaderModel(
                          label: 'أذكار وأوراد تقرأ صباحًا أو مساء',
                          fromHeader: 113,
                          toHeader: 131,
                        ),
                      ],
                    ),
                  ),
            ),
            const SizedBox(height: 16),
            _buildSupplicationCard(
              icon: Icons.favorite,
              title: 'أذكار وأدعية خاصة',
              subtitle: 'أدعية خاصة لحالات مختلفة',
              color: AppColors.primaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'أذكار وأدعية خاصة',
                      fromHeader: 132,
                      toHeader: 150,
                    ),
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.thirdColor, AppColors.thirdColor.withOpacity(0.8)],
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
            child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأذكار',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أذكار وأوراد يومية وأدعية خاصة',
                  style: TextStyles.medium.copyWith(
                    color: Colors.white.withOpacity(0.8),
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

  Widget _buildSupplicationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyles.bold.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyles.medium.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward, color: color, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'عرض المحتوى',
                        style: TextStyles.medium.copyWith(
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
