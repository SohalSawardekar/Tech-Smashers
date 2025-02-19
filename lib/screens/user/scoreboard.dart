import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({Key? key}) : super(key: key);

  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatchScores();
  }

  Future<void> fetchMatchScores() async {
    setState(() => isLoading = true);
    try {
      final matchesSnapshot = await _firestore.collection('matches').get();
      matches = matchesSnapshot.docs.map((doc) {
        final data = doc.data();
        // Retrieve the list of sets; default to an empty list if not found.
        final sets = data['sets'] as List<dynamic>? ?? [];
        // Convert each set into a map with setNumber and details.
        List<Map<String, dynamic>> setDetails =
            sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value as Map<String, dynamic>;
          return {
            'setNumber': index + 1,
            'team1Score': set['team1Score'] ?? 0,
            'team2Score': set['team2Score'] ?? 0,
            'team1Players': set['team1Players'] ?? [],
            'team2Players': set['team2Players'] ?? [],
          };
        }).toList();

        return {
          'id': doc.id,
          'team1': data['team1'] ?? 'Team 1',
          'team2': data['team2'] ?? 'Team 2',
          'roundNumber': data['roundNumber'] ?? 'N/A',
          'matchNumber': data['matchNumber'] ?? 'N/A',
          'isComplete': data['isComplete'] ?? false,
          'sets': setDetails,
        };
      }).toList();
    } catch (e) {
      print('Error fetching match scores: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Scoreboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchMatchScores,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  // Wrap the list view in an Expanded widget
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchMatchScores,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final match = matches[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                '${match['team1']} vs ${match['team2']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Round: ${match['roundNumber']}'),
                                  Text(match['isComplete']
                                      ? 'Status: Over'
                                      : 'Status: In Progress'),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: match['sets'].map<Widget>((set) {
                                      final team1Players =
                                          (set['team1Players'] as List)
                                              .join(' & ');
                                      final team2Players =
                                          (set['team2Players'] as List)
                                              .join(' & ');
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Set ${set['setNumber']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Team 1 Players: $team1Players',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              'Team 2 Players: $team2Players',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Score: ${set['team1Score']} - ${set['team2Score']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
