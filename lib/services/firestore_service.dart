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

  Future<List<TeamModel>> getTeams() async {
    try {
      // Fetch the documents from the 'teams' collection
      final querySnapshot = await _firestore.collection('teams').get();

      // Map the documents into a list of TeamModel
      return querySnapshot.docs.map((doc) {
        return TeamModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching teams: $e');
      throw Exception('Failed to fetch teams');
    }
  }
}
