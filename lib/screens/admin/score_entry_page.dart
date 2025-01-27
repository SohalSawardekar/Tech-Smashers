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
  bool isLoading = false; // State to show circular progress indicator

  final TextEditingController set1Team1Controller = TextEditingController();
  final TextEditingController set1Team2Controller = TextEditingController();
  final TextEditingController set2Team1Controller = TextEditingController();
  final TextEditingController set2Team2Controller = TextEditingController();
  final TextEditingController set3Team1Controller = TextEditingController();
  final TextEditingController set3Team2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  @override
  void dispose() {
    set1Team1Controller.dispose();
    set1Team2Controller.dispose();
    set2Team1Controller.dispose();
    set2Team2Controller.dispose();
    set3Team1Controller.dispose();
    set3Team2Controller.dispose();
    super.dispose();
  }

  Future<void> fetchMatches() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('isComplete', isEqualTo: false)
          .get();

      setState(() {
        matches = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching matches: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> updateMatchScore(String matchId) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final matchData = {
        'set1': {
          'team1Score': int.tryParse(set1Team1Controller.text) ?? 0,
          'team2Score': int.tryParse(set1Team2Controller.text) ?? 0,
        },
        'set2': {
          'team1Score': int.tryParse(set2Team1Controller.text) ?? 0,
          'team2Score': int.tryParse(set2Team2Controller.text) ?? 0,
        },
        'set3': {
          'team1Score': int.tryParse(set3Team1Controller.text) ?? 0,
          'team2Score': int.tryParse(set3Team2Controller.text) ?? 0,
        },
        'isComplete': true, // Mark the match as complete
      };

      await _firestore.collection('matches').doc(matchId).update(matchData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match scores updated successfully!')),
      );

      // Refresh matches after updating
      await fetchMatches();

      // Clear inputs
      setState(() {
        selectedMatchId = null;
        set1Team1Controller.clear();
        set1Team2Controller.clear();
        set2Team1Controller.clear();
        set2Team2Controller.clear();
        set3Team1Controller.clear();
        set3Team2Controller.clear();
      });
    } catch (e) {
      print('Error updating match score: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update match score')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
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
          ? const Center(
              child: CircularProgressIndicator(), // Show loading spinner
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Match',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMatchId,
                      hint: const Text('Select a match'),
                      items: matches
                          .map(
                            (match) => DropdownMenuItem<String>(
                              value: match['id'] as String,
                              child: Text(
                                '${match['team1']} vs ${match['team2']}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMatchId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Enter Scores for Sets',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Set 1'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: set1Team1Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 1 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: set1Team2Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 2 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Set 2'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: set2Team1Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 1 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: set2Team2Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 2 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Set 3'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: set3Team1Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 1 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: set3Team2Controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Team 2 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: selectedMatchId == null
                          ? null
                          : () => updateMatchScore(selectedMatchId!),
                      child: const Text('Update Match Scores'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
