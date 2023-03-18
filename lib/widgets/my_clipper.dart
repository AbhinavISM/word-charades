import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Rect> {
  double width;
  double height;

  MyClipper({required this.height, required this.width});
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width, height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
