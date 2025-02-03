// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLeaderboardPage extends StatefulWidget {
  const AdminLeaderboardPage({super.key});

  @override
  State<AdminLeaderboardPage> createState() => _AdminLeaderboardPageState();
}

class _AdminLeaderboardPageState extends State<AdminLeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  List<Team> teams = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _winsController = TextEditingController();
  final TextEditingController _lossesController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _aggregateScoreController =
      TextEditingController();

  Team? _selectedTeam; // For editing

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final snapshot = await _firestore.collection('leaderboard').get();
      setState(() {
        teams = snapshot.docs
            .map((doc) =>
                Team.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Sort: First by `score` (desc), then by `aggregateScore` (desc)
        teams.sort((a, b) {
          if (b.score != a.score) {
            return b.score.compareTo(a.score); // Sort by score descending
          }
          return b.aggregateScore.compareTo(
              a.aggregateScore); // Sort by aggregate score descending
        });
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      final teamData = {
        'name': _nameController.text.trim(),
        'wins': int.tryParse(_winsController.text) ?? 0,
        'losses': int.tryParse(_lossesController.text) ?? 0,
        'score': int.tryParse(_scoreController.text) ?? 0,
        'aggregateScore': int.tryParse(_aggregateScoreController.text) ?? 0,
      };

      if (_selectedTeam == null) {
        await _firestore.collection('leaderboard').add(teamData);
      } else {
        await _firestore
            .collection('leaderboard')
            .doc(_selectedTeam!.id)
            .update(teamData);
      }

      _resetForm();
      _fetchTeams();
    }
  }

  Future<void> _deleteTeam(String teamId) async {
    await _firestore.collection('leaderboard').doc(teamId).delete();
    _fetchTeams();
  }

  void _editTeam(Team team) {
    setState(() {
      _selectedTeam = team;
      _nameController.text = team.name;
      _winsController.text = team.wins.toString();
      _lossesController.text = team.losses.toString();
      _scoreController.text = team.score.toString();
      _aggregateScoreController.text = team.aggregateScore.toString();
    });
  }

  void _resetForm() {
    setState(() {
      _selectedTeam = null;
      _nameController.clear();
      _winsController.clear();
      _lossesController.clear();
      _scoreController.clear();
      _aggregateScoreController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Manage Leaderboard"),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.indigo[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Add / Edit Team",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_nameController, "Team Name"),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(_winsController, "Wins",
                                  isNumber: true)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTextField(
                                  _lossesController, "Losses",
                                  isNumber: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(_scoreController, "Score",
                                  isNumber: true)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTextField(
                                  _aggregateScoreController, "Aggregate Score",
                                  isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _saveTeam,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text(_selectedTeam == null
                                ? 'Add Team'
                                : 'Update Team'),
                          ),
                          if (_selectedTeam != null)
                            ElevatedButton(
                              onPressed: _resetForm,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey),
                              child: const Text('Cancel'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(team.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Wins: ${team.wins}, Losses: ${team.losses}, Score: ${team.score}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTeam(team),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTeam(team.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }
}

class Team {
  final String id;
  final String name;
  final int wins;
  final int losses;
  final int score;
  final int aggregateScore;

  Team({
    required this.id,
    required this.name,
    required this.wins,
    required this.losses,
    required this.score,
    required this.aggregateScore,
  });

  factory Team.fromMap(Map<String, dynamic> data, String id) {
    return Team(
      id: id,
      name: data['name'] ?? '',
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      score: data['score'] ?? 0,
      aggregateScore: data['aggregateScore'] ?? 0,
    );
  }
}
