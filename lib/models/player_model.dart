// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PlayerModel {
  String nickName;
  String socketId;
  bool isRoomLeader;
  int points;

  PlayerModel({
    required this.nickName,
    required this.socketId,
    required this.isRoomLeader,
    required this.points,
  });

  PlayerModel copyWith({
    String? nickName,
    String? socketId,
    bool? isRoomLeader,
    int? points,
  }) {
    return PlayerModel(
      nickName: nickName ?? this.nickName,
      socketId: socketId ?? this.socketId,
      isRoomLeader: isRoomLeader ?? this.isRoomLeader,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickName': nickName,
      'socketId': socketId,
      'isRoomLeader': isRoomLeader,
      'points': points,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      nickName: map['nick_name'] as String,
      socketId: map['socket_id'] as String,
      isRoomLeader: map['is_room_leader'] as bool,
      points: map['points'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerModel.fromJson(String source) =>
      PlayerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PlayerModel(nickName: $nickName, socketId: $socketId, isRoomLeader: $isRoomLeader, points: $points)';
  }

  @override
  bool operator ==(covariant PlayerModel other) {
    if (identical(this, other)) return true;

    return other.nickName == nickName &&
        other.socketId == socketId &&
        other.isRoomLeader == isRoomLeader &&
        other.points == points;
  }

  @override
  int get hashCode {
    return nickName.hashCode ^
        socketId.hashCode ^
        isRoomLeader.hashCode ^
        points.hashCode;
  }
}
