import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String icon;
  final Color color;
  final double size;

  const AvatarWidget({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}