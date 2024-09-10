import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String imageLink;
  final double radius;

  const CircularImage({
    super.key,
    required this.imageLink,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(
        imageLink,
      ),
    );
  }
}
