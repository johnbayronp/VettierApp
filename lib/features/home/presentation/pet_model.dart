import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String petId;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final String type;
  final String gender;
  final int age;
  final String birthdate;
  final double weight;
  final String photoURL;
  final String medicalNotes;

  Pet({
    required this.petId,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.type,
    required this.gender,
    required this.age,
    required this.birthdate,
    required this.weight,
    required this.photoURL,
    required this.medicalNotes,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Manejo seguro del campo gender
    String genderValue = '';
    try {
      if (data.containsKey('gender') && data['gender'] != null) {
        genderValue = data['gender'].toString();
      }
    } catch (e) {
      print('Error al procesar campo gender: $e');
      genderValue = '';
    }
    
    return Pet(
      petId: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      type: data['type'] ?? '',
      gender: genderValue,
      age: data['age'] ?? 0,
      birthdate: data['birthdate'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      photoURL: data['photoURL'] ?? '',
      medicalNotes: data['medicalNotes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'type': type,
      'gender': gender,
      'age': age,
      'birthdate': birthdate,
      'weight': weight,
      'photoURL': photoURL,
      'medicalNotes': medicalNotes,
    };
  }

  Pet copyWith({
    String? petId,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    String? type,
    String? gender,
    int? age,
    String? birthdate,
    double? weight,
    String? photoURL,
    String? medicalNotes,
  }) {
    return Pet(
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      birthdate: birthdate ?? this.birthdate,
      weight: weight ?? this.weight,
      photoURL: photoURL ?? this.photoURL,
      medicalNotes: medicalNotes ?? this.medicalNotes,
    );
  }

  @override
  String toString() {
    return 'Pet(petId: $petId, ownerId: $ownerId, name: $name, species: $species, breed: $breed, type: $type, gender: $gender, age: $age, birthdate: $birthdate, weight: $weight, photoURL: $photoURL, medicalNotes: $medicalNotes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pet &&
        other.petId == petId &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.species == species &&
        other.breed == breed &&
        other.type == type &&
        other.gender == gender &&
        other.age == age &&
        other.birthdate == birthdate &&
        other.weight == weight &&
        other.photoURL == photoURL &&
        other.medicalNotes == medicalNotes;
  }

  @override
  int get hashCode {
    return petId.hashCode ^
        ownerId.hashCode ^
        name.hashCode ^
        species.hashCode ^
        breed.hashCode ^
        type.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        birthdate.hashCode ^
        weight.hashCode ^
        photoURL.hashCode ^
        medicalNotes.hashCode;
  }
} 