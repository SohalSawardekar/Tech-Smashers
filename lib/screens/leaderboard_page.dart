import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _firestore.collection('teams').get();
      setState(() {
        teams = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _sortTeams();
      });
    } catch (e) {
      print('Error fetching teams: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _sortTeams() {
    setState(() {
      teams.sort((a, b) {
        int pointCompare = b['points'].compareTo(a['points']);
        if (pointCompare != 0) return pointCompare;
        return b['aggregateScore'].compareTo(a['aggregateScore']);
      });
    });
  }

  Future<void> updateTeamScore(
      String teamId, int points, double aggregateScore) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'points': points,
        'aggregateScore': aggregateScore,
      });
      fetchTeams();
    } catch (e) {
      print('Error updating team score: $e');
    }
  }

  void _editScore(int index) async {
    final team = teams[index];
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ScoreEditDialog(
        teamName: team['name'],
        initialPoints: team['points'],
        initialAggregateScore: team['aggregateScore'],
      ),
    );

    if (result != null) {
      updateTeamScore(team['id'], result['points'], result['aggregateScore']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  child: ListTile(
                    title: Text(team['name']),
                    subtitle: Text(
                        'Points: ${team['points']} | Aggregate Score: ${team['aggregateScore']}'),
                    trailing: isEditing
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editScore(index),
                          )
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isEditing ? Icons.check : Icons.edit),
        onPressed: () => setState(() => isEditing = !isEditing),
      ),
    );
  }
}

class ScoreEditDialog extends StatelessWidget {
  final String teamName;
  final int initialPoints;
  final double initialAggregateScore;

  const ScoreEditDialog({
    Key? key,
    required this.teamName,
    required this.initialPoints,
    required this.initialAggregateScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pointsController =
        TextEditingController(text: initialPoints.toString());
    final scoreController =
        TextEditingController(text: initialAggregateScore.toString());

    return AlertDialog(
      title: Text('Edit Scores for $teamName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: pointsController,
            decoration: const InputDecoration(labelText: 'Points'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: scoreController,
            decoration: const InputDecoration(labelText: 'Aggregate Score'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'points': int.parse(pointsController.text),
              'aggregateScore': double.parse(scoreController.text)
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
