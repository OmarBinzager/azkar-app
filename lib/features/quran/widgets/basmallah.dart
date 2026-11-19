import 'package:flutter/material.dart';

class Basmallah extends StatelessWidget {
  final int index;
  const Basmallah({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      alignment: Alignment.center,
      child: Image.asset(
        "assets/images/Basmala.png",
        color: Colors.black87,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }
}
