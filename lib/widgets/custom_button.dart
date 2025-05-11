import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double width;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = 55,
    this.width = double.infinity,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: isFullWidth ? width : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined
                  ? Colors.transparent
                  : (backgroundColor ?? AppTheme.primaryColor),
          foregroundColor:
              textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white),
          elevation: isOutlined ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isOutlined
                    ? BorderSide(
                      color: backgroundColor ?? AppTheme.primaryColor,
                      width: 1.5,
                    )
                    : BorderSide.none,
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: isOutlined ? AppTheme.primaryColor : Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
