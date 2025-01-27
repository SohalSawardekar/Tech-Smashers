import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int scoreTeamA = 0;
  int scoreTeamB = 0;

  void _incrementScoreA() {
    setState(() {
      scoreTeamA++;
    });
  }

  void _decrementScoreA() {
    setState(() {
      if (scoreTeamA > 0) scoreTeamA--;
    });
  }

  void _resetScoreA() {
    setState(() {
      scoreTeamA = 0;
    });
  }

  void _incrementScoreB() {
    setState(() {
      scoreTeamB++;
    });
  }

  void _decrementScoreB() {
    setState(() {
      if (scoreTeamB > 0) scoreTeamB--;
    });
  }

  void _resetScoreB() {
    setState(() {
      scoreTeamB = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Counter'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Row(
        children: [
          // Team A
          Expanded(
            child: Container(
              color: Colors.teal.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Team A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$scoreTeamA',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _incrementScoreA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _decrementScoreA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade300,
                    ),
                    child: const Text(
                      '-',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetScoreA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 2,
            color: Colors.grey,
          ),

          // Team B
          Expanded(
            child: Container(
              color: Colors.teal.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Team B',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$scoreTeamB',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _incrementScoreB,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _decrementScoreB,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade300,
                    ),
                    child: const Text(
                      '-',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetScoreB,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
