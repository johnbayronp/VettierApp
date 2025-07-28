import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoURL;
  final String role;
  final Map<String, String> address;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? specialty;
  final String? clinicId;
  final String? experience;
  final String? education;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoURL,
    required this.role,
    required this.address,
    required this.createdAt,
    required this.lastLogin,
    this.specialty,
    this.clinicId,
    this.experience,
    this.education,
  });

  // Factory constructor para crear un User desde Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return User(
      uid: doc.id, // Usar el ID del documento como uid
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? 'client',
      address: Map<String, String>.from(data['address'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      specialty: data['specialty'],
      clinicId: data['clinicId'],
      experience: data['experience'],
      education: data['education'],
    );
  }

  // Método para convertir User a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoURL': photoURL,
      'role': role,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      if (specialty != null) 'specialty': specialty,
      if (clinicId != null) 'clinicId': clinicId,
      if (experience != null) 'experience': experience,
      if (education != null) 'education': education,
    };
  }

  // Método para crear una copia del User con algunos campos modificados
  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoURL,
    String? role,
    Map<String, String>? address,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? specialty,
    String? clinicId,
    String? experience,
    String? education,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      specialty: specialty ?? this.specialty,
      clinicId: clinicId ?? this.clinicId,
      experience: experience ?? this.experience,
      education: education ?? this.education,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
} 