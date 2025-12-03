import 'package:flutter/material.dart';

class ActionHintWidget extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const ActionHintWidget({
    super.key,
    required this.hintText,
    this.icon = Icons.info_outline_rounded,
    this.backgroundColor = const Color(0xFF272397),
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.onDismiss,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.1),
          border: Border.all(
            color: backgroundColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20.0,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 12.0,
                  color: textColor,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  color: iconColor,
                  size: 18.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}