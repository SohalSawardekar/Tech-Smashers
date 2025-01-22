// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String name;
  final List<Player> players;

  TeamModel({
    required this.name,
    List<Player>? players,
  }) : players = players ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'players': players.map((player) => player.toMap()).toList(),
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      name: map['name'] ?? '',
      players: map['players'] == null
          ? []
          : (map['players'] as List)
              .map((playerMap) => Player.fromMap(playerMap))
              .toList(),
    );
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'gender': gender.toString().split('.').last,
      'role': role,
      'isCaptain': isCaptain,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'] ?? '',
      number: map['number'] ?? 0,
      gender: map['gender'] == 'male' ? Gender.male : Gender.female,
      role: map['role'] ?? '',
      isCaptain: map['isCaptain'] ?? false,
    );
  }
}

enum Gender { male, female }
