// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PointModel {
  double dx;
  double dy;
  double sourceDrawingWidth;
  double sourceDrawingHeight;
  PointModel({
    required this.dx,
    required this.dy,
    required this.sourceDrawingWidth,
    required this.sourceDrawingHeight,
  });

  PointModel copyWith({
    double? dx,
    double? dy,
    double? sourceDrawingWidth,
    double? sourceDrawingHeight,
  }) {
    return PointModel(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      sourceDrawingWidth: sourceDrawingWidth ?? this.sourceDrawingWidth,
      sourceDrawingHeight: sourceDrawingHeight ?? this.sourceDrawingHeight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dx': dx,
      'dy': dy,
      'sourceDrawingWidth': sourceDrawingWidth,
      'sourceDrawingHeight': sourceDrawingHeight,
    };
  }

  factory PointModel.fromMap(Map<String, dynamic> map) {
    return PointModel(
      dx: map['dx'] as double,
      dy: map['dy'] as double,
      sourceDrawingWidth: map['sourceDrawingWidth'] as double,
      sourceDrawingHeight: map['sourceDrawingHeight'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory PointModel.fromJson(String source) =>
      PointModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PointModel(dx: $dx, dy: $dy, sourceDrawingWidth: $sourceDrawingWidth, sourceDrawingHeight: $sourceDrawingHeight)';
  }

  @override
  bool operator ==(covariant PointModel other) {
    if (identical(this, other)) return true;

    return other.dx == dx &&
        other.dy == dy &&
        other.sourceDrawingWidth == sourceDrawingWidth &&
        other.sourceDrawingHeight == sourceDrawingHeight;
  }

  @override
  int get hashCode {
    return dx.hashCode ^
        dy.hashCode ^
        sourceDrawingWidth.hashCode ^
        sourceDrawingHeight.hashCode;
  }
}
