import 'package:mirallapp/dummy/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mirallapp/features/home/presentation/map_screen.dart';
import 'package:mirallapp/features/home/presentation/clinic_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedService = 'Salud';
  String userLocation = users[0]['address']['city'];
  double? userLat;
  double? userLng;
  int selectedRadius = 10000; // 10 km por defecto

  Future<void> _updateCity() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Obtener el nombre de la ciudad usando geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String city = placemarks.isNotEmpty ? (placemarks.first.locality ?? '') : '';
    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;
      userLocation = city.isNotEmpty ? city : userLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userName = users[0]['name'];
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
    print('Clínicas encontradas: ${filteredClinics.length}');

         // Buscar la próxima cita (la más próxima en fecha)
     final now = DateTime.now();
     final upcomingAppointments = appointments
       .where((a) => a['date'] is DateTime && (a['date'] as DateTime).isAfter(now))
       .toList();
     upcomingAppointments.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
     final nextAppointment = upcomingAppointments.isNotEmpty ? upcomingAppointments.first : null;
         // Buscar mascota y clínica
   final pet = nextAppointment != null
    ? pets.firstWhere(
        (p) => p['petId'] == nextAppointment['petId'], 
        orElse: () => pets.first
      )
    : pets.first;
   final clinic = nextAppointment != null ? clinics.firstWhere(
     (c) => c['id'] == nextAppointment['clinicId'], 
     orElse: () => clinics.first
   ) : (clinics.isNotEmpty ? clinics.first : null);

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
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 4),
              Text(userLocation, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
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
              Text('Hola, $userName,', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              const Text('¡Cuidemos a tus mascotas!', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              // Tarjeta de próxima cita
              if (nextAppointment != null && clinic != null)
                _NextAppointmentCard(
                  appointment: nextAppointment,
                  pet: pet,
                  clinic: clinic,
                ),
              if (nextAppointment == null || clinic == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('No tienes próximas citas', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                    onPressed: () {},
                  ),
                ],
              ),
                             SizedBox(
                 height: 160,
                 child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: petsList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    final pet = petsList[i];
                    return _PetCard(
                      name: pet['name'] ?? 'Sin nombre', 
                      image: pet['image'] ?? 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200&h=200&fit=crop',
                      type: pet['type'] ?? 'Sin Raza',
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
            // Eliminar overlay superior (no incluir Positioned con top: 0)
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