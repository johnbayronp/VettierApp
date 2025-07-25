import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> createUser({
    required String uid,
    required String name,
    required int age,
    required String location,
    required String email,
  }) async {
    await users.doc(uid).set({
      'uid': uid,
      'name': name,
      'age': age,
      'location': location,
      'email': email,
    });
  }

  Future<void> updateUser({
    required String uid,
    String? name,
    int? age,
    String? location,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (age != null) data['age'] = age;
    if (location != null) data['location'] = location;
    if (email != null) data['email'] = email;
    await users.doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Stream<Map<String, dynamic>?> userStream(String uid) {
    return users.doc(uid).snapshots().map((doc) => doc.data() as Map<String, dynamic>?);
  }
} 