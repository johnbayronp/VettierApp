class Appointment {
  final String id;
  final DateTime dateTime;
  final String clientId;
  final String petId;
  final String veterinarianId;
  final String reason;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.clientId,
    required this.petId,
    required this.veterinarianId,
    required this.reason,
  });
} 