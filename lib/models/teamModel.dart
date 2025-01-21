// ignore_for_file: file_names

class TeamModel {
  final String id;
  final String name;
  final List<String> members; // list of user uids, for example
  final String? createdBy; // optional: who created this team

  TeamModel({
    required this.id,
    required this.name,
    required this.members,
    this.createdBy,
  });

  factory TeamModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TeamModel(
      id: documentId,
      name: map['name'] ?? '',
      members: map['members'] == null
          ? []
          : List<String>.from(map['members'] as List),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'createdBy': createdBy,
    };
  }
}
