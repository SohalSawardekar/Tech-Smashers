// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

class TeamRegistrationPage extends StatefulWidget {
  const TeamRegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TeamRegistrationPageState createState() => _TeamRegistrationPageState();
}

class _TeamRegistrationPageState extends State<TeamRegistrationPage>
    with SingleTickerProviderStateMixin {
  final List<Team> teams = [];
  late AnimationController _controller;

  final TextEditingController teamController = TextEditingController();

  Team? currentTeam;
  String error = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    teamController.dispose();
    super.dispose();
  }

  void _createNewTeam() {
    if (teamController.text.isEmpty) {
      setState(() => error = 'Please enter a team name');
      return;
    }

    setState(() {
      currentTeam = Team(name: teamController.text);
      error = '';
    });
    _showAddPlayerDialog();
  }

  void _addPlayerToTeam(Player player) {
    setState(() {
      currentTeam!.players.add(player);
      if (currentTeam!.players.length == 6) {
        if (_validateTeam()) {
          teams.add(currentTeam!);
          currentTeam = null;
          teamController.clear();
          _showSuccessDialog();
        } else {
          _showErrorDialog('Team must have at least one female player');
          currentTeam!.players.removeLast();
        }
      }
    });
  }

  bool _validateTeam() {
    return currentTeam!.players.any((player) => player.gender == Gender.female);
  }

  void _showAddPlayerDialog() {
    final playerNameController = TextEditingController();
    final numberController = TextEditingController();
    Gender selectedGender = Gender.male;
    String? selectedRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Add Player ${currentTeam!.players.length + 1}/6',
            style: TextStyle(color: Colors.teal.shade700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: playerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jersey Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Gender>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people, color: Colors.teal),
                  ),
                  items: Gender.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child:
                          Text(gender.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedGender = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sports, color: Colors.teal),
                  ),
                  items: [
                    'Captain',
                    'Forward',
                    'Defender',
                    'Midfielder',
                    'Goalkeeper',
                    'Substitute'
                  ]
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (playerNameController.text.isNotEmpty &&
                    numberController.text.isNotEmpty) {
                  _addPlayerToTeam(Player(
                    name: playerNameController.text,
                    number: int.parse(numberController.text),
                    gender: selectedGender,
                    role: selectedRole ?? 'Player',
                    isCaptain: currentTeam!.players.isEmpty,
                  ));
                  Navigator.pop(context);
                  if (currentTeam!.players.length < 6) {
                    _showAddPlayerDialog();
                  }
                }
              },
              child: const Text('Add Player'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Success!', style: TextStyle(color: Colors.green)),
        content: const Text('Team has been successfully registered.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade50,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      'Team Registration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Team Input Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: teamController,
                              decoration: const InputDecoration(
                                labelText: 'Team Name',
                                border: OutlineInputBorder(),
                                prefixIcon:
                                    Icon(Icons.group, color: Colors.teal),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Create Team',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _createNewTeam,
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  error,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Current Team Section
                    if (currentTeam != null) ...[
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Team: ${currentTeam!.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: currentTeam!.players.map((player) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.teal.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (player.isCaptain)
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 18),
                                            Text(
                                              player.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '#${player.number} - ${player.role}',
                                          style: TextStyle(
                                            color: Colors.teal.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          player.gender
                                              .toString()
                                              .split('.')
                                              .last
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.teal.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Registered Teams Section
                    if (teams.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Registered Teams',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...teams
                          .map((team) => Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    team.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: team.players.map((player) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.teal.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (player.isCaptain)
                                                      const Icon(Icons.star,
                                                          color: Colors.amber,
                                                          size: 18),
                                                    Text(
                                                      player.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .teal.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '#${player.number} - ${player.role}',
                                                  style: TextStyle(
                                                    color: Colors.teal.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  player.gender
                                                      .toString()
                                                      .split('.')
                                                      .last
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.teal.shade500,
                                                    fontSize: 12,
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
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Gender { male, female }

class Player {
  final String name;
  final int number;
  final Gender gender;
  final String role;
  final bool isCaptain;

  Player({
    required this.name,
    required this.number,
    required this.gender,
    required this.role,
    required this.isCaptain,
  });
}

class Team {
  final String name;
  final List<Player> players;

  Team({
    required this.name,
    List<Player>? players,
  }) : players = players ?? [];
}
