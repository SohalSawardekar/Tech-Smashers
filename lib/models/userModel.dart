class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String role; // e.g., "admin" or "user"

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
  });

  /// Create a UserModel from a Firestore document snapshot map.
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  /// Convert this object to a map for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'role': role,
    };
  }
}
