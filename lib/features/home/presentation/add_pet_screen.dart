import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'pet_model.dart';
import '../data/pet_repository.dart';

class AddPetScreen extends StatefulWidget {
  final Map<String, dynamic>? petToEdit;
  
  const AddPetScreen({Key? key, this.petToEdit}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _selectedType;
  String? _selectedGender;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> petTypes = [
    'Perro',
    'Gato',
    'Ave',
    'Reptil',
    'Otro',
  ];

  final List<String> genders = [
    'Macho',
    'Hembra',
  ];

  @override
  void initState() {
    super.initState();
    // Si estamos editando una mascota, cargar los datos existentes
    if (widget.petToEdit != null) {
      _nameController.text = widget.petToEdit!['name'] ?? '';
      _breedController.text = widget.petToEdit!['breed'] ?? '';
      _ageController.text = widget.petToEdit!['age']?.toString() ?? '';
      _selectedType = widget.petToEdit!['type'];
      _selectedGender = widget.petToEdit!['gender'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _medicalNotesController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error seleccionando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: const Text('¿De dónde quieres seleccionar la imagen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear ID único para la mascota
      final petId = 'pet_${DateTime.now().millisecondsSinceEpoch}';
      
      // Crear objeto Pet
      final pet = Pet(
        petId: petId,
        ownerId: user.uid,
        name: _nameController.text.trim(),
        species: _selectedType ?? 'Dog',
        breed: _breedController.text.trim(),
        type: _selectedType ?? 'Perro',
        gender: _selectedGender ?? 'Macho',
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        birthdate: DateTime.now().subtract(Duration(days: (int.tryParse(_ageController.text.trim()) ?? 0) * 365)).toIso8601String(),
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        photoURL: '', // Por ahora vacío, se puede implementar subida de imagen
        medicalNotes: _medicalNotesController.text.trim(),
      );

      // Guardar en Firebase
      final repository = FirebasePetRepository();
      await repository.createPet(pet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡${_nameController.text.trim()} ha sido agregado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error guardando mascota: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar mascota: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.purple,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.petToEdit != null ? 'Editar mascota' : 'Agregar mascota',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Para balancear el header
                ],
              ),
            ),

            SizedBox(height: 24),

            // Contenido del formulario
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto de la mascota
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showImagePickerDialog,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(
                                          _selectedImage!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey[600],
                                      ),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: _showImagePickerDialog,
                              child: Text(
                                'Agregar foto',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Nombre de la mascota
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre de la mascota',
                        hint: 'Ej: Max, Luna, Rocky',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el nombre';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Tipo de mascota
                      _buildDropdownField(
                        label: 'Tipo de mascota',
                        value: _selectedType,
                        items: petTypes,
                        onChanged: (value) => setState(() => _selectedType = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona el tipo';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Raza
                      _buildTextField(
                        controller: _breedController,
                        label: 'Raza',
                        hint: 'Ej: Golden Retriever, Siames',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la raza';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Género
                      _buildDropdownField(
                        label: 'Género',
                        value: _selectedGender,
                        items: genders,
                        onChanged: (value) => setState(() => _selectedGender = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona el género';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Edad
                      _buildTextField(
                        controller: _ageController,
                        label: 'Edad (años)',
                        hint: 'Ej: 3',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la edad';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Por favor ingresa un número válido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Peso
                      _buildTextField(
                        controller: _weightController,
                        label: 'Peso (kg)',
                        hint: 'Ej: 15.5',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el peso';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingresa un número válido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Notas médicas
                      _buildTextField(
                        controller: _medicalNotesController,
                        label: 'Notas médicas (opcional)',
                        hint: 'Información médica importante...',
                        validator: (value) => null, // Opcional
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Botón de guardar
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.petToEdit != null ? 'Guardar cambios' : 'Guardar mascota',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            hint: Text('Seleccionar...'),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
} 