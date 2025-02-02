import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentBracketPage extends StatefulWidget {
  const TournamentBracketPage({super.key});

  @override
  State<TournamentBracketPage> createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> matches = [];
  List<String> _teams = [];
  String? _team1;
  String? _team2;
  bool isComplete = false;
  bool isLoading = false;
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchMatches();
  }

  Future<void> _fetchTeams() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _firestore.collection('teams').get();
      final List<String> teams =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      setState(() {
        _teams = teams;
      });
    } catch (e) {
      debugPrint('Error fetching teams: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _fetchMatches() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final snapshot = await _firestore.collection('matches').get();
      final List<Map<String, dynamic>> fetchedMatches = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      setState(() {
        matches = fetchedMatches;
      });
    } catch (e) {
      debugPrint('Error fetching matches: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _scheduleMatch() async {
    final roundNumber = int.tryParse(_roundNumberController.text);
    final matchNumber = int.tryParse(_matchNumberController.text);

    if (_team1 == null || _team2 == null || matchNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select teams and enter match number')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      await _firestore.collection('matches').add({
        'team1': _team1,
        'team2': _team2,
        'roundNumber': roundNumber,
        'matchNumber': matchNumber,
        'isComplete': isComplete,
        'winner': {
          'teamName': "",
          'score': 0,
        },
        'set1': {
          'team1Score': 0,
          'team2Score': 0,
        },
        'set2': {
          'team1Score': 0,
          'team2Score': 0,
        },
        'set3': {
          'team1Score': 0,
          'team2Score': 0,
        },
        'set4': {
          'team1Score': 0,
          'team2Score': 0,
        },
        'set5': {
          'team1Score': 0,
          'team2Score': 0,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match scheduled successfully!')),
      );

      await _fetchMatches(); // Refresh matches after scheduling

      setState(() {
        _team1 = null;
        _team2 = null;
        _matchNumberController.clear();
        _roundNumberController.clear();
      });
    } catch (e) {
      debugPrint('Error scheduling match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule match')),
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
        title: const Text('Schedule Match'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loader
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Select Teams and Enter Match Number',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _team1,
                        hint: const Text('Select Team 1'),
                        items: _teams
                            .map((team) => DropdownMenuItem(
                                value: team, child: Text(team)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _team1 = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _team2,
                        hint: const Text('Select Team 2'),
                        items: _teams
                            .map((team) => DropdownMenuItem(
                                value: team, child: Text(team)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _team2 = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roundNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Round Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _matchNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Match Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _scheduleMatch,
                        child: const Text('Schedule Match'),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          const Text(
                            'Scheduled Matches',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              final isComplete = match['isComplete'] as bool;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    '${match['team1']} vs ${match['team2']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Round: ${match['roundNumber']}, Match: ${match['matchNumber']}',
                                  ),
                                  trailing: Text(
                                    isComplete ? 'Completed' : 'Pending',
                                    style: TextStyle(
                                      color: isComplete
                                          ? Colors.green
                                          : Colors.red, // Red or Green
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
