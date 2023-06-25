import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yayscribbl/models/touch_points.dart';

class MyCustomPainter extends CustomPainter {
  List<TouchPoints?> pointsList;
  MyCustomPainter({required this.pointsList});
  // List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
    canvas.clipRect(rect);

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.point, pointsList[i + 1]!.point,
            pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        // offsetPoints.clear();
        // offsetPoints.add(pointsList[i].point);
        // offsetPoints.add(
        //     Offset(pointsList[i].point.dx + 0.1, pointsList[i].point.dy + 0.1));
        // canvas.drawPoints(
        //     ui.PointMode.points, offsetPoints, pointsList[i].paint);
        canvas.drawPoints(
            PointMode.points, [pointsList[i]!.point], pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return true;
  }
}
