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
  PlayerModel turn;
  int turnIndex;

  RoomModel({
    required this.word,
    required this.roomName,
    required this.roomSize,
    required this.maxRounds,
    required this.currentRound,
    required this.players,
    required this.canJoin,
    required this.turn,
    required this.turnIndex,
  });

  RoomModel copyWith({
    String? word,
    String? roomName,
    int? roomSize,
    int? maxRounds,
    int? currentRound,
    List<PlayerModel>? players,
    bool? canJoin,
    PlayerModel? turn,
    int? turnIndex,
  }) {
    return RoomModel(
      word: word ?? this.word,
      roomName: roomName ?? this.roomName,
      roomSize: roomSize ?? this.roomSize,
      maxRounds: maxRounds ?? this.maxRounds,
      currentRound: currentRound ?? this.currentRound,
      players: players ?? this.players,
      canJoin: canJoin ?? this.canJoin,
      turn: turn ?? this.turn,
      turnIndex: turnIndex ?? this.turnIndex,
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
      'turn': turn.toMap(),
      'turnIndex': turnIndex,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      word: map['word'] as String,
      roomName: map['room_name'] as String,
      roomSize: map['room_size'] as int,
      maxRounds: map['max_rounds'] as int,
      currentRound: map['current_round'] as int,
      players: List<PlayerModel>.from(
        (map['players'] as List<dynamic>).map<PlayerModel>(
          (x) => PlayerModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      canJoin: map['can_join'],
      turn: PlayerModel.fromMap(map['turn'] as Map<String, dynamic>),
      turnIndex: map['turn_index'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomModel(word: $word, roomName: $roomName, roomSize: $roomSize, maxRounds: $maxRounds, currentRound: $currentRound, players: $players, canJoin: $canJoin, turn: $turn, turnIndex: $turnIndex)';
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
        other.canJoin == canJoin &&
        other.turn == turn &&
        other.turnIndex == turnIndex;
  }

  @override
  int get hashCode {
    return word.hashCode ^
        roomName.hashCode ^
        roomSize.hashCode ^
        maxRounds.hashCode ^
        currentRound.hashCode ^
        players.hashCode ^
        canJoin.hashCode ^
        turn.hashCode ^
        turnIndex.hashCode;
  }
}
