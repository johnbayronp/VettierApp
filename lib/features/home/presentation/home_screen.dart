import 'package:mirallapp/dummy/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mirallapp/features/home/presentation/map_screen.dart';
import 'package:mirallapp/features/home/presentation/clinic_detail_screen.dart';
import 'package:mirallapp/features/home/presentation/add_pet_screen.dart';
import 'package:mirallapp/features/home/presentation/pet_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/pet_repository.dart';
import '../data/appointment_repository.dart';
import '../data/clinic_repository.dart';
import 'pet_model.dart';
import 'appointment_model.dart';
import 'clinic_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String selectedService = 'Salud';
  String userLocation = 'Ciudad';
  double? userLat;
  double? userLng;
  int selectedRadius = 10000; // 10 km por defecto
  String userName = 'Usuario'; // Valor por defecto
  bool isLoadingUser = true;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadCachedLocation(); // Cargar ubicación desde caché primero
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Ya no actualizamos automáticamente al volver a la app
  }

  Future<void> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCity = prefs.getString('cached_city');
      final cachedLat = prefs.getDouble('cached_lat');
      final cachedLng = prefs.getDouble('cached_lng');
      final lastUpdate = prefs.getInt('location_last_update');
      
      if (cachedCity != null && cachedLat != null && cachedLng != null && lastUpdate != null) {
        // Verificar si la caché tiene menos de 24 horas
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheAge = now - lastUpdate;
        final maxAge = 24 * 60 * 60 * 1000; // 24 horas en milisegundos
        
        if (cacheAge < maxAge) {
          // Usar ubicación en caché
          setState(() {
            userLocation = cachedCity;
            userLat = cachedLat;
            userLng = cachedLng;
          });
          return;
        }
      }
      
      // Si no hay caché válida, cargar ubicación por defecto
      setState(() {
        userLocation = 'Ciudad';
        userLat = null;
        userLng = null;
      });
    } catch (e) {
      print('Error al cargar ubicación en caché: $e');
      setState(() {
        userLocation = 'Ciudad';
        userLat = null;
        userLng = null;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          final userData = docSnapshot.data();
          setState(() {
            userName = userData?['name'] ?? 'Usuario';
            userLocation = userData?['address']?['city'] ?? 'Ciudad';
            isLoadingUser = false;
          });
        } else {
          setState(() {
            isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  Future<void> _updateCity() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Si no está habilitado, mantener la ubicación por defecto
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Si el usuario niega el permiso, mantener la ubicación por defecto
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Si el permiso está denegado permanentemente, mantener la ubicación por defecto
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Timeout de 10 segundos
      );

      // Obtener el nombre de la ciudad usando geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      String city = '';
      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality ?? 
               placemarks.first.administrativeArea ?? 
               placemarks.first.subAdministrativeArea ?? 
               '';
      }

      // Actualizar el estado solo si se obtuvo una ciudad válida
      if (city.isNotEmpty) {
        setState(() {
          userLat = position.latitude;
          userLng = position.longitude;
          userLocation = city;
          isLoadingLocation = false;
        });

        // Guardar en caché
        await _saveLocationToCache(city, position.latitude, position.longitude);
      } else {
        setState(() {
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      // En caso de error, mantener la ubicación por defecto
      print('Error al obtener ubicación: $e');
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveLocationToCache(String city, double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_city', city);
      await prefs.setDouble('cached_lat', lat);
      await prefs.setDouble('cached_lng', lng);
      await prefs.setInt('location_last_update', DateTime.now().millisecondsSinceEpoch);
      print('Ubicación guardada en caché: $city');
    } catch (e) {
      print('Error al guardar ubicación en caché: $e');
    }
  }

  Future<void> _clearLocationCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_city');
      await prefs.remove('cached_lat');
      await prefs.remove('cached_lng');
      await prefs.remove('location_last_update');
      
      setState(() {
        userLocation = 'Ciudad';
        userLat = null;
        userLng = null;
      });
      
      print('Caché de ubicación limpiada');
    } catch (e) {
      print('Error al limpiar caché de ubicación: $e');
    }
  }

  void _showLocationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: const Text('Actualizar ubicación'),
                subtitle: const Text('Obtener ubicación actual'),
                onTap: () {
                  Navigator.pop(context);
                  _updateCity();
                },
              ),
              if (userLat != null && userLng != null)
                ListTile(
                  leading: const Icon(Icons.clear, color: Colors.red),
                  title: const Text('Limpiar caché'),
                  subtitle: const Text('Eliminar ubicación guardada'),
                  onTap: () {
                    Navigator.pop(context);
                    _clearLocationCache();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.grey),
                title: const Text('Información'),
                subtitle: const Text('La ubicación se guarda por 24 horas'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final List<Map<String, dynamic>> petsList = pets;
    final List<Map<String, dynamic>> clinicsList = clinics;
    final filteredClinics = clinicsList.where((c) {
      final services = c['services'];
      if (services is! List) return false;
      if (userLat == null || userLng == null) return false;
      final double clinicLat = (c['latitude'] as num?)?.toDouble() ?? 0.0;
      final double clinicLng = (c['longitude'] as num?)?.toDouble() ?? 0.0;
      final double distance = Geolocator.distanceBetween(userLat!, userLng!, clinicLat, clinicLng);
      return services.contains(selectedService) && distance <= selectedRadius;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: GestureDetector(
          onTap: _updateCity,
          onLongPress: () => _showLocationMenu(context),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 4),
              if (isLoadingLocation)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                )
              else
                Expanded(
                  child: Row(
                    children: [
                      Text(userLocation, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                      if (userLat != null && userLng != null)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Caché',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.map, color: Colors.deepPurple, size: 28),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MapScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              if (isLoadingUser)
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Cargando...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                )
              else
                Text('Hola, $userName,', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              const Text('¡Cuidemos a tus mascotas!', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              // Tarjeta de próxima cita usando datos reales
              if (user != null)
                _NextAppointmentStreamBuilder(user: user)
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No tienes próximas citas'),
                  ),
                ),
              const SizedBox(height: 28),
              // Accesos rápidos con filtrado dinámico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    icon: Icons.medical_services,
                    label: 'Salud',
                    color: Colors.deepPurple,
                    selected: selectedService == 'Salud',
                    onTap: () => setState(() => selectedService = 'Salud'),
                  ),
                  _QuickAction(
                    icon: Icons.cut,
                    label: 'Peluquería',
                    color: Colors.orange,
                    selected: selectedService == 'Peluquería',
                    onTap: () => setState(() => selectedService = 'Peluquería'),
                  ),
                  _QuickAction(
                    icon: Icons.pets,
                    label: 'Consulta',
                    color: Colors.pinkAccent,
                    selected: selectedService == 'Consulta',
                    onTap: () => setState(() => selectedService = 'Consulta'),
                  ),
                  _QuickAction(
                    icon: Icons.restaurant,
                    label: 'Nutrición',
                    color: Colors.amber,
                    selected: selectedService == 'Nutrición',
                    onTap: () => setState(() => selectedService = 'Nutrición'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Clínicas veterinarias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF990045).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF990045)),
                        const SizedBox(width: 4),
                        Text(
                          '${(selectedRadius / 1000).toStringAsFixed(0)} km a la redonda',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF990045), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadiusBadge(label: '1 km', value: 1000, selected: selectedRadius == 1000, onTap: () => setState(() => selectedRadius = 1000)),
                  SizedBox(width: 8),
                  _RadiusBadge(label: '5 km', value: 5000, selected: selectedRadius == 5000, onTap: () => setState(() => selectedRadius = 5000)),
                  SizedBox(width: 8),
                  _RadiusBadge(label: '10 km', value: 10000, selected: selectedRadius == 10000, onTap: () => setState(() => selectedRadius = 10000)),
                  SizedBox(width: 8),
                  _RadiusBadge(label: '20 km', value: 20000, selected: selectedRadius == 20000, onTap: () => setState(() => selectedRadius = 20000)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: filteredClinics.isEmpty
                  ? Center(child: Text('No hay clínicas cercanas para este servicio.', style: TextStyle(color: Colors.black54, fontSize: 16)))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredClinics.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final clinic = filteredClinics[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClinicDetailScreen(clinic: clinic),
                              ),
                            );
                          },
                          child: _ClinicCard(
                            name: clinic['name'] ?? 'Clínica sin nombre',
                            image: clinic['image'] ?? 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800',
                            address: clinic['address'] ?? 'Dirección no disponible',
                            rating: clinic['rating'] ?? 0.0,
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mis Mascotas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepOrange, size: 32),
                    onPressed: () => _openAddPetScreen(),
                  ),
                ],
              ),
              SizedBox(
                height: 160,
                child: StreamBuilder<List<Pet>>(
                  stream: FirebasePetRepository().getPetsByOwner(FirebaseAuth.instance.currentUser?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    final petsList = snapshot.data ?? [];
                    
                    if (petsList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 48, color: Colors.grey[400]),
                            SizedBox(height: 8),
                            Text(
                              'No tienes mascotas registradas',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: petsList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final pet = petsList[i];
                        return GestureDetector(
                          onTap: () {
                            // Convertir Pet a Map para compatibilidad con PetDetailScreen
                            final petMap = {
                              'petId': pet.petId,
                              'name': pet.name,
                              'type': pet.type,
                              'breed': pet.breed,
                              'age': pet.age,
                              'weight': pet.weight,
                              'image': pet.photoURL.isNotEmpty ? pet.photoURL : 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200&h=200&fit=crop',
                              'gender': pet.gender ?? '',
                              'medicalNotes': pet.medicalNotes,
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailScreen(pet: petMap),
                              ),
                            );
                          },
                          child: _PetCard(
                            name: pet.name, 
                            image: pet.photoURL.isNotEmpty ? pet.photoURL : 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200&h=200&fit=crop',
                            type: pet.type,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddPetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(),
      ),
    ).then((_) {
      // Refrescar la pantalla después de agregar una mascota
      setState(() {});
    });
  }
}

class _NextAppointmentStreamBuilder extends StatelessWidget {
  final User user;

  const _NextAppointmentStreamBuilder({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: FirebaseAppointmentRepository().getUpcomingAppointments(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Cargando citas...', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text('Error al cargar citas', style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text('No tienes próximas citas', style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        final nextAppointment = appointments.first;
        return StreamBuilder<List<Pet>>(
          stream: FirebasePetRepository().getPetsByOwner(user.uid),
          builder: (context, petSnapshot) {
            if (petSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Cargando datos...', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              );
            }

            final pets = petSnapshot.data ?? [];
            final pet = pets.firstWhere(
              (p) => p.petId == nextAppointment.petId,
              orElse: () => Pet(
                petId: '',
                ownerId: '',
                name: 'Mascota no encontrada',
                species: '',
                breed: '',
                type: '',
                gender: '',
                age: 0,
                birthdate: '',
                weight: 0.0,
                photoURL: '',
                medicalNotes: '',
              ),
            );

            return FutureBuilder<Clinic?>(
              future: FirebaseClinicRepository().getClinic(nextAppointment.clinicId),
              builder: (context, clinicSnapshot) {
                final clinicName = clinicSnapshot.data?.name ?? 'Clínica no encontrada';
                
                return _NextAppointmentCard(
                  appointment: {
                    'reason': nextAppointment.reason,
                    'date': nextAppointment.date,
                  },
                  pet: {
                    'name': pet.name,
                  },
                  clinic: {
                    'name': clinicName,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: selected ? color : color.withOpacity(0.15),
            radius: 28,
            child: Icon(icon, color: selected ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}

// Tarjeta mejorada de próxima cita
class _NextAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Map<String, dynamic> pet;
  final Map<String, dynamic> clinic;

  const _NextAppointmentCard({required this.appointment, required this.pet, required this.clinic});

  @override
  Widget build(BuildContext context) {
    final DateTime date = appointment['date'] as DateTime;
    final String formattedDate = '${date.day}/${date.month}/${date.year}';
    final String formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['reason'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Mascota: ${pet['name']}  •  Clínica: ${clinic['name']}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedTime  •  $formattedDate',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String name;
  final String image;
  final String type;
  const _PetCard({required this.name, required this.image, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Círculo con imagen del dueño
          CircleAvatar(
            radius: 40,
            backgroundImage: image.isNotEmpty 
              ? NetworkImage(image)
              : null,
            backgroundColor: image.isEmpty ? Colors.grey[300] : null,
            child: image.isEmpty 
              ? Icon(Icons.person, size: 40, color: Colors.grey[600])
              : null,
          ),
          SizedBox(height: 8),
          // Nombre del dueño
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1),
          // Tipo de mascota
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final String name;
  final String image;
  final String address;
  final double rating;
  const _ClinicCard({required this.name, required this.image, required this.address, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(12, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Imagen de fondo
            Positioned.fill(
              child: image.isNotEmpty 
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.local_hospital, size: 48, color: Colors.grey),
                  ),
            ),
            // Overlay difuminado inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(199, 0, 0, 0),
                      Color.fromARGB(150, 0, 0, 0),
                      Color.fromARGB(3, 0, 0, 0),
                    ],
                  ),
                ),
              ),
            ),
            // Textos e iconos alineados abajo
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white, letterSpacing: 1, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 13, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Badge visual para radio
class _RadiusBadge extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;
  const _RadiusBadge({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
} 