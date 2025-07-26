import 'package:flutter/material.dart';
import 'package:mirallapp/dummy/mock_data.dart';

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
  final _ageController = TextEditingController();
  String? _selectedType;
  String? _selectedGender;

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
    _ageController.dispose();
    super.dispose();
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
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                // Aquí iría la lógica para seleccionar foto
                              },
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
                  onPressed: _savePet,
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
                  child: Text(
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
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
          hint: Text('Seleccionar...'),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      if (widget.petToEdit != null) {
        // Editar mascota existente
        final petIndex = pets.indexWhere((pet) => pet['id'] == widget.petToEdit!['id']);
        if (petIndex != -1) {
          pets[petIndex] = {
            ...widget.petToEdit!,
            'name': _nameController.text,
            'type': _selectedType,
            'breed': _breedController.text,
            'gender': _selectedGender,
            'age': int.parse(_ageController.text),
          };
        }

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mascota actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Crear nueva mascota
        final newPet = {
          'id': 'pet${pets.length + 1}',
          'name': _nameController.text,
          'type': _selectedType,
          'breed': _breedController.text,
          'gender': _selectedGender,
          'age': int.parse(_ageController.text),
          'ownerId': 'user1', // Asumiendo que es el usuario actual
          'image': '', // Por ahora vacío, se puede implementar después
        };

        // Agregar a la lista de mascotas
        pets.add(newPet);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mascota agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Regresar a la pantalla anterior
      Navigator.pop(context);
    }
  }
} 