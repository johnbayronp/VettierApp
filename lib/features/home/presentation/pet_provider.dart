import 'package:flutter/foundation.dart';
import '../data/pet_repository.dart';
import 'pet_model.dart';

class PetProvider extends ChangeNotifier {
  final PetRepository _repository;

  PetProvider({required PetRepository repository})
      : _repository = repository;

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Métodos CRUD
  Future<void> createPet(Pet pet) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.createPet(pet);
      _pets.add(pet);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePet(Pet pet) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updatePet(pet);
      final index = _pets.indexWhere((p) => p.petId == pet.petId);
      if (index != -1) {
        _pets[index] = pet;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deletePet(petId);
      _pets.removeWhere((pet) => pet.petId == petId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getPet(String petId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final pet = await _repository.getPet(petId);
      if (pet != null) {
        final index = _pets.indexWhere((p) => p.petId == petId);
        if (index != -1) {
          _pets[index] = pet;
        } else {
          _pets.add(pet);
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

  // Métodos de consulta
  void loadPetsByOwner(String ownerId) {
    _repository.getPetsByOwner(ownerId).listen((pets) {
      _pets = pets;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  void loadPetsBySpecies(String species) {
    _repository.getPetsBySpecies(species).listen((pets) {
      _pets = pets;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  void loadPetsByBreed(String breed) {
    _repository.getPetsByBreed(breed).listen((pets) {
      _pets = pets;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  void loadAllPets() {
    _repository.getAllPets().listen((pets) {
      _pets = pets;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  // Métodos de actualización específicos
  Future<void> updatePetMedicalNotes(String petId, String medicalNotes) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updatePetMedicalNotes(petId, medicalNotes);
      final index = _pets.indexWhere((pet) => pet.petId == petId);
      if (index != -1) {
        _pets[index] = _pets[index].copyWith(medicalNotes: medicalNotes);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePetPhoto(String petId, String photoURL) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updatePetPhoto(petId, photoURL);
      final index = _pets.indexWhere((pet) => pet.petId == petId);
      if (index != -1) {
        _pets[index] = _pets[index].copyWith(photoURL: photoURL);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Métodos de utilidad
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearPets() {
    _pets = [];
    notifyListeners();
  }

  Pet? getPetById(String petId) {
    try {
      return _pets.firstWhere((pet) => pet.petId == petId);
    } catch (e) {
      return null;
    }
  }

  List<Pet> getPetsByOwnerId(String ownerId) {
    return _pets.where((pet) => pet.ownerId == ownerId).toList();
  }
} 