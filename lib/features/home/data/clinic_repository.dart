import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/clinic_model.dart';

abstract class ClinicRepository {
  Future<void> createClinic(Clinic clinic);
  Future<void> updateClinic(Clinic clinic);
  Future<void> deleteClinic(String clinicId);
  Future<Clinic?> getClinic(String clinicId);
  Stream<List<Clinic>> getClinicsByCity(String city);
  Stream<List<Clinic>> getClinicsByService(String service);
  Stream<List<Clinic>> getClinicsByRating(double minRating);
  Stream<List<Clinic>> getAllClinics();
  Future<void> updateClinicRating(String clinicId, double newRating);
  Future<void> updateClinicServices(String clinicId, List<String> services);
}

class FirebaseClinicRepository implements ClinicRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clinics';

  @override
  Future<void> createClinic(Clinic clinic) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clinic.id)
          .set(clinic.toFirestore());
    } catch (e) {
      throw Exception('Error al crear la clínica: $e');
    }
  }

  @override
  Future<void> updateClinic(Clinic clinic) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clinic.id)
          .update(clinic.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar la clínica: $e');
    }
  }

  @override
  Future<void> deleteClinic(String clinicId) async {
    try {
      await _firestore.collection(_collection).doc(clinicId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la clínica: $e');
    }
  }

  @override
  Future<Clinic?> getClinic(String clinicId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(clinicId)
          .get();
      
      if (doc.exists) {
        return Clinic.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener la clínica: $e');
    }
  }

  @override
  Stream<List<Clinic>> getClinicsByCity(String city) {
    return _firestore
        .collection(_collection)
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Clinic.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Clinic>> getClinicsByService(String service) {
    return _firestore
        .collection(_collection)
        .where('services', arrayContains: service)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Clinic.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Clinic>> getClinicsByRating(double minRating) {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThanOrEqualTo: minRating)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Clinic.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Clinic>> getAllClinics() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Clinic.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updateClinicRating(String clinicId, double newRating) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clinicId)
          .update({'rating': newRating});
    } catch (e) {
      throw Exception('Error al actualizar la calificación de la clínica: $e');
    }
  }

  @override
  Future<void> updateClinicServices(String clinicId, List<String> services) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clinicId)
          .update({'services': services});
    } catch (e) {
      throw Exception('Error al actualizar los servicios de la clínica: $e');
    }
  }
} 