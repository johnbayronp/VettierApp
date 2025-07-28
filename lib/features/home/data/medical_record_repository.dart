import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/medical_record_model.dart';

abstract class MedicalRecordRepository {
  Future<void> createMedicalRecord(MedicalRecord record);
  Future<void> updateMedicalRecord(MedicalRecord record);
  Future<void> deleteMedicalRecord(String recordId);
  Future<MedicalRecord?> getMedicalRecord(String recordId);
  Stream<List<MedicalRecord>> getMedicalRecordsByPet(String petId);
  Stream<List<MedicalRecord>> getMedicalRecordsByType(String petId, String type);
  Stream<List<MedicalRecord>> getMedicalRecordsByVeterinarian(String veterinarianId);
  Stream<List<MedicalRecord>> getAllMedicalRecords();
  Future<void> updateMedicalRecordStatus(String recordId, String status);
}

class FirebaseMedicalRecordRepository implements MedicalRecordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medical_records';

  @override
  Future<void> createMedicalRecord(MedicalRecord record) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(record.recordId)
          .set(record.toFirestore());
    } catch (e) {
      throw Exception('Error al crear registro médico: $e');
    }
  }

  @override
  Future<void> updateMedicalRecord(MedicalRecord record) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(record.recordId)
          .update(record.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar registro médico: $e');
    }
  }

  @override
  Future<void> deleteMedicalRecord(String recordId) async {
    try {
      await _firestore.collection(_collection).doc(recordId).delete();
    } catch (e) {
      throw Exception('Error al eliminar registro médico: $e');
    }
  }

  @override
  Future<MedicalRecord?> getMedicalRecord(String recordId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(recordId).get();
      if (doc.exists) {
        return MedicalRecord.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener registro médico: $e');
    }
  }

  @override
  Stream<List<MedicalRecord>> getMedicalRecordsByPet(String petId) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<MedicalRecord>> getMedicalRecordsByType(String petId, String type) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<MedicalRecord>> getMedicalRecordsByVeterinarian(String veterinarianId) {
    return _firestore
        .collection(_collection)
        .where('veterinarianId', isEqualTo: veterinarianId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<MedicalRecord>> getAllMedicalRecords() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updateMedicalRecordStatus(String recordId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error al actualizar estado del registro médico: $e');
    }
  }
} 