// ignore_for_file: file_names

class MatchModel {
  final String id;
  final num matchNo;
  final String teamAId;
  final String teamBId;
  final String teamAPlayer;
  final String teamBPlayer;
  final bool isCompleted;

  MatchModel({
    required this.id,
    required this.matchNo,
    required this.teamAId,
    required this.teamBId,
    required this.teamAPlayer,
    required this.teamBPlayer,
    required this.isCompleted,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MatchModel(
      id: documentId,
      matchNo: map['matchNo'],
      teamAId: map['teamAId'] ?? '',
      teamBId: map['teamBId'] ?? '',
      teamAPlayer: map['teamAPlayer'] ?? 0,
      teamBPlayer: map['teamBPlayer'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchNo': matchNo,
      'teamAId': teamAId,
      'teamBId': teamBId,
      'teamAPlayer': teamAPlayer,
      'teamBPlayer': teamBPlayer,
      'isCompleted': isCompleted,
    };
  }
}
