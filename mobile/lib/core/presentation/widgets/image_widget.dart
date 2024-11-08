import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:pantry_chef/core/constants/icons.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit? fit;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      imageUrl: imageUrl,
      errorWidget: (context, url, error) {
        return DecoratedBox(
          decoration: BoxDecoration(color: context.theme.appColors.darkBeige),
          child: Center(
            child: Image.asset(IconsAsset.noImage, fit: fit),
          ),
        );
      },
    );
  }
}
