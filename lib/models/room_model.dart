// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:yayscribbl/models/player_model.dart';

class RoomModel {
  String word;
  String roomName;
  int roomSize;
  int maxRounds;
  int currentRound;
  List<PlayerModel> players;
  bool canJoin;

  RoomModel({
    required this.word,
    required this.roomName,
    required this.roomSize,
    required this.maxRounds,
    required this.currentRound,
    required this.players,
    required this.canJoin,
  });

  RoomModel copyWith({
    String? word,
    String? roomName,
    int? roomSize,
    int? maxRounds,
    int? currentRound,
    List<PlayerModel>? players,
    bool? canJoin,
  }) {
    return RoomModel(
      word: word ?? this.word,
      roomName: roomName ?? this.roomName,
      roomSize: roomSize ?? this.roomSize,
      maxRounds: maxRounds ?? this.maxRounds,
      currentRound: currentRound ?? this.currentRound,
      players: players ?? this.players,
      canJoin: canJoin ?? this.canJoin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'word': word,
      'roomName': roomName,
      'roomSize': roomSize,
      'maxRounds': maxRounds,
      'currentRound': currentRound,
      'players': players.map((x) => x.toMap()).toList(),
      'canJoin': canJoin,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      word: map['word'] as String,
      roomName: map['roomName'] as String,
      roomSize: map['roomSize'] as int,
      maxRounds: map['maxRounds'] as int,
      currentRound: map['currentRound'] as int,
      players: List<PlayerModel>.from(
        (map['players'] as List<dynamic>).map<PlayerModel>(
          (x) => PlayerModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      canJoin: map['canJoin'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomModel(word: $word, roomName: $roomName, roomSize: $roomSize, maxRounds: $maxRounds, currentRound: $currentRound, players: $players, canJoin: $canJoin)';
  }

  @override
  bool operator ==(covariant RoomModel other) {
    if (identical(this, other)) return true;

    return other.word == word &&
        other.roomName == roomName &&
        other.roomSize == roomSize &&
        other.maxRounds == maxRounds &&
        other.currentRound == currentRound &&
        listEquals(other.players, players) &&
        other.canJoin == canJoin;
  }

  @override
  int get hashCode {
    return word.hashCode ^
        roomName.hashCode ^
        roomSize.hashCode ^
        maxRounds.hashCode ^
        currentRound.hashCode ^
        players.hashCode ^
        canJoin.hashCode;
  }
}
