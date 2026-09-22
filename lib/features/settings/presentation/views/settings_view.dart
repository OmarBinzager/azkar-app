import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/services/isar_services.dart';
import 'package:new_azkar_app/core/services/settings_service.dart';
import 'package:new_azkar_app/core/providers/settings_provider.dart';
import 'package:new_azkar_app/core/providers/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/features/splash/views/splash_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView>
    with TickerProviderStateMixin {
  final IsarServices _isarServices = IsarServices();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final versionAsync = ref.watch(versionProvider);
    final dataUpdateState = ref.watch(dataUpdateProvider);

    if (settings.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.fourthColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings,
                  size: 36.r,
                  color: AppColors.secondaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'جاري تحميل الإعدادات...',
                style: TextStyles.medium.copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(LayoutConstants.screenPadding.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              SizedBox(height: 20.h),
              _buildSectionTitle('الصوت والوسائط'),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'تشغيل الصوت تلقائياً',
                subtitle: 'تشغيل الصوت عند فتح الأذكار',
                value: settings.autoPlayAudio,
                onChanged: (value) async {
                  await ref
                      .read(settingsProvider.notifier)
                      .setAutoPlayAudio(value);
                },
              ),
              SizedBox(height: 16.h),

              _buildSectionTitle('المظهر والخط'),
              _buildSliderTile(
                icon: Icons.text_fields,
                title: 'حجم الخط',
                subtitle: '${settings.fontSize.round()}',
                value: settings.fontSize,
                min: 22.0,
                max: 35.0,
                onChanged: (value) async {
                  await ref.read(settingsProvider.notifier).setFontSize(value);
                },
              ),
              SizedBox(height: 16.h),

              _buildSectionTitle('إدارة البيانات'),
              _buildActionTile(
                icon: Icons.library_music,
                title: 'التحميلات',
                subtitle: 'إدارة تنزيلات الملفات الصوتية',
                onTap: () {
                  context.pushNamed(Routes.downloads);
                },
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 12.h),
              _buildActionTile(
                icon: Icons.update,
                title: 'تحديث بيانات الأذكار',
                subtitle:
                    dataUpdateState.isLoading
                        ? 'جاري التحديث...'
                        : 'إعادة تهيئة بيانات التطبيق (يتم تلقائياً عند تحديث التطبيق)',
                onTap: _showUpdateDataDialog,
                color: AppColors.warring,
              ),
              SizedBox(height: 16.h),

              _buildSectionTitle('حول التطبيق'),
              versionAsync.when(
                data:
                    (version) => _buildInfoTile(
                      icon: Icons.info_outline,
                      title: 'إصدار التطبيق',
                      subtitle: version, // Real version from package_info_plus
                      color: AppColors.primaryColor,
                    ),
                loading:
                    () => _buildInfoTile(
                      icon: Icons.info_outline,
                      title: 'إصدار التطبيق',
                      subtitle: 'جاري التحميل...',
                      color: AppColors.primaryColor,
                    ),
                error:
                    (_, __) => _buildInfoTile(
                      icon: Icons.info_outline,
                      title: 'إصدار التطبيق',
                      subtitle: '1.4.0', // Fallback version
                      color: AppColors.primaryColor,
                    ),
              ),
              SizedBox(height: 12.h),
              _buildInfoTile(
                icon: Icons.share,
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق لتنفع غيرك',
                color: AppColors.primaryColor,
                onTap: onShare,
              ),
              SizedBox(height: 12.h),
              _buildInfoTile(
                icon: Icons.description_outlined,
                title: 'سياسة الخصوصية',
                subtitle: 'اقرأ سياسة الخصوصية',
                onTap: () {
                  // Navigate to privacy policy
                },
                color: AppColors.secondaryColor,
              ),
              SizedBox(height: 12.h),
              _buildInfoTile(
                icon: Icons.help_outline,
                title: 'المساعدة والدعم',
                subtitle: 'كيفية استخدام التطبيق',
                onTap: () {
                  // Navigate to help
                },
                color: AppColors.thirdColor,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      foregroundColor: AppColors.gold,
      elevation: 0,
      title: Text(
        'الإعدادات',
        style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
      ),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: CShadow.LG,
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.settings, color: AppColors.gold, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات التطبيق',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'خصص تجربتك في التطبيق',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, top: 6.h),
      child: Text(
        title,
        style: TextStyles.mediumBold.copyWith(
          color: AppColors.secondaryColor,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
          onTap: () => onChanged(!value),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.secondaryColor, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.secondaryColor,
                  activeTrackColor: AppColors.secondaryColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.secondaryColor, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.secondaryColor,
                inactiveTrackColor: AppColors.secondaryColor.withOpacity(0.2),
                thumbColor: AppColors.secondaryColor,
                overlayColor: AppColors.secondaryColor.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
                divisions: ((max - min) / 1).round(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'صغير',
                  style: TextStyles.regular.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  'كبير',
                  style: TextStyles.regular.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? AppColors.secondaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: tileColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: tileColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: tileColor, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? color,
  }) {
    final tileColor = color ?? AppColors.secondaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: tileColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: tileColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: tileColor, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
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

  void _showUpdateDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.warring.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: AppColors.warring,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'تحديث البيانات',
                  style: TextStyles.mediumBold.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم حذف جميع البيانات الحالية وإعادة إدخالها من جديد.\n\nملاحظة: يتم هذا التحديث تلقائياً عند تحديث التطبيق.\n\nهل أنت متأكد من المتابعة؟',
            style: TextStyles.regular.copyWith(
              color: Colors.grey[700],
              height: 1.4,
              fontSize: 13.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyles.medium.copyWith(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warring,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'تحديث',
                style: TextStyles.medium.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void onShare() {
    String message =
        '\n\n ✨ حمل تطبيق عمل اليوم والليلة الآن من متجر التطبيقات ✨\n تطبيق رائع ✨ يحتوي جميع اعمال وأدعية المسلم 🤲 في يومه وليلته, ايضاً يمكنك قراءة القرآن 📖 وتتبع أوقات الأذان 🕌. وأينما كنت يمكنك تحديد اتجاه القبلة 🧭. فقط حمله الآن 🔽🔽⏬🔽🔽!.\n\n'
        'https://play.google.com/store/apps/details?id=com.Letterspd.amal_alyoum';

    SharePlus.instance.share(ShareParams(text: message));
  }

  Future<void> _updateData() async {
    try {
      await ref.read(dataUpdateProvider.notifier).updateData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Text(
                  'تم تحديث البيانات بنجاح\ أعد تشغيل التطبيق...',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'حدث خطأ أثناء تحديث البيانات',
                style: TextStyles.medium.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
