// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PlayerModel {
  String nickName;
  String socketId;
  bool canMsg;
  int points;
  bool guessed;

  PlayerModel({
    required this.nickName,
    required this.socketId,
    required this.canMsg,
    required this.points,
    required this.guessed,
  });

  PlayerModel copyWith({
    String? nickName,
    String? socketId,
    bool? canMsg,
    int? points,
    bool? guessed,
  }) {
    return PlayerModel(
      nickName: nickName ?? this.nickName,
      socketId: socketId ?? this.socketId,
      canMsg: canMsg ?? this.canMsg,
      points: points ?? this.points,
      guessed: guessed ?? this.guessed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickName': nickName,
      'socketId': socketId,
      'canMsg': canMsg,
      'points': points,
      'guessed': guessed,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      nickName: map['nickName'] as String,
      socketId: map['socketId'] as String,
      canMsg: map['canMsg'] as bool,
      points: map['points'] as int,
      guessed: map['guessed'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerModel.fromJson(String source) =>
      PlayerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PlayerModel(nickName: $nickName, socketId: $socketId, canMsg: $canMsg, points: $points, guessed: $guessed)';
  }

  @override
  bool operator ==(covariant PlayerModel other) {
    if (identical(this, other)) return true;

    return other.nickName == nickName &&
        other.socketId == socketId &&
        other.canMsg == canMsg &&
        other.points == points &&
        other.guessed == guessed;
  }

  @override
  int get hashCode {
    return nickName.hashCode ^
        socketId.hashCode ^
        canMsg.hashCode ^
        points.hashCode ^
        guessed.hashCode;
  }
}
