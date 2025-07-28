import 'package:flutter/foundation.dart';
import '../data/appointment_repository.dart';
import 'appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;
  
  AppointmentProvider({required AppointmentRepository repository})
      : _repository = repository;

  List<Appointment> _appointments = [];
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _confirmedAppointments = [];
  List<Appointment> _cancelledAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Appointment> get appointments => _appointments;
  List<Appointment> get pendingAppointments => _pendingAppointments;
  List<Appointment> get confirmedAppointments => _confirmedAppointments;
  List<Appointment> get cancelledAppointments => _cancelledAppointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Crear nueva cita
  Future<void> createAppointment(Appointment appointment) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _repository.createAppointment(appointment);
      
      // Agregar la nueva cita a la lista local
      _appointments.add(appointment);
      _sortAppointments();
      
      notifyListeners();
    } catch (e) {
      _setError('Error al crear la cita: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar cita
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _repository.updateAppointment(appointment);
      
      // Actualizar la cita en la lista local
      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointment.appointmentId);
      if (index != -1) {
        _appointments[index] = appointment;
        _sortAppointments();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar la cita: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar cita
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _repository.deleteAppointment(appointmentId);
      
      // Remover la cita de la lista local
      _appointments.removeWhere((apt) => apt.appointmentId == appointmentId);
      
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar la cita: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar estado de cita
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _repository.updateAppointmentStatus(appointmentId, status);
      
      // Actualizar el estado en la lista local
      final index = _appointments.indexWhere((apt) => apt.appointmentId == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(status: status);
        _sortAppointments();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar el estado de la cita: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar citas por mascota
  void loadAppointmentsByPet(String petId) {
    _repository.getAppointmentsByPet(petId).listen(
      (appointments) {
        _appointments = appointments;
        _sortAppointments();
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Error al cargar las citas: $error');
      },
    );
  }

  // Cargar citas por clínica
  void loadAppointmentsByClinic(String clinicId) {
    _repository.getAppointmentsByClinic(clinicId).listen(
      (appointments) {
        _appointments = appointments;
        _sortAppointments();
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Error al cargar las citas: $error');
      },
    );
  }

  // Cargar citas por estado
  void loadAppointmentsByStatus(String status) {
    _repository.getAppointmentsByStatus(status).listen(
      (appointments) {
        _appointments = appointments;
        _sortAppointments();
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Error al cargar las citas: $error');
      },
    );
  }

  // Cargar citas próximas del cliente
  void loadUpcomingAppointments(String clientId) {
    _repository.getUpcomingAppointments(clientId).listen(
      (appointments) {
        _upcomingAppointments = appointments;
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Error al cargar las citas próximas: $error');
      },
    );
  }

  // Obtener cita por ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((apt) => apt.appointmentId == appointmentId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar citas por estado
  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments.where((apt) => apt.status == status).toList();
  }

  // Filtrar citas por fecha
  List<Appointment> getAppointmentsByDate(DateTime date) {
    return _appointments.where((apt) {
      final aptDate = apt.date;
      return aptDate.year == date.year &&
             aptDate.month == date.month &&
             aptDate.day == date.day;
    }).toList();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _sortAppointments() {
    _appointments.sort((a, b) => a.date.compareTo(b.date));
  }

  // Limpiar datos
  void clearData() {
    _appointments = [];
    _pendingAppointments = [];
    _confirmedAppointments = [];
    _cancelledAppointments = [];
    _clearError();
    notifyListeners();
  }
} 