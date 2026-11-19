import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

class HeaderWidget extends StatelessWidget {
  final dynamic e;
  final dynamic jsonData;

  const HeaderWidget({
    super.key,
    required this.e,
    required this.jsonData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/888-02.png",
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "اياتها\n${getVerseCount(e["surah"])}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 7,
                    fontFamily: "UthmanicHafs13",
                    color: Colors.black87,
                  ),
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: e["surah"].toString(),
                      style: const TextStyle(
                        fontFamily: "arsura",
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  "ترتيبها\n${e["surah"]}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 7,
                    fontFamily: "UthmanicHafs13",
                    color: Colors.black87,
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
