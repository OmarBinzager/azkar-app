import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

import '../constants/layout_constants.dart';

extension ContextExtensions<T> on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  void push(Widget page) async {
    await Future.delayed(Duration.zero);
    await Navigator.of(
      this,
    ).push(MaterialPageRoute(builder: (context) => page));
  }

  void canPush(Widget page) async {
    Navigator.of(this).push(CupertinoPageRoute(builder: (context) => page));
  }

  /// This is to make the user not feel like navigating to new screen
  void pushWithoutTransition(Widget page) async {
    await Navigator.of(this).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void pushAndRemoveWithoutTransition(Widget page) async {
    await Navigator.of(this).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  void pushAndRemoveOthers(Widget page) async {
    await Future.delayed(Duration.zero);
    await Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  void pushReplacement(Widget page) async {
    await Future.delayed(Duration.zero);
    await Navigator.of(
      this,
    ).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  /// Pop the top-most route off the navigator that most tightly encloses the
  ///  given context.
  //void pop([T? result]) => Navigator.pop(this, result);

  void closeDrawer() => Scaffold.of(this).closeDrawer();

  // void showLoadingOverlay() async {
  //   await showDialog(
  //     context: this,
  //     builder: (context) {
  //       return const LoadingWidget();
  //     },
  //     barrierDismissible: false,
  //   );
  // }

  void showSnackbarError(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      _snackbarContent(
        backgroundColor: Colors.red,
        message: message,
        icon: Icons.info,
      ),
    );
  }

  void showSnackbarSuccess(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      _snackbarContent(
        backgroundColor: const Color.fromARGB(255, 27, 148, 92),
        message: message,
        icon: Icons.check_circle,
      ),
    );
  }

  SnackBar _snackbarContent({
    required Color backgroundColor,
    required String message,
    required IconData icon,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          Expanded(
            flex: 10,
            child: Text(
              message,
              style: theme.textTheme.labelMedium!.copyWith(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: Icon(icon, color: Colors.white)),
        ],
      ),
    );
  }

  Future<T?> showBottomSheet({
    required Widget sheet,
    bool isDismissible = true,
  }) {
    return _showBottomSheet(sheet, isDismissible);
  }

  Future<T?> _showBottomSheet(Widget child, bool isDismissible) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.9,
        minWidth: double.infinity,
      ),
      builder:
          (_) => PopScope(
            canPop: isDismissible,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                defaultBottomPaddingSize,
              ),
              child: child,
            ),
          ),
    );
  }

  Future<T?> showAlertDialog({
    bool barrierDismissible = true,
    required Widget child,
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'نافذة تنبية',
      pageBuilder:
          (context, animation, secondaryAnimation) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
              reverseCurve: Curves.easeIn,
            ),
            child: PopScope(
              canPop: barrierDismissible,
              child: Dialog(
                alignment: Alignment.center,
                insetAnimationCurve: Curves.easeInOut,
                child: Padding(padding: pgAllPadding24, child: child),
              ),
            ),
          ),
    );
  }

  double getResponsiveFontSize(double fontSize) {
    double screenWidth = MediaQuery.of(this).size.width;
    return screenWidth * (fontSize / 375); // 375 is the base width
  }
}

/// Styles partial text in a list of TextSpans by a regex pattern.
/// [spans]: The input list of TextSpans.
/// [pattern]: The regex pattern to match.
/// [matchStyle]: A function that takes a RegExpMatch and returns a TextStyle for the match.
/// [normalStyle]: The style for non-matching text.
List<TextSpan> styleTextByRegex({
  required List<TextSpan> spans,
  required RegExp pattern,
  TextStyle? matchStyle,
  TextStyle? normalStyle,
}) {
  final result = <TextSpan>[];

  for (final span in spans) {
    final text = span.text;
    final baseStyle = span.style ?? normalStyle;

    if (text == null) {
      result.add(span);
      continue;
    }

    int start = 0;
    for (final match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > start) {
        result.add(
          TextSpan(text: text.substring(start, match.start), style: baseStyle),
        );
      }
      // Add the matched text: if there is a capture group, use it (removes delimiters), else use the full match
      final matchText = match.groupCount > 0 ? match.group(1) : match.group(0);
      result.add(TextSpan(text: matchText, style: matchStyle ?? span.style));
      start = match.end;
    }
    // Add any remaining text after the last match
    if (start < text.length) {
      result.add(
        TextSpan(text: text.substring(start), style: baseStyle ?? span.style),
      );
    }
  }
  return result;
}

double adaptiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;

  // Scale factor based on a design width (e.g., 375 for iPhone X)
  double scaleFactor = screenWidth / 375.0;

  // Limit the scaling to avoid text being too small or too large
  double minScale = 0.8; // 80% of base size
  double maxScale = 1.2; // 120% of base size

  double adjustedScale = scaleFactor.clamp(minScale, maxScale);

  return baseFontSize * adjustedScale;
}

/// Styles text between double parentheses (( )) in a list of TextSpans, removing the parentheses and applying highlightedStyle to the inner text.
List<TextSpan> styleTextBetweenDoubleParentheses(
  List<TextSpan> spans, {
  TextStyle? normalStyle,
  TextStyle? highlightedStyle,
}) {
  final regex = RegExp(r'\(\((.+?)\)\)');
  final result = <TextSpan>[];

  for (final span in spans) {
    final text = span.text;
    if (text == null) {
      result.add(span);
      continue;
    }

    int start = 0;
    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > start) {
        result.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: span.style ?? normalStyle,
          ),
        );
      }
      // Add the matched inner text (without parentheses) with highlighted style
      result.add(
        TextSpan(text: match.group(1), style: highlightedStyle ?? span.style),
      );
      start = match.end;
    }
    // Add any remaining text after the last match
    if (start < text.length) {
      result.add(
        TextSpan(text: text.substring(start), style: span.style ?? normalStyle),
      );
    }
  }
  return result;
}
