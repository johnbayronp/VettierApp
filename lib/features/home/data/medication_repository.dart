import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/medication_model.dart';

abstract class MedicationRepository {
  Future<void> createMedication(Medication medication);
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(String medicationId);
  Future<Medication?> getMedication(String medicationId);
  Stream<List<Medication>> getMedicationsByPet(String petId);
  Stream<List<Medication>> getActiveMedicationsByPet(String petId);
  Stream<List<Medication>> getMedicationsByVeterinarian(String veterinarianId);
  Stream<List<Medication>> getAllMedications();
  Future<void> updateMedicationStatus(String medicationId, String status);
}

class FirebaseMedicationRepository implements MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medications';

  @override
  Future<void> createMedication(Medication medication) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(medication.medicationId)
          .set(medication.toFirestore());
    } catch (e) {
      throw Exception('Error al crear medicamento: $e');
    }
  }

  @override
  Future<void> updateMedication(Medication medication) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(medication.medicationId)
          .update(medication.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar medicamento: $e');
    }
  }

  @override
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _firestore.collection(_collection).doc(medicationId).delete();
    } catch (e) {
      throw Exception('Error al eliminar medicamento: $e');
    }
  }

  @override
  Future<Medication?> getMedication(String medicationId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(medicationId).get();
      if (doc.exists) {
        return Medication.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener medicamento: $e');
    }
  }

  @override
  Stream<List<Medication>> getMedicationsByPet(String petId) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Medication>> getActiveMedicationsByPet(String petId) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .where('status', isEqualTo: 'active')
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Medication>> getMedicationsByVeterinarian(String veterinarianId) {
    return _firestore
        .collection(_collection)
        .where('prescribedBy', isEqualTo: veterinarianId)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Medication>> getAllMedications() {
    return _firestore
        .collection(_collection)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updateMedicationStatus(String medicationId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(medicationId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error al actualizar estado del medicamento: $e');
    }
  }
} 