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
  bool isJoin;
  int turnIndex;
  List<PlayerModel> players;
  PlayerModel turn;
  RoomModel({
    required this.word,
    required this.roomName,
    required this.roomSize,
    required this.maxRounds,
    required this.currentRound,
    required this.isJoin,
    required this.turnIndex,
    required this.players,
    required this.turn,
  });

  RoomModel copyWith({
    String? word,
    String? roomName,
    int? roomSize,
    int? maxRounds,
    int? currentRound,
    bool? isJoin,
    int? turnIndex,
    List<PlayerModel>? players,
    PlayerModel? turn,
  }) {
    return RoomModel(
      word: word ?? this.word,
      roomName: roomName ?? this.roomName,
      roomSize: roomSize ?? this.roomSize,
      maxRounds: maxRounds ?? this.maxRounds,
      currentRound: currentRound ?? this.currentRound,
      isJoin: isJoin ?? this.isJoin,
      turnIndex: turnIndex ?? this.turnIndex,
      players: players ?? this.players,
      turn: turn ?? this.turn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'word': word,
      'roomName': roomName,
      'roomSize': roomSize,
      'maxRounds': maxRounds,
      'currentRound': currentRound,
      'isJoin': isJoin,
      'turnIndex': turnIndex,
      'players': players.map((x) => x.toMap()).toList(),
      'turn': turn.toMap(),
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      word: map['word'] as String,
      roomName: map['roomName'] as String,
      roomSize: map['roomSize'] as int,
      maxRounds: map['maxRounds'] as int,
      currentRound: map['currentRound'] as int,
      isJoin: map['isJoin'] as bool,
      turnIndex: map['turnIndex'] as int,
      players: List<PlayerModel>.from((map['players'] as List<int>).map<PlayerModel>((x) => PlayerModel.fromMap(x as Map<String,dynamic>),),),
      turn: PlayerModel.fromMap(map['turn'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source) => RoomModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomModel(word: $word, roomName: $roomName, roomSize: $roomSize, maxRounds: $maxRounds, currentRound: $currentRound, isJoin: $isJoin, turnIndex: $turnIndex, players: $players, turn: $turn)';
  }

  @override
  bool operator ==(covariant RoomModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.word == word &&
      other.roomName == roomName &&
      other.roomSize == roomSize &&
      other.maxRounds == maxRounds &&
      other.currentRound == currentRound &&
      other.isJoin == isJoin &&
      other.turnIndex == turnIndex &&
      listEquals(other.players, players) &&
      other.turn == turn;
  }

  @override
  int get hashCode {
    return word.hashCode ^
      roomName.hashCode ^
      roomSize.hashCode ^
      maxRounds.hashCode ^
      currentRound.hashCode ^
      isJoin.hashCode ^
      turnIndex.hashCode ^
      players.hashCode ^
      turn.hashCode;
  }
}
