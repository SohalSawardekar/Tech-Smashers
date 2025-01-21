// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';

class TournamentBracketPage extends StatefulWidget {
  const TournamentBracketPage({super.key});

  @override
  _TournamentBracketPageState createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  int totalRounds = 0;
  List<List<Match>> brackets = [];
  final double baseHeight = 80;
  final double baseWidth = 130;
  int? totalTeams;

  void initializeBracket(int teams) {
    int adjustedTeams =
        1 << (teams - 1).bitLength; 
    totalRounds = (adjustedTeams.bitLength) - 1;

    brackets = List.generate(
      totalRounds,
      (roundIndex) => List.generate(
        adjustedTeams >> (roundIndex + 1),
        (_) => Match(),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Tournament Bracket'),
        backgroundColor: Colors.deepPurple,
      ),
      body: totalTeams == null
          ? _buildTeamSelection()
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.purple.shade400,
                    Colors.deepPurple.shade900,
                  ],
                ),
              ),
              child: SafeArea(
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.8,
                  maxScale: 3.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            _buildConnectingLines(),
                            _buildBrackets(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTeamSelection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Total Number of Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., 8',
              ),
              onSubmitted: (value) {
                final teams = int.tryParse(value);
                if (teams != null && teams > 0) {
                  setState(() {
                    totalTeams = teams;
                    initializeBracket(teams);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingLines() {
    return CustomPaint(
      size: Size(
        baseWidth * totalRounds + 100,
        baseHeight * (brackets[0].length + 1),
      ),
      painter: BracketLinesPainter(
        brackets: brackets,
        baseHeight: baseHeight,
        baseWidth: baseWidth,
      ),
    );
  }

  Widget _buildBrackets() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalRounds, (roundIndex) {
        double verticalSpacing = baseHeight * (1 << roundIndex);
        return Column(
          children: [
            Container(
              width: baseWidth,
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Round ${roundIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ...List.generate(
              brackets[roundIndex].length,
              (matchIndex) => Column(
                children: [
                  _buildMatchBox(brackets[roundIndex][matchIndex]),
                  SizedBox(height: verticalSpacing - baseHeight),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMatchBox(Match match) {
    return Container(
      width: baseWidth - 20,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
      ),
      child: Column(
        children: [
          _buildTeamInput(match, true),
          const Divider(height: 1, color: Colors.white38),
          _buildTeamInput(match, false),
        ],
      ),
    );
  }

  Widget _buildTeamInput(Match match, bool isFirstTeam) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: isFirstTeam ? 'Team 1' : 'Team 2',
          hintStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            if (isFirstTeam) {
              match.team1 = value;
            } else {
              match.team2 = value;
            }
          });
        },
      ),
    );
  }
}

class Match {
  String team1 = '';
  String team2 = '';
}

class BracketLinesPainter extends CustomPainter {
  final List<List<Match>> brackets;
  final double baseHeight;
  final double baseWidth;

  BracketLinesPainter({
    required this.brackets,
    required this.baseHeight,
    required this.baseWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int roundIndex = 0; roundIndex < brackets.length - 1; roundIndex++) {
      final currentRound = brackets[roundIndex];
      final nextRound = brackets[roundIndex + 1];

      for (int matchIndex = 0; matchIndex < currentRound.length; matchIndex++) {
        final currentMatchTop = Offset(
          roundIndex * baseWidth + baseWidth / 2,
          matchIndex * baseHeight + baseHeight / 2,
        );
        final nextMatchTop = Offset(
          (roundIndex + 1) * baseWidth + baseWidth / 2,
          matchIndex ~/ 2 * baseHeight + baseHeight / 2,
        );

        canvas.drawLine(
          currentMatchTop,
          Offset(nextMatchTop.dx, currentMatchTop.dy),
          paint,
        );
        canvas.drawLine(
          Offset(nextMatchTop.dx, currentMatchTop.dy),
          nextMatchTop,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
