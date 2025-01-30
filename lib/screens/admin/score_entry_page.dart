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
          for (int i = 0; i < 5; i++) {
            team1Controllers[i].text =
                currentMatchData['set${i + 1}']?['team1Score']?.toString() ??
                    '';
            team2Controllers[i].text =
                currentMatchData['set${i + 1}']?['team2Score']?.toString() ??
                    '';
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
      Map<String, dynamic> matchData = {'isComplete': isMatchComplete};
      for (int i = 0; i < 5; i++) {
        if (team1Controllers[i].text.isNotEmpty ||
            team2Controllers[i].text.isNotEmpty) {
          matchData['set${i + 1}'] = {
            'team1Score': int.tryParse(team1Controllers[i].text) ?? 0,
            'team2Score': int.tryParse(team2Controllers[i].text) ?? 0,
          };
        }
      }
      if (matchData.isNotEmpty) {
        await _firestore.collection('matches').doc(matchId).update(matchData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match scores updated successfully!')),
        );
        fetchMatches();
      }
    } catch (e) {
      print('Error updating match score: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update match score')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMatchId,
                    hint: const Text('Select a match'),
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
                      fetchMatchDetails(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < 5; i++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Set ${i + 1}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: team1Controllers[i],
                                decoration: InputDecoration(
                                  labelText: 'Team 1 Score',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: team2Controllers[i],
                                decoration: InputDecoration(
                                  labelText: 'Team 2 Score',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  SwitchListTile(
                    title: const Text('Match Completed'),
                    value: isMatchComplete,
                    onChanged: (value) {
                      setState(() {
                        isMatchComplete = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedMatchId == null
                        ? null
                        : () => updateMatchScore(selectedMatchId!),
                    child: const Text('Update Match Scores'),
                  ),
                ],
              ),
            ),
    );
  }
}
