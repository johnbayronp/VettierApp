import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String recordId;
  final String petId;
  final String type; // 'vaccination', 'consultation', 'surgery', 'treatment', 'checkup'
  final String title;
  final String description;
  final DateTime date;
  final String veterinarianId; // ID del veterinario
  final String? clinicId;
  final String? notes;
  final Map<String, dynamic>? details; // Detalles específicos según el tipo
  final String status; // 'completed', 'scheduled', 'cancelled'

  MedicalRecord({
    required this.recordId,
    required this.petId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.veterinarianId,
    this.clinicId,
    this.notes,
    this.details,
    required this.status,
  });

  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return MedicalRecord(
      recordId: doc.id,
      petId: data['petId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      veterinarianId: data['veterinarianId'] ?? '',
      clinicId: data['clinicId'],
      notes: data['notes'],
      details: data['details'] != null ? Map<String, dynamic>.from(data['details']) : null,
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'type': type,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'veterinarianId': veterinarianId,
      'clinicId': clinicId,
      'notes': notes,
      'details': details,
      'status': status,
    };
  }
} 