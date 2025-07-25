import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userRepo = UserRepository();
      final user = await userRepo.getUser(uid);
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _countryController.text = user['location'] ?? '';
        _ageController.text = user['age']?.toString() ?? '';
        // Puedes cargar bio y tratamiento si los tienes en Firestore
      }
    }
    setState(() { _loading = false; });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _treatmentController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F2F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Guardar', style: TextStyle(color: Color(0xFF990045), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.pink[50],
                        child: const Icon(Icons.person, size: 48, color: Color(0xFF990045)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Edad'),
                    ),
                    // Puedes agregar más campos aquí
                  ],
                ),
              ),
            ),
    );
  }
} 