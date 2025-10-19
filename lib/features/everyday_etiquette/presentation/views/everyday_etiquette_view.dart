import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/app_tile.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EverydayEtiquetteView extends ConsumerWidget {
  const EverydayEtiquetteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.read(headersProvider);
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'آداب يومية',
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
            _buildSectionTitle('آداب الاستيقاظ واللباس'),
            _buildEtiquetteCard(
              icon: Icons.wb_sunny,
              title: 'آداب الاستيقاظ',
              subtitle: 'أدعية وأذكار الاستيقاظ من النوم',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[64]),
            ),
            _buildEtiquetteCard(
              icon: Icons.checkroom,
              title: 'آداب لبس الثّوب',
              subtitle: 'أدعية وأذكار لبس الملابس',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[65]),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('آداب الطهارة'),
            _buildEtiquetteCard(
              icon: Icons.cleaning_services,
              title: 'آداب الطهارة',
              subtitle: 'أدعية الدخول والخروج من الخلاء والوضوء',
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'آداب الطهارة',
                      fromHeader: 66,
                      toHeader: 68,
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('آداب المسجد'),
            _buildEtiquetteCard(
              icon: Icons.mosque,
              title: 'آداب الخروج للمسجد',
              subtitle: 'أدعية الخروج والدخول للمسجد',
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'آداب الخروج للمسجد',
                      fromHeader: 69,
                      toHeader: 72,
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('آداب المنزل'),
            _buildEtiquetteCard(
              icon: Icons.home,
              title: 'دعاء الخروج من المنزل',
              subtitle: 'أدعية الخروج من المنزل',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[73]),
            ),
            _buildEtiquetteCard(
              icon: Icons.home_outlined,
              title: 'دعاء دخول المنزل',
              subtitle: 'أدعية دخول المنزل',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[74]),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('آداب الحياة اليومية'),
            _buildEtiquetteCard(
              icon: Icons.style,
              title: 'آداب خلع الثوب ولبسه',
              subtitle: 'أدعية خلع ولبس الملابس',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[75]),
            ),
            _buildEtiquetteCard(
              icon: Icons.restaurant,
              title: 'آداب الأكل',
              subtitle: 'أدعية وأذكار الطعام',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[76]),
            ),
            _buildEtiquetteCard(
              icon: Icons.meeting_room,
              title: 'دعاء مغادرة المجلس',
              subtitle: 'أدعية مغادرة المجالس',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[77]),
            ),
            _buildEtiquetteCard(
              icon: Icons.bedtime,
              title: 'آداب النّوم',
              subtitle: 'أدعية وأذكار النوم',
              onTap:
                  () => context.pushNamed(Routes.contents, extra: headers[78]),
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
            child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آداب يومية',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدعية وأذكار الحياة اليومية',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyles.mediumBold.copyWith(
          color: AppColors.secondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildEtiquetteCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.secondaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
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
}
