// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PlayerModel {
  String nickName;
  String socketID;
  bool isPartyLeader;
  int points;
  PlayerModel({
    required this.nickName,
    required this.socketID,
    required this.isPartyLeader,
    required this.points,
  });

  PlayerModel copyWith({
    String? nickName,
    String? socketID,
    bool? isPartyLeader,
    int? points,
  }) {
    return PlayerModel(
      nickName: nickName ?? this.nickName,
      socketID: socketID ?? this.socketID,
      isPartyLeader: isPartyLeader ?? this.isPartyLeader,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickName': nickName,
      'socketID': socketID,
      'isPartyLeader': isPartyLeader,
      'points': points,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      nickName: map['nickName'] as String,
      socketID: map['socketID'] as String,
      isPartyLeader: map['isPartyLeader'] as bool,
      points: map['points'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerModel.fromJson(String source) =>
      PlayerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PlayerModel(nickName: $nickName, socketID: $socketID, isPartyLeader: $isPartyLeader, points: $points)';
  }

  @override
  bool operator ==(covariant PlayerModel other) {
    if (identical(this, other)) return true;

    return other.nickName == nickName &&
        other.socketID == socketID &&
        other.isPartyLeader == isPartyLeader &&
        other.points == points;
  }

  @override
  int get hashCode {
    return nickName.hashCode ^
        socketID.hashCode ^
        isPartyLeader.hashCode ^
        points.hashCode;
  }
}
