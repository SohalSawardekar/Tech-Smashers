// ignore_for_file: file_names

class MatchModel {
  final String id;
  final String teamAId;
  final String teamBId;
  final int scoreTeamA;
  final int scoreTeamB;
  final bool isCompleted;

  MatchModel({
    required this.id,
    required this.teamAId,
    required this.teamBId,
    required this.scoreTeamA,
    required this.scoreTeamB,
    required this.isCompleted,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MatchModel(
      id: documentId,
      teamAId: map['teamAId'] ?? '',
      teamBId: map['teamBId'] ?? '',
      scoreTeamA: map['scoreTeamA'] ?? 0,
      scoreTeamB: map['scoreTeamB'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamAId': teamAId,
      'teamBId': teamBId,
      'scoreTeamA': scoreTeamA,
      'scoreTeamB': scoreTeamB,
      'isCompleted': isCompleted,
    };
  }
}
