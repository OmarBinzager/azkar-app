import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CSvgIcon extends StatelessWidget {
  const CSvgIcon({super.key, required this.icon, this.color, this.size});

  final String icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        icon,
        fit: size != null ? BoxFit.fill : BoxFit.none,
        // height: 24, width: 24,
        colorFilter: color != null ? ColorFilter.mode(
            color!, BlendMode.srcIn) : null,
      ),
    );
  }
}
