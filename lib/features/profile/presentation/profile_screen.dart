import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_provider.dart' as app_auth;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRepository = UserRepository();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
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
                
                final user = snapshot.data;
                final userName = user?['name'] ?? 'Usuario';
                final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                final userLocation = user?['location'] ?? 'Sin ubicación';
                final userAge = user?['age']?.toString() ?? '';
                
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Avatar y información del usuario
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: user?['photoURL'] != null && user!['photoURL'].isNotEmpty
                                    ? NetworkImage(user!['photoURL']) as ImageProvider
                                    : null,
                                child: (user?['photoURL'] == null || user!['photoURL'].isEmpty)
                                    ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Métrica de actividad (pasos diarios)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.directions_walk,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Text(
                                      'Mascotas registradas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Lista de opciones
                        _buildOptionItem(
                          context,
                          icon: Icons.pets,
                          title: 'Mis Mascotas',
                          subtitle: 'Gestionar mascotas registradas',
                          onTap: () {
                            // Navegar a mascotas
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildOptionItem(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Mis Citas',
                          subtitle: 'Ver historial de citas',
                          onTap: () {
                            // Navegar a citas
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildOptionItem(
                          context,
                          icon: Icons.favorite,
                          title: 'Favoritos',
                          subtitle: 'Clínicas y veterinarios favoritos',
                          onTap: () {
                            // Navegar a favoritos
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildOptionItem(
                          context,
                          icon: Icons.settings,
                          title: 'Configuración',
                          subtitle: 'Ajustes de la aplicación',
                          onTap: () {
                            // Navegar a configuración
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildOptionItem(
                          context,
                          icon: Icons.notifications,
                          title: 'Notificaciones',
                          subtitle: 'Gestionar alertas',
                          onTap: () {
                            // Navegar a notificaciones
                          },
                          showToggle: true,
                        ),
                        const SizedBox(height: 32),
                        
                        // Botón de cerrar sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Cerrar Sesión'),
                                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Cerrar Sesión'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              
                              if (shouldLogout == true) {
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error al cerrar sesión'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.red[300]!),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text(
                                  'Cerrar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showToggle = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (showToggle)
            Switch(
              value: false,
              onChanged: (value) {
                // Manejar toggle
              },
              activeColor: const Color(0xFF990045),
            )
          else
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
} 