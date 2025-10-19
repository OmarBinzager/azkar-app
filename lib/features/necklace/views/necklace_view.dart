import 'package:flutter/services.dart';
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
  ConsumerState<ConsumerStatefulWidget> createState() => _NecklaceViewState();
}

class _NecklaceViewState extends ConsumerState<NecklaceView>
    with TickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController(
    text: '100',
  );
  late FocusNode _focusNode;

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _initializeAnimations();
    textEditingController.addListener(() {
      setState(() {});
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCountTap() {
    final counter = ref.read(necklaceProvider);
    final target = int.tryParse(textEditingController.text.trim()) ?? 100;

    if (counter < target) {
      HapticFeedback.vibrate();
      ref.read(necklaceProvider.notifier).state++;
      // Safe animation handling
      try {
        _pulseController.forward().then((_) => _pulseController.reverse());

        // Shake animation when reaching target
        if (counter + 1 == target) {
          _shakeController.forward().then((_) => _shakeController.reset());
        }
      } catch (e) {
        // Handle animation errors gracefully
        print('Animation error: $e');
      }
    }
  }

  void _onReset() {
    ref.read(necklaceProvider.notifier).state = 0;

    // Safe animation handling
    try {
      _shakeController.forward().then((_) => _shakeController.reset());
    } catch (e) {
      // Handle animation errors gracefully
      print('Reset animation error: $e');
    }
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
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside the input field
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LayoutConstants.screenPadding),
          child: Column(
            children: [
              // _buildHeaderCard(),
              // const SizedBox(height: 30),
              _buildTargetInput(),
              const SizedBox(height: 30),
              _buildProgressCard(progress, counter, target),
              const SizedBox(height: 30),
              _buildNecklaceSection(counter, target),
              const SizedBox(height: 32),
            ],
          ),
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
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
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
            child: Icon(
              Icons.radio_button_checked,
              color: AppColors.gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السبحة الإلكترونية',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عد الأذكار والتسبيح بسهولة',
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

  Widget _buildTargetInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عدد التسبيح المطلوب',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _resetCount,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restart_alt,
                    color: AppColors.primaryColor,
                    size: 24,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 16,
                ),
              ),
              Text(
                '$counter / $target',
                style: TextStyles.bold.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                width: (MediaQuery.of(context).size.width * .7),
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.fourthColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: (MediaQuery.of(context).size.width * .7) * progress,
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% مكتمل',
            style: TextStyles.medium.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNecklaceSection(int counter, int target) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.LG,
      ),
      child: GestureDetector(
        onTap: counter < target ? _onCountTap : null,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Necklace image
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
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.radio_button_checked,
                              color: AppColors.primaryColor,
                              size: 80,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                // Counter display
                Positioned(
                  top: 60,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: CShadow.MD,
                          ),
                          child: Text(
                            counter.toString(),
                            style: TextStyles.heading1Bold.copyWith(
                              color: AppColors.gold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Control buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.restart_alt,
                  label: 'إعادة تعيين',
                  onTap: _onReset,
                  color: AppColors.warring,
                ),
                SizedBox(height: 10),
                Text(
                  'إضغط في اي مكان داخل هذا المربع للتسبيح.',
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
            if (counter >= target) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'تم إكمال العدد المطلوب!',
                      style: TextStyles.mediumBold.copyWith(
                        color: AppColors.gold,
                        fontSize: 16,
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled ? CShadow.SM : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyles.medium.copyWith(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
