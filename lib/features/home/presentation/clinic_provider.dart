import 'package:flutter/foundation.dart';
import '../data/clinic_repository.dart';
import 'clinic_model.dart';

class ClinicProvider extends ChangeNotifier {
  final ClinicRepository _repository;

  ClinicProvider({required ClinicRepository repository}) : _repository = repository;

  List<Clinic> _clinics = [];
  bool _isLoading = false;
  String? _error;

  List<Clinic> get clinics => _clinics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createClinic(Clinic clinic) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.createClinic(clinic);
      _clinics.add(clinic);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateClinic(Clinic clinic) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateClinic(clinic);
      final index = _clinics.indexWhere((c) => c.id == clinic.id);
      if (index != -1) {
        _clinics[index] = clinic;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteClinic(String clinicId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteClinic(clinicId);
      _clinics.removeWhere((clinic) => clinic.id == clinicId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getClinic(String clinicId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final clinic = await _repository.getClinic(clinicId);
      if (clinic != null) {
        final index = _clinics.indexWhere((c) => c.id == clinicId);
        if (index != -1) {
          _clinics[index] = clinic;
        } else {
          _clinics.add(clinic);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void loadClinicsByCity(String city) {
    _repository.getClinicsByCity(city).listen(
      (clinics) {
        _clinics = clinics;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void loadClinicsByService(String service) {
    _repository.getClinicsByService(service).listen(
      (clinics) {
        _clinics = clinics;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void loadClinicsByRating(double minRating) {
    _repository.getClinicsByRating(minRating).listen(
      (clinics) {
        _clinics = clinics;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void loadAllClinics() {
    _repository.getAllClinics().listen(
      (clinics) {
        _clinics = clinics;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> updateClinicRating(String clinicId, double newRating) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateClinicRating(clinicId, newRating);
      final index = _clinics.indexWhere((c) => c.id == clinicId);
      if (index != -1) {
        _clinics[index] = _clinics[index].copyWith(rating: newRating);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateClinicServices(String clinicId, List<String> services) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateClinicServices(clinicId, services);
      final index = _clinics.indexWhere((c) => c.id == clinicId);
      if (index != -1) {
        _clinics[index] = _clinics[index].copyWith(services: services);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearClinics() {
    _clinics = [];
    notifyListeners();
  }

  Clinic? getClinicById(String clinicId) {
    try {
      return _clinics.firstWhere((clinic) => clinic.id == clinicId);
    } catch (e) {
      return null;
    }
  }

  List<Clinic> getClinicsByCity(String city) {
    return _clinics.where((clinic) => clinic.city == city).toList();
  }

  List<Clinic> getClinicsByService(String service) {
    return _clinics.where((clinic) => clinic.services.contains(service)).toList();
  }

  List<Clinic> getClinicsByRating(double minRating) {
    return _clinics.where((clinic) => clinic.rating >= minRating).toList();
  }
} 