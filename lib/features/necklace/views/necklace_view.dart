import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/app_text_field.dart';
import 'package:new_azkar_app/features/necklace/provider/necklace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NecklaceView extends ConsumerStatefulWidget {
  const NecklaceView({super.key});

  @override
  ConsumerState<NecklaceView> createState() => _NecklaceViewState();
}

class _NecklaceViewState extends ConsumerState<NecklaceView>
    with TickerProviderStateMixin {
  late TextEditingController textEditingController;
  late FocusNode _focusNode;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: '100');
    _focusNode = FocusNode();

    // Animation for counter pulse effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation for necklace shake effect
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onCountTap() {
    HapticFeedback.lightImpact();
    ref.read(necklaceProvider.notifier).state++;
    _pulseController.forward().then((_) => _pulseController.reverse());
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _onReset() {
    HapticFeedback.mediumImpact();
    ref.read(necklaceProvider.notifier).state = 0;
  }

  void _resetCount() {
    textEditingController.text = '100';
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(necklaceProvider);
    final target = int.tryParse(textEditingController.text.trim()) ?? 100;
    final progress = target > 0 ? (counter / target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'السبحة الإلكترونية',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
          child: Column(
            children: [
              _buildTargetInput(),
              SizedBox(height: 20.h),
              _buildProgressCard(progress, counter, target),
              SizedBox(height: 20.h),
              _buildNecklaceSection(counter, target),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInput() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عدد التسبيح المطلوب',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  textInputType: TextInputType.number,
                  hintText: 'أدخل العدد المطلوب',
                  controller: textEditingController,
                  focusNode: _focusNode,
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: _resetCount,
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.restart_alt,
                    color: AppColors.primaryColor,
                    size: 22.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int counter, int target) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: TextStyles.mediumBold.copyWith(
                  color: AppColors.secondaryColor,
                  fontSize: 15.sp,
                ),
              ),
              Text(
                '$counter / $target',
                style: TextStyles.bold.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppColors.fourthColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    height: 10.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.gold],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10.h),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% مكتمل',
            style: TextStyles.medium.copyWith(
              color: Colors.grey[600],
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNecklaceSection(int counter, int target) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.LG,
      ),
      child: GestureDetector(
        onTap: counter < target ? _onCountTap : null,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          _shakeAnimation.value *
                          0.1 *
                          (counter % 2 == 0 ? 1 : -1),
                      child: Image.asset(
                        PngAssets.necklace,
                        height: 180.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180.h,
                            width: 180.h,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(90.r),
                            ),
                            child: Icon(
                              Icons.radio_button_checked,
                              color: AppColors.primaryColor,
                              size: 70.r,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 50.h,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(25.r),
                            boxShadow: CShadow.MD,
                          ),
                          child: Text(
                            counter.toString(),
                            style: TextStyles.heading1Bold.copyWith(
                              color: AppColors.gold,
                              fontSize: 26.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.restart_alt,
                  label: 'إعادة تعيين',
                  onTap: _onReset,
                  color: AppColors.warring,
                ),
                SizedBox(height: 10.h),
                Text(
                  'إضغط في اي مكان داخل هذا المربع للتسبيح.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                ),
              ],
            ),
            if (counter >= target) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.gold, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'تم إكمال العدد المطلوب!',
                      style: TextStyles.mediumBold.copyWith(
                        color: AppColors.gold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isEnabled ? CShadow.SM : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[600],
              size: 24.r,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyles.medium.copyWith(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
