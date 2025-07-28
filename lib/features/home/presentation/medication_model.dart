import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String medicationId;
  final String petId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active', 'completed', 'discontinued'
  final String? notes;
  final String prescribedBy; // ID del veterinario
  final DateTime prescribedDate;

  Medication({
    required this.medicationId,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes,
    required this.prescribedBy,
    required this.prescribedDate,
  });

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Medication(
      medicationId: doc.id,
      petId: data['petId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      status: data['status'] ?? 'active',
      notes: data['notes'],
      prescribedBy: data['prescribedBy'] ?? '',
      prescribedDate: (data['prescribedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'notes': notes,
      'prescribedBy': prescribedBy,
      'prescribedDate': Timestamp.fromDate(prescribedDate),
    };
  }
} 