import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScoreEntryPage extends StatefulWidget {
  @override
  _ScoreEntryPageState createState() => _ScoreEntryPageState();
}

class _ScoreEntryPageState extends State<ScoreEntryPage> {
  final TextEditingController team1ScoreController = TextEditingController();
  final TextEditingController team2ScoreController = TextEditingController();
  final TextEditingController team1NameController = TextEditingController();
  final TextEditingController team2NameController = TextEditingController();

  String winner = '';
  bool isScoreValid = true;
  String errorMessage = '';

  // Track game history
  List<Map<String, dynamic>> gameHistory = [];

  @override
  void dispose() {
    team1ScoreController.dispose();
    team2ScoreController.dispose();
    team1NameController.dispose();
    team2NameController.dispose();
    super.dispose();
  }

  void resetScores() {
    setState(() {
      team1ScoreController.clear();
      team2ScoreController.clear();
      winner = '';
      isScoreValid = true;
      errorMessage = '';
    });
  }

  bool validateScores() {
    try {
      int team1Score = int.parse(team1ScoreController.text);
      int team2Score = int.parse(team2ScoreController.text);

      // Badminton game rules validation
      if (team1Score < 0 || team2Score < 0) {
        setState(() {
          errorMessage = 'Scores cannot be negative';
          isScoreValid = false;
        });
        return false;
      }

      // Check if either team has reached at least 21 points
      if (team1Score < 21 && team2Score < 21) {
        setState(() {
          errorMessage = 'At least one team must score 21 points';
          isScoreValid = false;
        });
        return false;
      }

      // Check for 2-point difference rule
      if ((team1Score >= 21 || team2Score >= 21) &&
          (team1Score - team2Score).abs() < 2) {
        setState(() {
          errorMessage = 'There must be a 2-point difference to win';
          isScoreValid = false;
        });
        return false;
      }

      // Maximum score limit (30 points as per rules)
      if (team1Score > 30 || team2Score > 30) {
        setState(() {
          errorMessage = 'Maximum score limit is 30 points';
          isScoreValid = false;
        });
        return false;
      }

      setState(() {
        isScoreValid = true;
        errorMessage = '';
      });
      return true;
    } catch (e) {
      setState(() {
        errorMessage = 'Please enter valid scores';
        isScoreValid = false;
      });
      return false;
    }
  }

  void calculateWinner() {
    if (!validateScores()) return;

    int team1Score = int.parse(team1ScoreController.text);
    int team2Score = int.parse(team2ScoreController.text);
    String team1Name = team1NameController.text.isNotEmpty
        ? team1NameController.text
        : 'Team 1';
    String team2Name = team2NameController.text.isNotEmpty
        ? team2NameController.text
        : 'Team 2';

    setState(() {
      if (team1Score > team2Score) {
        winner = '$team1Name Wins!';
      } else {
        winner = '$team2Name Wins!';
      }

      // Add game to history
      gameHistory.add({
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Score': team1Score,
        'team2Score': team2Score,
        'winner': winner,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Badminton Score Entry'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetScores,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Team Names Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: team1NameController,
                        decoration: InputDecoration(
                          labelText: 'Team 1 Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: team2NameController,
                        decoration: InputDecoration(
                          labelText: 'Team 2 Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Score Entry Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: team1ScoreController,
                        decoration: InputDecoration(
                          labelText: 'Team 1 Score',
                          border: OutlineInputBorder(),
                          errorText: !isScoreValid ? errorMessage : null,
                          prefixIcon: Icon(Icons.sports_score),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: team2ScoreController,
                        decoration: InputDecoration(
                          labelText: 'Team 2 Score',
                          border: OutlineInputBorder(),
                          errorText: !isScoreValid ? errorMessage : null,
                          prefixIcon: Icon(Icons.sports_score),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: calculateWinner,
                icon: Icon(Icons.emoji_events),
                label: Text('Calculate Winner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              SizedBox(height: 24),

              if (winner.isNotEmpty)
                Card(
                  color: Colors.purple.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events,
                            size: 48, color: Colors.purple),
                        SizedBox(height: 8),
                        Text(
                          winner,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 24),

              // Game History Section
              if (gameHistory.isNotEmpty) ...[
                Text(
                  'Game History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: gameHistory.length,
                  itemBuilder: (context, index) {
                    final game = gameHistory[gameHistory.length - 1 - index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          '${game['team1Name']} vs ${game['team2Name']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${game['team1Score']} - ${game['team2Score']}\n${game['winner']}',
                        ),
                        trailing: Text(
                          '${game['timestamp'].hour}:${game['timestamp'].minute}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
