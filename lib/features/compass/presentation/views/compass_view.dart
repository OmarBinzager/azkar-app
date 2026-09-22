import 'dart:async';
import 'dart:math' show atan2, cos, pi, sin, tan;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';

class CompassView extends StatefulWidget {
  const CompassView({super.key});

  @override
  State<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<CompassView>
    with SingleTickerProviderStateMixin {
  double? _heading;
  double? _qiblaDirection;
  Position? _userPosition;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Kaaba coordinates (Mecca)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    try {
      await _getUserLocation();
      _listenToCompass();
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تهيئة البوصلة: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'خدمة الموقع غير مفعلة. يرجى تفعيلها للمتابعة.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'تم رفض إذن الوصول للموقع.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من الإعدادات.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _userPosition = position;
        _qiblaDirection = _calculateQiblaDirection(
          position.latitude,
          position.longitude,
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في الحصول على الموقع: $e';
        _isLoading = false;
      });
    }
  }

  void _listenToCompass() {
    FlutterCompass.events?.listen(
      (CompassEvent event) {
        if (mounted) {
          setState(() {
            _heading = event.heading;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'البوصلة غير مدعومة على هذا الجهاز';
            _isLoading = false;
          });
        }
      },
    );
  }

  double _calculateQiblaDirection(double latitude, double longitude) {
    double lat1 = latitude * (math.pi / 180.0);
    double lon1 = longitude * (math.pi / 180.0);
    double lat2 = kaabaLatitude * (math.pi / 180.0);
    double lon2 = kaabaLongitude * (math.pi / 180.0);

    double dLon = lon2 - lon1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double qibla = math.atan2(y, x);
    qibla = qibla * (180.0 / math.pi);
    qibla = (qibla + 360.0) % 360.0;

    return qibla;
  }

  double? _calculateCompassAngle() {
    if (_heading == null || _qiblaDirection == null) return null;

    double direction = _qiblaDirection! - _heading!;
    return direction * (math.pi / 180.0) * -1;
  }

  String _getDirectionName(double degree) {
    if (degree >= 337.5 || degree < 22.5) return 'شمال';
    if (degree >= 22.5 && degree < 67.5) return 'شمال شرق';
    if (degree >= 67.5 && degree < 112.5) return 'شرق';
    if (degree >= 112.5 && degree < 157.5) return 'جنوب شرق';
    if (degree >= 157.5 && degree < 202.5) return 'جنوب';
    if (degree >= 202.5 && degree < 247.5) return 'جنوب غرب';
    if (degree >= 247.5 && degree < 292.5) return 'غرب';
    if (degree >= 292.5 && degree < 337.5) return 'شمال غرب';
    return 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    final angle = _calculateCompassAngle();

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'اتجاه القبلة',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.gold, size: 22.r),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeCompass();
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
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.compass_calibration,
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
            'جاري تحديد اتجاه القبلة...',
            style: TextStyles.mediumBold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى التأكد من تفعيل خدمة الموقع',
            style: TextStyles.regular.copyWith(
              color: Colors.grey[600],
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 36.r,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'حدث خطأ',
              style: TextStyles.bold.copyWith(
                color: AppColors.error,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? 'خطأ غير معروف',
              style: TextStyles.medium.copyWith(
                color: Colors.grey[600],
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeCompass();
              },
              icon: Icon(Icons.refresh, size: 18.r),
              label: Text('إعادة المحاولة', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.explore_off,
              color: AppColors.gold,
              size: 36.r,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'لا يمكن تحديد الاتجاه',
            style: TextStyles.bold.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تأكد من تفعيل البوصلة والموقع',
            style: TextStyles.medium.copyWith(
              color: Colors.grey[600],
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView(double angle) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
      child: Column(
        children: [
          _buildHeaderCard(),
          SizedBox(height: 20.h),
          _buildCompassCard(angle),
          SizedBox(height: 20.h),
          _buildInfoCards(),
          SizedBox(height: 24.h),
        ],
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
              Icons.compass_calibration,
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
                  'اتجاه القبلة',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تحديد اتجاه الكعبة المشرفة',
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

  Widget _buildCompassCard(double angle) {
    return Container(
      width: double.infinity,
      height: 280.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.MD,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background compass circle
          Container(
            width: 250.r,
            height: 250.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(125.r),
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
                    width: 220.r,
                    height: 220.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(110.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(110.r),
                      child: Image.asset(
                        PngAssets.compass,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(110.r),
                            ),
                            child: Icon(
                              Icons.compass_calibration,
                              color: AppColors.secondaryColor,
                              size: 80.r,
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
            width: 18.r,
            height: 18.r,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(9.r),
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
        SizedBox(height: 10.h),
        _buildInfoCard(
          icon: Icons.compass_calibration,
          title: 'اتجاه الجهاز',
          value: '${_heading?.toStringAsFixed(1)}°',
          subtitle: _getDirectionName(_heading ?? 0),
          color: AppColors.primaryColor,
        ),
        if (_userPosition != null) ...[
          SizedBox(height: 10.h),
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
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.SM,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.r),
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
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyles.bold.copyWith(color: color, fontSize: 16.sp),
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
    );
  }
}
