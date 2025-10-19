import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/extensions/context_extensions.dart';
import 'package:new_azkar_app/core/widgets/svg_icon.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/home/presentation/widgets/fast_access_card.dart';
import 'package:new_azkar_app/features/home/presentation/widgets/item_card.dart';
import 'package:new_azkar_app/features/home/presentation/widgets/second_item_card.dart';
import 'package:new_azkar_app/features/home/providers/fast_access_list_provider.dart';
import 'package:new_azkar_app/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:new_azkar_app/features/prayer_times/model/prayer_times_model.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilNextPrayer = Duration.zero;
  String _nextPrayerName = '';
  DateTime? _nextPrayerTime;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double spacing = 14;
    final headers = ref.read(headersProvider);
    ref.read(contentsListProvider);
    final prayerTimes = ref.watch(prayerTimesProvider);

    return Scaffold(
      // Remove backgroundColor here!
      backgroundColor: AppColors.fourthColor,
      body:
      // 3. Main content
      SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section with Top Bar (as before)
            SliverToBoxAdapter(child: _buildHeaderSection(spacing)),
            // Hero Section with Prayer Times
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 8,
                  top: 10,
                ),
                child: _buildHeroSection(),
              ),
            ),
            // Main Content Section (Main Features)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'الأقسام الرئيسية',
                    //   style: TextStyles.bold.copyWith(
                    //     color: AppColors.success[900],
                    //     fontSize: 22,
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    _buildMainCardsGrid(spacing),
                  ],
                ),
              ),
            ),
            // Secondary Tools Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: _buildSecondaryCards(spacing),
              ),
            ),
            // Footer/Branding
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Center(
                  child: Text(
                    'حُرُوْفْ',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'DecoTypeThuluthII',
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor.withOpacity(.9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- New AppBar with centered title/logo and action icons ---
  Widget _buildHeaderSection(double spacing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Action Icons
          _buildIconButton(
            icon: SvgAssets.favorite,
            onTap: () => context.pushNamed(Routes.favorite),
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.search,
                onTap: () => context.pushNamed(Routes.search),
                isIcon: true,
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: SvgAssets.settings,
                onTap: () => context.pushNamed(Routes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Hero Section with Prayer Times ---
  Widget _buildHeroSection() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryColor, AppColors.primaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative Images
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              PngAssets.mosques,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      GlobalStrings.bookTitle,
                      style: TextStyles.bigSplashFont.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 42,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Prayer Time Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_buildPrayerTimeInfo(), _buildCityInfo()],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeInfo() {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return prayerTimesAsync.when(
      data: (data) {
        // Start the countdown if not already started or if next prayer changed
        if (_nextPrayerTime == null ||
            _nextPrayerName != data.getNextPrayerInfo(DateTime.now())['name']) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startCountdown(data);
          });
        }

        String countdownText = _formatDuration(_timeUntilNextPrayer);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_nextPrayerName} بعد',
              style: TextStyles.medium.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countdownText,
              style: TextStyles.medium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        );
      },
      error:
          (error, stackTrace) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أوقات الصلاة',
                style: TextStyles.bold.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                'غير متوفرة',
                style: TextStyles.medium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
      loading:
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جاري التحميل...',
                style: TextStyles.bold.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCityInfo() {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return prayerTimesAsync.when(
      data:
          (data) => Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                data.city ?? '',
                style: TextStyles.medium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
            ],
          ),
      error:
          (error, stackTrace) => Text(
            'موقع غير معروف',
            style: TextStyles.medium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
      loading:
          () => Text(
            '...',
            style: TextStyles.medium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
    );
  }

  Widget _buildIconButton({
    required dynamic icon,
    required VoidCallback onTap,
    bool isIcon = false,
    int? badge,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child:
                    isIcon
                        ? Icon(icon, size: 24, color: AppColors.secondaryColor)
                        : CSvgIcon(
                          icon: icon,
                          size: 24,
                          color: AppColors.secondaryColor,
                        ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- Improved Fast Access Section: horizontal scroll, add button at end ---
  // All fast access section, add button, item, and related methods are removed.

  // --- More visually distinct Add button for Fast Access ---
  // All fast access section, add button, item, and related methods are removed.

  // --- Restructured main features: first 4 as grid, last 3 as list ---
  Widget _buildMainCardsGrid(double spacing) {
    final mainFeatures = [
      {
        'label': 'القرآن الكريم',
        'icon': Icons.menu_book,
        'onTap': () => context.pushNamed(Routes.quran),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'الصلوات',
        'icon': Icons.mosque,
        'onTap': () => context.pushNamed(Routes.prayers),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'الأذكار',
        'icon': FontAwesomeIcons.handsPraying,
        'onTap': () => context.pushNamed(Routes.theSupplications),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'آداب يومية',
        'icon': Icons.auto_stories,
        'onTap': () => context.pushNamed(Routes.everydayEtiquette),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'نصائح وآداب عامة',
        'icon': FontAwesomeIcons.handHoldingHeart,
        'onTap': () => context.pushNamed(Routes.tipsAndEtiquette),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'دَلَائِلُ الخَيْرَاتِ',
        'icon': FontAwesomeIcons.handHoldingHand,
        'onTap':
            () => context.pushNamed(
              Routes.headersViewer,
              extra: HeaderModel(
                fromHeader: 82,
                toHeader: 92,
                label: 'دَلَائِلُ الخَيْرَاتِ وَشَوَارِقُ الأَنوَار',
              ),
            ),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
      {
        'label': 'ليلة الجمعة ويومها',
        'icon': Icons.weekend,
        'onTap': () => context.pushNamed(Routes.fridayNight),
        'gradient': [AppColors.secondaryColor, AppColors.primaryColor],
      },
    ];
    // First 4 as grid
    final gridFeatures = mainFeatures.take(4).toList();
    // Last 3 as list
    final listFeatures = mainFeatures.skip(4).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 2.5 / 1.3,
          ),
          itemCount: gridFeatures.length,
          itemBuilder: (context, index) {
            final feature = gridFeatures[index];
            return _buildMainCard(
              label: feature['label'] as String,
              icon: feature['icon'] as IconData,
              onTap: feature['onTap'] as VoidCallback,
              gradient: feature['gradient'] as List<Color>,
            );
          },
        ),
        SizedBox(height: spacing),
        // Last 3 as full-width list
        Column(
          children: [
            for (final feature in listFeatures) ...[
              _buildMainCard(
                label: feature['label'] as String,
                icon: feature['icon'] as IconData,
                onTap: feature['onTap'] as VoidCallback,
                gradient: feature['gradient'] as List<Color>,
                isFullWidth: true,
              ),
              SizedBox(height: spacing),
            ],
          ],
        ),
      ],
    );
  }

  // --- Add subtle elevation/shadow and ripple to all cards ---
  Widget _buildMainCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    List<Color>? gradient,
    bool isFullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          // height: 80,
          decoration: BoxDecoration(
            gradient:
                gradient != null
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    )
                    : null,
            color:
                gradient == null
                    ? AppColors.secondaryColor.withOpacity(0.92)
                    : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (gradient != null
                        ? gradient.first
                        : AppColors.secondaryColor)
                    .withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative small spots
              Positioned(
                top: 10,
                left: 14,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 28,
                left: 36,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 18,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Main card content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: adaptiveFontSize(context, 16),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCards(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSecondaryCard(
              label: 'أوقات الأذان',
              icon: Icons.access_time,
              onTap: () => context.pushNamed(Routes.prayerTimes),
            ),
            _buildSecondaryCard(
              label: 'السبحة',
              icon: Icons.circle,
              onTap: () => context.pushNamed(Routes.necklace),
            ),
            _buildSecondaryCard(
              label: 'إتجاه القبلة',
              icon: Icons.explore,
              onTap: () => context.pushNamed(Routes.compass),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 85,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyles.regular.copyWith(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // All fast access section, add button, item, and related methods are removed.

  void _startCountdown(PrayerTimesModel data) {
    final now = DateTime.now();
    final nextPrayerInfo = data.getNextPrayerInfo(now);
    _nextPrayerName = nextPrayerInfo['name'] ?? '';
    _nextPrayerTime = nextPrayerInfo['time'] as DateTime?;

    _updateCountdown();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    if (_nextPrayerTime == null) return;
    final now = DateTime.now();
    setState(() {
      _timeUntilNextPrayer = _nextPrayerTime!.difference(now);
      if (_timeUntilNextPrayer.isNegative) {
        _timeUntilNextPrayer = Duration.zero;
        // Optionally, trigger a refresh of prayer times here
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) =>
        n.toString().padLeft(2, '0').startsWith('0')
            ? n.toString().padLeft(1, '0')
            : n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hoursس $minutesد $secondsث';
  }

  // Helper to build a blurred gradient circle
  Widget _buildGradientCircle(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
