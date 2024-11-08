import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerContainer({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.theme.appColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
