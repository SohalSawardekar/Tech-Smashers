import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _calculateAndUpdateScores();
    });
  }

  Future<void> fetchLeaderboard() async {
    setState(() => isLoading = true);
    try {
      final leaderboardDoc =
          await _firestore.collection('leaderboard').doc('latest').get();
      if (!leaderboardDoc.exists) {
        await _initializeLeaderboard();
      } else {
        setState(() {
          teams = List<Map<String, dynamic>>.from(
              leaderboardDoc.data()?['teams'] ?? []);
          _sortTeams();
        });
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _initializeLeaderboard() async {
    try {
      final teamsSnapshot = await _firestore.collection('teams').get();
      teams = teamsSnapshot.docs
          .map((doc) =>
              {'id': doc.id, 'name': doc.data()['name'], 'totalScore': 0})
          .toList();
      await _firestore.collection('leaderboard').doc('latest').set({
        'teams': teams,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _sortTeams();
      setState(() {});
    } catch (e) {
      print('Error initializing leaderboard: $e');
    }
  }

  Future<void> _calculateAndUpdateScores() async {
    try {
      final matchesSnapshot = await _firestore.collection('matches').get();
      Map<String, num> teamScores = {};

      for (var match in matchesSnapshot.docs) {
        final matchData = match.data();
        final team1 = matchData['team1'];
        final team2 = matchData['team2'];

        if (team1 != null && team2 != null) {
          for (int i = 1; i <= 5; i++) {
            final set = matchData['set$i'];
            if (set != null &&
                set.containsKey('team1Score') &&
                set.containsKey('team2Score')) {
              teamScores[team1] = (teamScores[team1] ?? 0) + set['team1Score'];
              teamScores[team2] = (teamScores[team2] ?? 0) + set['team2Score'];
            }
          }
        }
      }

      teams = teams.map((team) {
        return {
          'id': team['id'],
          'name': team['name'],
          'totalScore': teamScores.containsKey(team['name'])
              ? teamScores[team['name']]!
              : 0,
        };
      }).toList();

      _sortTeams();

      await _firestore.collection('leaderboard').doc('latest').update({
        'teams': teams,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {});
    } catch (e) {
      print('Error updating leaderboard scores: $e');
    }
  }

  void _sortTeams() {
    teams.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
        backgroundColor: Colors.blue,
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final isTopThree = index < 3;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Rank Circle
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isTopThree
                                    ? [
                                        Colors.amber, // Gold
                                        Colors.grey[300], // Silver
                                        Colors.brown[300], // Bronze
                                      ][index]
                                    : Colors.blue.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isTopThree
                                        ? Colors.white
                                        : Colors.blue[900],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Team Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Progress Bar
                                  if (teams.isNotEmpty)
                                    LinearProgressIndicator(
                                      value: team['totalScore'] /
                                          teams[0]['totalScore'],
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          isTopThree
                                              ? [
                                                  Colors.amber,
                                                  Colors.grey[400]!,
                                                  Colors.brown[300]!,
                                                ][index]
                                              : Colors.blue),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Score
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${team['totalScore']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  'points',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
