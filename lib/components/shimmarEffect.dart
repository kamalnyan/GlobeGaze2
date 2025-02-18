import 'package:flutter/material.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(
      baseColor: isDarkMode(context) ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode(context)  ? Colors.grey[600]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDarkMode(context)  ? Colors.black : Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
