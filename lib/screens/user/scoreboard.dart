import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        List<Map<String, dynamic>> setScores = [];
        for (int i = 1; i <= 5; i++) {
          final setData = data['set$i'];
          if (setData != null) {
            setScores.add({
              'setNumber': i,
              'team1Score': setData['team1Score'] ?? 0,
              'team2Score': setData['team2Score'] ?? 0,
            });
          }
        }
        return {
          'id': doc.id,
          'team1': data['team1'],
          'team2': data['team2'],
          'setScores': setScores,
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children:
                                  match['setScores'].map<Widget>((setScore) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Set ${setScore['setNumber']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${setScore['team1Score']} - ${setScore['team2Score']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
    );
  }
}
