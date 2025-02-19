import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> matches = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    setState(() => isLoading = true);
    try {
      final matchesSnapshot = await _firestore.collection('matches').get();
      matches = matchesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching matches: $e');
    }
    setState(() => isLoading = false);
  }

  Widget _buildSetDetails(Map<String, dynamic> setData, int setIndex) {
    // Extract players and scores, ensuring default values if not available
    final List<dynamic> team1Players = setData['team1Players'] ?? [];
    final List<dynamic> team2Players = setData['team2Players'] ?? [];
    final team1Score = setData['team1Score'] ?? 0;
    final team2Score = setData['team2Score'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set ${setIndex + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team 1 Players: ${team1Players.join(' & ')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team 2 Players: ${team2Players.join(' & ')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMatches,
            tooltip: 'Refresh Matches',
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
              child: RefreshIndicator(
                onRefresh: fetchMatches,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];

                    // Extracting details from the match document
                    final team1 = match['team1'] ?? 'Team 1';
                    final team2 = match['team2'] ?? 'Team 2';
                    final roundNumber =
                        match['roundNumber']?.toString() ?? 'N/A';
                    final matchNumber =
                        match['matchNumber']?.toString() ?? 'N/A';
                    final isComplete = match['isComplete'] ?? false;
                    final List<dynamic> sets = match['sets'] ?? [];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Team 1 info
                            Expanded(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      team1.toString().isNotEmpty
                                          ? team1[0].toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    team1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // Team 2 info
                            Expanded(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      team2.toString().isNotEmpty
                                          ? team2[0].toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    team2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Round: $roundNumber'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isComplete ? 'Complete' : 'Pending',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sets.asMap().entries.map((entry) {
                                final setIndex = entry.key;
                                final setData =
                                    Map<String, dynamic>.from(entry.value);
                                return _buildSetDetails(setData, setIndex);
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
    );
  }
}
