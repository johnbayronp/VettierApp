import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/appointment_model.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment(Appointment appointment);
  Future<void> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String appointmentId);
  Future<Appointment?> getAppointment(String appointmentId);
  Stream<List<Appointment>> getAppointmentsByClient(String clientId);
  Stream<List<Appointment>> getAppointmentsByPet(String petId);
  Stream<List<Appointment>> getAppointmentsByClinic(String clinicId);
  Stream<List<Appointment>> getAppointmentsByStatus(String status);
  Stream<List<Appointment>> getUpcomingAppointments(String clientId);
  Stream<List<Appointment>> getUpcomingAppointmentsByPet(String petId);
  Stream<List<Appointment>> getAllAppointments();
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> addAppointmentNotes(String appointmentId, String notes);
}

class FirebaseAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  @override
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.appointmentId)
          .set(appointment.toFirestore());
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.appointmentId)
          .update(appointment.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Error al eliminar cita: $e');
    }
  }

  @override
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(appointmentId).get();
      if (doc.exists) {
        return Appointment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener cita: $e');
    }
  }

  @override
  Stream<List<Appointment>> getAppointmentsByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Appointment>> getAppointmentsByPet(String petId) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Appointment>> getAppointmentsByClinic(String clinicId) {
    return _firestore
        .collection(_collection)
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Appointment>> getAppointmentsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<Appointment>> getUpcomingAppointments(String clientId) {
    final now = DateTime.now();
    return _firestore
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .where('date', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return Appointment.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          }).where((appointment) => 
            appointment != null && 
            appointment.status.toLowerCase() != 'cancelada'
          ).cast<Appointment>().toList();
        });
  }

  @override
  Stream<List<Appointment>> getUpcomingAppointmentsByPet(String petId) {
    final now = DateTime.now();
    return _firestore
        .collection('appointments')
        .where('petId', isEqualTo: petId)
        .where('date', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return Appointment.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          }).where((appointment) => 
            appointment != null && 
            appointment.status.toLowerCase() != 'cancelada'
          ).cast<Appointment>().toList();
        });
  }

  @override
  Stream<List<Appointment>> getAllAppointments() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Error al actualizar estado de cita: $e');
    }
  }

  @override
  Future<void> addAppointmentNotes(String appointmentId, String notes) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update({'notes': notes});
    } catch (e) {
      throw Exception('Error al agregar notas de cita: $e');
    }
  }
} 