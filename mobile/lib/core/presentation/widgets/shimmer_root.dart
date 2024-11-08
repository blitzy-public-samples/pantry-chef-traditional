import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRoot extends StatelessWidget {
  final Widget child;

  const ShimmerRoot({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.appColors.darkBeige,
      highlightColor: context.theme.appColors.lightGrey,
      child: child,
    );
  }
}
