import 'dart:async';
import 'dart:math' show atan2, cos, pi, sin, tan;
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassView extends StatefulWidget {
  const CompassView({super.key});

  @override
  State<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<CompassView>
    with TickerProviderStateMixin {
  double? _qiblaDirection; // اتجاه القبلة بالدرجات
  double? _heading; // اتجاه الجهاز (البوصلة)
  bool _isLoading = true;
  String? _errorMessage;
  Position? _userPosition;

  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getUserLocation();
    _initializeCompass();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _initializeCompass() {
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _heading = event.heading;
          if (_isLoading && _qiblaDirection != null) {
            _isLoading = false;
          }
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'خطأ في البوصلة: $error';
          _isLoading = false;
        });
      },
    );

    // Handle case where compass events is null
    if (FlutterCompass.events == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'البوصلة غير متوفرة على هذا الجهاز';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'خدمة الموقع غير مفعلة';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'تم رفض إذن الموقع بشكل دائم';
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        setState(() {
          _userPosition = position;
        });
        _calculateQiblaDirection(position.latitude, position.longitude);
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'لم يتم منح إذن الموقع';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطأ في الحصول على الموقع: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateQiblaDirection(double lat, double lng) {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;

    double latRad = lat * pi / 180;
    double lngRad = lng * pi / 180;
    double kaabaLatRad = kaabaLat * pi / 180;
    double kaabaLngRad = kaabaLng * pi / 180;

    double deltaLng = kaabaLngRad - lngRad;

    double x = sin(deltaLng);
    double y = cos(latRad) * tan(kaabaLatRad) - sin(latRad) * cos(deltaLng);
    double qiblaDir = atan2(x, y) * 180 / pi;

    if (!mounted) return;
    setState(() {
      _qiblaDirection = (qiblaDir + 360) % 360;
      if (_heading != null) {
        _isLoading = false;
      }
    });
  }

  String _getDirectionName(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'شمال';
    if (degrees >= 22.5 && degrees < 67.5) return 'شمال شرق';
    if (degrees >= 67.5 && degrees < 112.5) return 'شرق';
    if (degrees >= 112.5 && degrees < 157.5) return 'جنوب شرق';
    if (degrees >= 157.5 && degrees < 202.5) return 'جنوب';
    if (degrees >= 202.5 && degrees < 247.5) return 'جنوب غرب';
    if (degrees >= 247.5 && degrees < 292.5) return 'غرب';
    if (degrees >= 292.5 && degrees < 337.5) return 'شمال غرب';
    return 'شمال';
  }

  @override
  Widget build(BuildContext context) {
    double? angle;
    if (_qiblaDirection != null && _heading != null) {
      angle = (_qiblaDirection! - _heading!) * (pi / 180);
    }

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'اتجاه القبلة',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _getUserLocation();
            },
          ),
        ],
      ),
      body: _buildBody(angle),
    );
  }

  Widget _buildBody(double? angle) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (angle == null) {
      return _buildNoDataState();
    }

    return _buildCompassView(angle);
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.compass_calibration,
              color: AppColors.secondaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحديد اتجاه القبلة...',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          CircularProgressIndicator(color: AppColors.secondaryColor),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'خطأ في تحديد الاتجاه',
              style: TextStyles.bold.copyWith(
                color: AppColors.secondaryColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: TextStyles.medium.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _getUserLocation();
              },
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
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

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.compass_calibration,
              color: AppColors.secondaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا يمكن تحديد الاتجاه',
            style: TextStyles.bold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'تأكد من تفعيل البوصلة والموقع',
            style: TextStyles.medium.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView(double angle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LayoutConstants.screenPadding),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 30),
          _buildCompassCard(angle),
          const SizedBox(height: 30),
          _buildInfoCards(),
        ],
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
            child: Icon(
              Icons.compass_calibration,
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
                  'اتجاه القبلة',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تحديد اتجاه الكعبة المشرفة',
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

  Widget _buildCompassCard(double angle) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.MD,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background compass
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(140),
              border: Border.all(
                color: AppColors.secondaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          // Rotating compass
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(125),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(125),
                      child: Image.asset(
                        PngAssets.compass,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(125),
                            ),
                            child: Icon(
                              Icons.compass_calibration,
                              color: AppColors.secondaryColor,
                              size: 100,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Center indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.navigation,
          title: 'اتجاه القبلة',
          value: '${_qiblaDirection?.toStringAsFixed(1)}°',
          subtitle: _getDirectionName(_qiblaDirection ?? 0),
          color: AppColors.secondaryColor,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.compass_calibration,
          title: 'اتجاه الجهاز',
          value: '${_heading?.toStringAsFixed(1)}°',
          subtitle: _getDirectionName(_heading ?? 0),
          color: AppColors.primaryColor,
        ),
        if (_userPosition != null) ...[
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'موقعك الحالي',
            value:
                '${_userPosition!.latitude.toStringAsFixed(4)}, ${_userPosition!.longitude.toStringAsFixed(4)}',
            subtitle: 'خط الطول والعرض',
            color: AppColors.thirdColor,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.SM,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
                  value,
                  style: TextStyles.bold.copyWith(color: color, fontSize: 18),
                ),
                Text(
                  subtitle,
                  style: TextStyles.regular.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
