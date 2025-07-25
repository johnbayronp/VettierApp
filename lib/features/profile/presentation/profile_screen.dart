import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRepository = UserRepository();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Perfil', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('No autenticado'))
          : StreamBuilder<Map<String, dynamic>?>(
              stream: userRepository.userStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No hay datos de usuario'));
                }
                final user = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.pink[50],
                        child: const Icon(Icons.person, size: 48, color: Color(0xFF990045)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['name'] ?? '',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3A2B3C)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? '',
                        style: const TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['location'] ?? '',
                        style: const TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Edad: ${user['age'] ?? ''}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF990045)),
                      ),
                      const SizedBox(height: 24),
                      // Aquí puedes agregar más widgets o secciones del perfil
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSavedCard(String title, String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              imagePath,
              height: 70,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _ProfileBottomNavBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, Icons.home_outlined, 'Inicio', 0),
          _buildNavItem(context, Icons.explore_outlined, 'Explora', 1),
          _buildNavItem(context, Icons.person, 'Perfil', 2, selected: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, {bool selected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: selected ? const Color(0xFF990045) : Colors.white,
          radius: 22,
          child: Icon(icon, color: selected ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF990045) : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
} 