import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/pet_model.dart';

abstract class PetRepository {
  Future<void> createPet(Pet pet);
  Future<void> updatePet(Pet pet);
  Future<void> deletePet(String petId);
  Future<Pet?> getPet(String petId);
  Stream<List<Pet>> getPetsByOwner(String ownerId);
  Stream<List<Pet>> getPetsBySpecies(String species);
  Stream<List<Pet>> getPetsByBreed(String breed);
  Stream<List<Pet>> getAllPets();
  Future<void> updatePetMedicalNotes(String petId, String medicalNotes);
  Future<void> updatePetPhoto(String petId, String photoURL);
}

class FirebasePetRepository implements PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pets';

  @override
  Future<void> createPet(Pet pet) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(pet.petId)
          .set(pet.toFirestore());
    } catch (e) {
      throw Exception('Error al crear mascota: $e');
    }
  }

  @override
  Future<void> updatePet(Pet pet) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(pet.petId)
          .update(pet.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar mascota: $e');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection(_collection).doc(petId).delete();
    } catch (e) {
      throw Exception('Error al eliminar mascota: $e');
    }
  }

  @override
  Future<Pet?> getPet(String petId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(petId).get();
      if (doc.exists) {
        return Pet.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener mascota: $e');
    }
  }

  @override
  Stream<List<Pet>> getPetsByOwner(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Pet>> getPetsBySpecies(String species) {
    return _firestore
        .collection(_collection)
        .where('species', isEqualTo: species)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Pet>> getPetsByBreed(String breed) {
    return _firestore
        .collection(_collection)
        .where('breed', isEqualTo: breed)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Pet>> getAllPets() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updatePetMedicalNotes(String petId, String medicalNotes) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(petId)
          .update({'medicalNotes': medicalNotes});
    } catch (e) {
      throw Exception('Error al actualizar notas médicas: $e');
    }
  }

  @override
  Future<void> updatePetPhoto(String petId, String photoURL) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(petId)
          .update({'photoURL': photoURL});
    } catch (e) {
      throw Exception('Error al actualizar foto: $e');
    }
  }
} 