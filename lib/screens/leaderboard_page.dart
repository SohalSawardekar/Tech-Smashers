import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Team {
  final int id;
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

  // Factory method to create a Team from Firestore data
  factory Team.fromMap(Map<String, dynamic> data) {
    return Team(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      score: data['score'] ?? 0,
      aggregateScore: data['aggregateScore'] ?? 0,
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Team> teams = [];
  String sortColumn = 'score';
  bool ascending = false;

  @override
  void initState() {
    super.initState();
    _fetchMatches(); // Fetch data when the widget initializes
  }

  Future<void> _fetchMatches() async {
    try {
      final snapshot = await _firestore.collection('leaderboard').get();
      setState(() {
        teams = snapshot.docs
            .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort: First by `score` (desc), then by `aggregateScore` (desc)
        teams.sort((a, b) {
          if (b.score != a.score) {
            return b.score.compareTo(a.score);
          }
          return b.aggregateScore.compareTo(a.aggregateScore);
        });
      });
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  void _sort<T>(Comparable<T> Function(Team team) getField, String columnName,
      int columnIndex) {
    setState(() {
      if (sortColumn == columnName) {
        ascending = !ascending;
      } else {
        sortColumn = columnName;
        ascending = true;
      }

      teams.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  Widget _buildRankIcon(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.emoji_events, color: Colors.amber[400], size: 24);
      case 1:
        return Icon(Icons.workspace_premium, color: Colors.grey[400], size: 24);
      case 2:
        return Icon(Icons.military_tech, color: Colors.orange[700], size: 24);
      default:
        return Icon(Icons.sports_score, color: Colors.blue[400], size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.indigo[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Team Leaderboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchMatches,
                  child: const Text("Refresh"),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Wrap the table in nested scroll views
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: teams.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                    Colors.indigo[600]),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                columns: [
                                  const DataColumn(label: Text('Rank')),
                                  const DataColumn(label: Text('Team')),
                                  DataColumn(
                                    label: const Text('Wins'),
                                    onSort: (index, _) => _sort(
                                        (team) => team.wins, 'wins', index),
                                  ),
                                  DataColumn(
                                    label: const Text('Losses'),
                                    onSort: (index, _) => _sort(
                                        (team) => team.losses, 'losses', index),
                                  ),
                                  DataColumn(
                                    label: const Text('Score'),
                                    onSort: (index, _) => _sort(
                                        (team) => team.score, 'score', index),
                                  ),
                                  DataColumn(
                                    label: const Text('Aggregate'),
                                    onSort: (index, _) => _sort(
                                        (team) => team.aggregateScore,
                                        'aggregateScore',
                                        index),
                                  ),
                                ],
                                rows: teams.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final team = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildRankIcon(index),
                                            const SizedBox(width: 8),
                                            Text(
                                              '#${index + 1}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(team.name)),
                                      DataCell(
                                        Text(
                                          team.wins.toString(),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          team.losses.toString(),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          team.score.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataCell(
                                          Text(team.aggregateScore.toString())),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
