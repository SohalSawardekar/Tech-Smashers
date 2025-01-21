import 'package:flutter/material.dart';

class Team {
  final String name;
  final int played;
  final int won;
  final int lost;
  final int points;
  final String recentForm;
  final double winPercentage;

  Team({
    required this.name,
    required this.played,
    required this.won,
    required this.lost,
    required this.points,
    required this.recentForm,
    required this.winPercentage,
  });
}

class LeaderboardPage extends StatelessWidget {
  final List<Team> teams = [
    Team(
        name: "Thunder Smashers",
        played: 10,
        won: 8,
        lost: 2,
        points: 16,
        recentForm: "WWLWW",
        winPercentage: 80),
    Team(
        name: "Lightning Strikers",
        played: 10,
        won: 7,
        lost: 3,
        points: 14,
        recentForm: "WLWWW",
        winPercentage: 70),
    // Add more teams here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Leaderboard'),
        backgroundColor: Colors.blue,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            TabBar(
              tabs: [
                Tab(text: 'Rankings'),
                Tab(text: 'Statistics'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Rankings Tab
                  _buildRankingsTab(),
                  // Statistics Tab
                  _buildStatisticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingsTab() {
    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text((index + 1).toString(),
                style: TextStyle(color: Colors.white)),
          ),
          title: Text(team.name),
          subtitle: Text('${team.points} points'),
          trailing: Text('${team.winPercentage}% Win'),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildStatisticCard(
          title: 'Highest Win Streak',
          value: '8 matches',
          team: 'Thunder Smashers',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _buildStatisticCard(
          title: 'Most Points Scored',
          value: '245 points',
          team: 'Lightning Strikers',
          icon: Icons.score,
          color: Colors.orange,
        ),
        _buildStatisticCard(
          title: 'Best Win Rate',
          value: '80%',
          team: 'Thunder Smashers',
          icon: Icons.percent,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required String team,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.blue.shade50,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text('$value by $team'),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: LeaderboardPage(),
    ));
