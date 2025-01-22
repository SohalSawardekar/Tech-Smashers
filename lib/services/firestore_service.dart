import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_smash/models/teamModel.dart'; // Your Team model

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new team to the 'teams' collection
  Future<void> addTeam(TeamModel team) async {
    try {
      await _firestore.collection('teams').add(team.toMap());
      print('Team added successfully!');
    } catch (e) {
      print('Error adding team: $e');
    }
  }

  // Get all teams
  // Future<List<TeamModel>> getTeams() async {
  //   try {
  //     final querySnapshot = await _firestore.collection('teams').get();
  //     return querySnapshot.docs
  //         .map((doc) => TeamModel.fromMap(doc.data()))
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching teams: $e');
  //     throw Exception('Failed to fetch teams');
  //   }
  // }
}
