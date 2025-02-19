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

  // Controllers for match and round number inputs
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();

  // For 5 sets, each set contains two players for each team.
  List<List<String?>> _selectedTeam1Players =
      List.generate(5, (_) => [null, null]);
  List<List<String?>> _selectedTeam2Players =
      List.generate(5, (_) => [null, null]);

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
            _selectedTeam1Players =
                List.generate(5, (_) => [null, null]); // Two players per set
          } else {
            _team2Players = playerNames;
            _selectedTeam2Players =
                List.generate(5, (_) => [null, null]); // Two players per set
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

    setState(() => isLoading = true);
    try {
      await _firestore.collection('matches').add({
        'team1': _team1,
        'team2': _team2,
        'roundNumber': roundNumber,
        'isComplete': false, // default value when scheduling
        'sets': List.generate(
          5,
          (index) => {
            'team1Players': _selectedTeam1Players[index],
            'team2Players': _selectedTeam2Players[index],
            'team1Score': 0,
            'team2Score': 0,
          },
        ),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match scheduled successfully!')),
      );

      // Clear selections after scheduling
      setState(() {
        _matchNumberController.clear();
        _roundNumberController.clear();
        _selectedTeam1Players = List.generate(5, (_) => [null, null]);
        _selectedTeam2Players = List.generate(5, (_) => [null, null]);
      });

      await _fetchMatches();
    } catch (e) {
      debugPrint('Error scheduling match: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Opens a dialog to update the completion status of a match.
  Future<void> _editMatchCompletion(Map<String, dynamic> match) async {
    bool isComplete = match['isComplete'] ?? false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Match Status'),
          content: Text(
              'Current status: ${isComplete ? 'Over' : 'In Progress'}\nDo you want to mark this match as ${isComplete ? 'Not Over' : 'Over'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('matches')
                      .doc(match['id'])
                      .update({'isComplete': !isComplete});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Match marked as ${!isComplete ? 'Over' : 'Not Over'}'),
                    ),
                  );
                  await _fetchMatches();
                } catch (e) {
                  debugPrint('Error updating match status: $e');
                } finally {
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(!isComplete ? 'Mark as Over' : 'Mark as Not Over'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchSchedulingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _team1,
              decoration: const InputDecoration(
                labelText: 'Team 1',
                border: OutlineInputBorder(),
              ),
              items: _teams
                  .map((team) =>
                      DropdownMenuItem(value: team, child: Text(team)))
                  .toList(),
              onChanged: (value) {
                setState(() => _team1 = value);
                if (value != null) _fetchPlayers(value, true);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _team2,
              decoration: const InputDecoration(
                labelText: 'Team 2',
                border: OutlineInputBorder(),
              ),
              items: _teams
                  .map((team) =>
                      DropdownMenuItem(value: team, child: Text(team)))
                  .toList(),
              onChanged: (value) {
                setState(() => _team2 = value);
                if (value != null) _fetchPlayers(value, false);
              },
            ),
            const SizedBox(height: 16),
            // Round number input (manual)
            TextField(
              controller: _roundNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Round Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Match number input
            // TextField(
            //   controller: _matchNumberController,
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(
            //     labelText: 'Match Number',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            const SizedBox(height: 16),
            Text(
              '${_team1 ?? 'Team 1'} vs ${_team2 ?? 'Team 2'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 5; i++) ...[
              Text(
                'Set ${i + 1}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedTeam1Players[i][0],
                          decoration: const InputDecoration(
                            labelText: 'Team 1 Player 1',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          items: _team1Players
                              .map((player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(player,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) => setState(
                              () => _selectedTeam1Players[i][0] = value),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedTeam1Players[i][1],
                          decoration: const InputDecoration(
                            labelText: 'Team 1 Player 2',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          items: _team1Players
                              .map((player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(player,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) => setState(
                              () => _selectedTeam1Players[i][1] = value),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("vs"),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedTeam2Players[i][0],
                          decoration: const InputDecoration(
                            labelText: 'Team 2 Player 1',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          items: _team2Players
                              .map((player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(player,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) => setState(
                              () => _selectedTeam2Players[i][0] = value),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedTeam2Players[i][1],
                          decoration: const InputDecoration(
                            labelText: 'Team 2 Player 2',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          items: _team2Players
                              .map((player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(player,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) => setState(
                              () => _selectedTeam2Players[i][1] = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scheduleMatch,
              child: const Text('Schedule Match'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledMatchesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scheduled Matches',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...matches.map((match) => Card(
                  child: ListTile(
                    title: Text(
                        "${match['team1']} VS ${match['team2']} - Round ${match['roundNumber'] ?? 'N/A'}"),
                    subtitle: Text(match['isComplete'] == true
                        ? 'Match Over'
                        : 'In Progress'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editMatchCompletion(match),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
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
                    _buildMatchSchedulingCard(),
                    const SizedBox(height: 20),
                    _buildScheduledMatchesCard(),
                  ],
                ),
              ),
      ),
    );
  }
}
