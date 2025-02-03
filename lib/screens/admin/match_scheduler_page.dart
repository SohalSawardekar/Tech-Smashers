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
  List<String> _team1Players = [];
  List<String> _team2Players = [];
  String? _team1;
  String? _team2;
  bool isLoading = false;
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();
  List<String?> _selectedTeam1Players = List.filled(5, null);
  List<String?> _selectedTeam2Players = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchMatches();
  }

  Future<void> _fetchTeams() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _firestore.collection('teams').get();
      setState(() {
        _teams = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      debugPrint('Error fetching teams: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPlayers(String team, bool isTeam1) async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('teams')
          .where('name', isEqualTo: team)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final teamData = snapshot.docs.first.data();
        final List<dynamic> playersData = teamData['players'] ?? [];

        final List<String> playerNames =
            playersData.map((player) => player['name'] as String).toList();

        setState(() {
          if (isTeam1) {
            _team1Players = playerNames;
            _selectedTeam1Players = List.filled(5, null);
          } else {
            _team2Players = playerNames;
            _selectedTeam2Players = List.filled(5, null);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching players: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchMatches() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await _firestore.collection('matches').get();
      setState(() {
        matches =
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      });
    } catch (e) {
      debugPrint('Error fetching matches: $e');
    } finally {
      setState(() => isLoading = false);
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

    setState(() => isLoading = true);
    try {
      await _firestore.collection('matches').add({
        'team1': _team1,
        'team2': _team2,
        'roundNumber': roundNumber,
        'matchNumber': matchNumber,
        'sets': List.generate(
            5,
            (index) => {
                  'team1Player': _selectedTeam1Players[index],
                  'team2Player': _selectedTeam2Players[index],
                  'team1Score': 0,
                  'team2Score': 0,
                }),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match scheduled successfully!')),
      );

      await _fetchMatches();
    } catch (e) {
      debugPrint('Error scheduling match: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      await _firestore.collection('matches').doc(matchId).delete();
      _fetchMatches();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match deleted successfully!')),
      );
    } catch (e) {
      debugPrint('Error deleting match: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Match')),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.indigo[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _team1,
                              hint: const Text('Select Team 1'),
                              items: _teams
                                  .map((team) => DropdownMenuItem(
                                      value: team, child: Text(team)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _team1 = value);
                                _fetchPlayers(value!, true);
                              },
                            ),
                            DropdownButtonFormField<String>(
                              value: _team2,
                              hint: const Text('Select Team 2'),
                              items: _teams
                                  .map((team) => DropdownMenuItem(
                                      value: team, child: Text(team)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _team2 = value);
                                _fetchPlayers(value!, false);
                              },
                            ),
                            const SizedBox(height: 32),
                            Text(
                                '${_team1 ?? 'Team 1'} vs ${_team2 ?? 'Team 2'}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            for (int i = 0; i < 5; i++)
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedTeam1Players[i],
                                      hint: Text('Set ${i + 1} Player'),
                                      items: _team1Players
                                          .map((player) => DropdownMenuItem(
                                              value: player,
                                              child: Text(player)))
                                          .toList(),
                                      onChanged: (value) => setState(() =>
                                          _selectedTeam1Players[i] = value),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("vs"),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedTeam2Players[i],
                                      hint: Text('Set ${i + 1} Player'),
                                      items: _team2Players
                                          .map((player) => DropdownMenuItem(
                                              value: player,
                                              child: Text(player)))
                                          .toList(),
                                      onChanged: (value) => setState(() =>
                                          _selectedTeam2Players[i] = value),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _scheduleMatch,
                              child: const Text('Schedule Match'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Scheduled Matches',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    ...matches.map((match) => ListTile(
                          title: Text("${match['team1']} VS ${match['team2']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMatch(match['id']),
                          ),
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}
