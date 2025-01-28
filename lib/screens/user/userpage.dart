import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> scoreboard = [];
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch teams
      final teamsSnapshot = await _firestore.collection('teams').get();
      teams = teamsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Fetch matches
      final matchesSnapshot = await _firestore.collection('matches').get();
      matches = matchesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Fetch scoreboard
      final scoreboardSnapshot =
          await _firestore.collection('scoreboard').get();
      scoreboard = scoreboardSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Fetch leaderboard
      final leaderboardSnapshot =
          await _firestore.collection('leaderboard').orderBy('score', descending: true).get();
      leaderboard = leaderboardSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teams Registered',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(team['name']),
                            subtitle: Text('Members: ${team['members']}'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scheduled Matches',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              '${match['team1']} vs ${match['team2']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Round: ${match['roundNumber']}, Match: ${match['matchNumber']}\nStatus: ${match['isComplete'] ? 'Completed' : 'Pending'}',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scoreboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scoreboard.length,
                      itemBuilder: (context, index) {
                        final team = scoreboard[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(team['name']),
                            subtitle: Text('Score: ${team['score']}'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaderboard.length,
                      itemBuilder: (context, index) {
                        final player = leaderboard[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: player['avatar'] != null
                                  ? NetworkImage(player['avatar'])
                                  : null,
                              child: player['avatar'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(player['name']),
                            subtitle: Text('Score: ${player['score']}'),
                            trailing: Text('Rank: #${index + 1}'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
