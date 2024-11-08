import 'package:flutter/material.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_container.dart';
import 'package:pantry_chef/core/presentation/widgets/shimmer_root.dart';

class ShimmerList extends StatelessWidget {
  final double cardHeight;

  const ShimmerList({
    super.key,
    this.cardHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerRoot(
      child: Column(
        children: [
          ShimmerContainer(height: cardHeight),
          const SizedBox(height: 12),
          ShimmerContainer(height: cardHeight),
          const SizedBox(height: 12),
          ShimmerContainer(height: cardHeight),
        ],
      ),
    );
  }
}
