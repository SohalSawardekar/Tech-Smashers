import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreEntryPage extends StatefulWidget {
  const ScoreEntryPage({super.key});

  @override
  _ScoreEntryPageState createState() => _ScoreEntryPageState();
}

class _ScoreEntryPageState extends State<ScoreEntryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedMatchId;
  List<Map<String, dynamic>> matches = [];
  bool isLoading = false;
  bool isMatchComplete = false;
  Map<String, dynamic> currentMatchData = {};

  final List<TextEditingController> team1Controllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> team2Controllers =
      List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  @override
  void dispose() {
    for (var controller in team1Controllers) {
      controller.dispose();
    }
    for (var controller in team2Controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchMatches() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _firestore.collection('matches').get();
      setState(() {
        matches =
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      });
    } catch (e) {
      print('Error fetching matches: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMatchDetails(String matchId) async {
    try {
      final doc = await _firestore.collection('matches').doc(matchId).get();
      if (doc.exists) {
        setState(() {
          currentMatchData = doc.data()!;
          isMatchComplete = currentMatchData['isComplete'] ?? false;

          // Initialize scores if they exist
          final sets = currentMatchData['sets'] as List<dynamic>;
          for (int i = 0; i < 5; i++) {
            team1Controllers[i].text = sets[i]['team1Score']?.toString() ?? '';
            team2Controllers[i].text = sets[i]['team2Score']?.toString() ?? '';
          }
        });
      }
    } catch (e) {
      print('Error fetching match details: $e');
    }
  }

  Future<void> updateMatchScore(String matchId) async {
    setState(() => isLoading = true);
    try {
      // Get the current sets data
      final sets = List.from(currentMatchData['sets']);

      // Update scores while preserving player information
      for (int i = 0; i < 5; i++) {
        sets[i] = {
          ...sets[i],
          'team1Score': int.tryParse(team1Controllers[i].text) ?? 0,
          'team2Score': int.tryParse(team2Controllers[i].text) ?? 0,
        };
      }

      await _firestore.collection('matches').doc(matchId).update({
        'sets': sets,
        'isComplete': isMatchComplete,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match scores updated successfully!')),
      );
      fetchMatches();
    } catch (e) {
      print('Error updating match score: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update match score')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSetCard(int setIndex) {
    final set = currentMatchData['sets']?[setIndex] ?? {};
    final team1Players = set['team1Players'] as List<dynamic>? ?? [];
    final team2Players = set['team2Players'] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set ${setIndex + 1}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: team1Controllers[setIndex],
                        decoration: const InputDecoration(
                          labelText: 'Team 1 Score',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Players: ${team1Players.join(" & ")}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: team2Controllers[setIndex],
                        decoration: const InputDecoration(
                          labelText: 'Team 2 Score',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Players: ${team2Players.join(" & ")}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Entry'),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedMatchId,
                          decoration: const InputDecoration(
                            labelText: 'Select Match',
                            border: OutlineInputBorder(),
                          ),
                          items: matches
                              .map((match) => DropdownMenuItem<String>(
                                    value: match['id'] as String,
                                    child: Text(
                                        '${match['team1']} vs ${match['team2']}'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMatchId = value;
                            });
                            if (value != null) {
                              fetchMatchDetails(value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedMatchId != null) ...[
                      for (int i = 0; i < 5; i++) _buildSetCard(i),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.purple,
                        ),
                        onPressed: () => updateMatchScore(selectedMatchId!),
                        child: const Text(
                          'Update Match Scores',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
