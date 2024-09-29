import 'dart:ui';

import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  List<Path> paths;
  List<Paint> pathPaints;
  MyCustomPainter({required this.paths, required this.pathPaints});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], pathPaints[i]);
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) => true;
}
