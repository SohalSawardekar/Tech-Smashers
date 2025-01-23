// ignore_for_file: library_private_types_in_public_api, unused_element, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tech_smash/models/teamModel.dart';
import 'package:tech_smash/services/firestore_service.dart';

class TeamRegistrationPage extends StatefulWidget {
  const TeamRegistrationPage({super.key});

  @override
  _TeamRegistrationPageState createState() => _TeamRegistrationPageState();
}

class _TeamRegistrationPageState extends State<TeamRegistrationPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late List<TeamModel> teams = [];
  TeamModel? currentTeam;
  late AnimationController _controller;
  final TextEditingController teamController = TextEditingController();
  String error = '';
  bool isTeamRegistered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fetchData();
    _startPeriodicFetch();
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
      currentTeam = TeamModel(
        name: teamController.text,
        players: [],
      );
      error = '';
    });
    _showAddPlayerDialog();
  }

  bool _validateTeam() {
    return currentTeam?.players
            .any((player) => player.gender == Gender.female) ??
        false;
  }

  void _addPlayerToTeam(Player player) {
    setState(() {
      currentTeam?.players.add(player);
      if ((currentTeam?.players.length ?? 0) == 6) {
        if (_validateTeam()) {
          _showSubmitDialog();
        } else {
          _showErrorDialog('Team must have at least one female player');
          currentTeam?.players.removeLast();
        }
      }
    });
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Submit Team', style: TextStyle(color: Colors.teal)),
        content: const Text('Are you sure you want to submit this team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _saveTeamWithLoadingIndicator(
                  currentTeam!); // Show loading and save
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _saveTeamWithLoadingIndicator(TeamModel team) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ),
    );

    try {
      await _firestoreService.addTeam(team); // Save the team
      Navigator.pop(context); // Close the loading indicator
      _showSuccessDialog(); // Show success dialog
      setState(() {
        isTeamRegistered = true;
      });
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      _showErrorDialog('Error saving team to database: $e');
    }
  }

  void _saveTeamToDatabase(TeamModel team) async {
    try {
      await _firestoreService.addTeam(team);
      _showSuccessDialog();
      setState(() {
        isTeamRegistered = true;
      });
    } catch (e) {
      _showErrorDialog('Error saving team to database: $e');
    }
  }

  void _fetchData() async {
    FirestoreService firestoreService = FirestoreService();

    try {
      List<TeamModel> teams = await firestoreService.getTeams();
      for (var team in teams) {
        print('Team: ${team.name}, Players: ${team.players.length}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List> streamTeams() async {
    try {
      final List<TeamModel> teamsData = await _firestoreService.getTeams();

      return teamsData;
    } catch (e) {
      _showErrorDialog('Error saving team to database: $e');
      return [];
    }
  }

  void _startPeriodicFetch() {
    
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
            'Add Player ${(currentTeam?.players.length ?? 0) + 1}/6',
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
                      child: Text(gender.toString().split('.').last),
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
                    'player',
                    'Substitute',
                  ].map((role) {
                    bool isDisabled = role == 'Captain' &&
                        (currentTeam?.players
                                .any((player) => player.role == 'Captain') ??
                            false);

                    return DropdownMenuItem<String>(
                      value: isDisabled ? null : role,
                      enabled: !isDisabled,
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isDisabled ? Colors.grey : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                playerNameController.dispose();
                numberController.dispose();
              },
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
                    isCaptain: currentTeam?.players.isEmpty ?? false,
                  ));
                  Navigator.pop(context);
                  playerNameController.dispose();
                  numberController.dispose();
                  if ((currentTeam?.players.length ?? 0) < 6) {
                    _showAddPlayerDialog();
                  } else {
                    Navigator.pop(context);
                    _showSubmitDialog();
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
                    if (isTeamRegistered) ...[
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
