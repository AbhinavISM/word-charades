import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

class TouchPoints {
  Paint paint;
  Offset point;

  TouchPoints({required this.paint, required this.point});

  Map<String, dynamic> toJson() {
    return {
      'point': {'dx': '${point.dx}', 'dy': '${point.dy}'}
    };
  }
}
