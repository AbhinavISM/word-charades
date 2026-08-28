// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RoundModel {
  int turnIndex;
  int guessCnt;
  int startTime;
  RoundModel({
    required this.turnIndex,
    required this.guessCnt,
    required this.startTime,
  });

  RoundModel copyWith({
    int? turnIndex,
    int? guessCnt,
    int? startTime,
  }) {
    return RoundModel(
      turnIndex: turnIndex ?? this.turnIndex,
      guessCnt: guessCnt ?? this.guessCnt,
      startTime: startTime ?? this.startTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'turnIndex': turnIndex,
      'guessCnt': guessCnt,
      'startTime': startTime,
    };
  }

  factory RoundModel.fromMap(Map<String, dynamic> map) {
    return RoundModel(
      turnIndex: map['turnIndex'] as int,
      guessCnt: map['guessCnt'] as int,
      startTime: map['startTime'].toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoundModel.fromJson(String source) =>
      RoundModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'RoundModel(turnIndex: $turnIndex, guessCnt: $guessCnt, startTime: $startTime)';

  @override
  bool operator ==(covariant RoundModel other) {
    if (identical(this, other)) return true;

    return other.turnIndex == turnIndex &&
        other.guessCnt == guessCnt &&
        other.startTime == startTime;
  }

  @override
  int get hashCode =>
      turnIndex.hashCode ^ guessCnt.hashCode ^ startTime.hashCode;
}
