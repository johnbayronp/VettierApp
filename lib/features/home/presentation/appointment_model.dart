import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String appointmentId;
  final String petId;
  final String clientId;
  final String veterinarianId;
  final String clinicId;
  final String reason;
  final DateTime date;
  final String status;
  final String notes;

  Appointment({
    required this.appointmentId,
    required this.petId,
    required this.clientId,
    required this.veterinarianId,
    required this.clinicId,
    required this.reason,
    required this.date,
    required this.status,
    required this.notes,
  });

  // Constructor desde Firestore
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      appointmentId: doc.id,
      petId: data['petId'] ?? '',
      clientId: data['clientId'] ?? '',
      veterinarianId: data['veterinarianId'] ?? '',
      clinicId: data['clinicId'] ?? '',
      reason: data['reason'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'clientId': clientId,
      'veterinarianId': veterinarianId,
      'clinicId': clinicId,
      'reason': reason,
      'date': Timestamp.fromDate(date),
      'status': status,
      'notes': notes,
    };
  }

  // Copiar con cambios
  Appointment copyWith({
    String? appointmentId,
    String? petId,
    String? clientId,
    String? veterinarianId,
    String? clinicId,
    String? reason,
    DateTime? date,
    String? status,
    String? notes,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      petId: petId ?? this.petId,
      clientId: clientId ?? this.clientId,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      clinicId: clinicId ?? this.clinicId,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Appointment(appointmentId: $appointmentId, petId: $petId, clientId: $clientId, veterinarianId: $veterinarianId, clinicId: $clinicId, reason: $reason, date: $date, status: $status, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment &&
        other.appointmentId == appointmentId &&
        other.petId == petId &&
        other.clientId == clientId &&
        other.veterinarianId == veterinarianId &&
        other.clinicId == clinicId &&
        other.reason == reason &&
        other.date == date &&
        other.status == status &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return appointmentId.hashCode ^
        petId.hashCode ^
        clientId.hashCode ^
        veterinarianId.hashCode ^
        clinicId.hashCode ^
        reason.hashCode ^
        date.hashCode ^
        status.hashCode ^
        notes.hashCode;
  }
} 