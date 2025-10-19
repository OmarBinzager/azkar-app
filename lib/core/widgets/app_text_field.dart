import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.optional = true,
    this.maxLines = 1,
    this.suffix,
    this.icon,
    this.onTap,
    this.shadowEnabled = true,
    this.textInputType,
    this.fillColor,
    this.textInputFormatters = const [],
    this.focusNode,
  });

  final String hintText;
  final String? label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final String? icon;
  final bool readOnly;
  final bool optional;
  final Widget? suffix;
  final TextInputType? textInputType;
  final VoidCallback? onTap;
  final bool shadowEnabled;
  final List<TextInputFormatter> textInputFormatters;
  final Color? fillColor;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool isObscuredEnabled;

  @override
  void initState() {
    isObscuredEnabled = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          style: TextStyles.medium,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          validator: widget.validator,
          maxLines: widget.maxLines,
          controller: widget.controller,
          obscureText: isObscuredEnabled,
          keyboardType: widget.textInputType,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            suffix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget.suffix,
            ),
            fillColor: widget.fillColor ?? Colors.white,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyles.medium.copyWith(
              color: AppColors.neutral[400],
            ),
            contentPadding: const EdgeInsetsDirectional.only(
              top: 15,
              start: 10,
              bottom: 15,
            ),
            prefixIcon:
                widget.icon == null
                    ? null
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 15,
                      ),
                      child: SvgPicture.asset(widget.icon!),
                    ),
            prefixIconConstraints: const BoxConstraints(maxWidth: 60),
            suffixIcon:
                widget.obscureText
                    ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isObscuredEnabled = !isObscuredEnabled;
                        });
                      },
                      child: Icon(
                        isObscuredEnabled
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: context.theme.colorScheme.primary,
                      ),
                    )
                    : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.neutral[300]!),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputFormatters: widget.textInputFormatters,
        ),
      ],
    );
  }
}
