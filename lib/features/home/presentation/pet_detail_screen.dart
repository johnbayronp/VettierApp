import 'package:flutter/material.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:mirallapp/features/home/presentation/add_pet_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
             body: NestedScrollView(
         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // App Bar personalizado
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: Colors.purple,
                             leading: IconButton(
                 icon: Icon(Icons.arrow_back, color: Colors.white),
                 onPressed: () => Navigator.pop(context),
               ),
                               title: innerBoxIsScrolled ? Text(
                  widget.pet['name'] ?? 'Sin nombre',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ) : null,
               actions: [
                 IconButton(
                   icon: Icon(Icons.edit, color: Colors.white),
                   onPressed: () => _openEditPetScreen(),
                 ),
               ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Imagen de fondo de la mascota
                    Positioned.fill(
                      child: widget.pet['image'] != null && widget.pet['image'].toString().isNotEmpty
                        ? Image.network(
                            widget.pet['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.purple, Colors.purple.shade700],
                                ),
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.purple, Colors.purple.shade700],
                              ),
                            ),
                            child: Icon(
                              Icons.pets,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                    ),
                    // Overlay para mejor legibilidad del texto
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Nombre de la mascota posicionado manualmente
                    Positioned(
                      bottom: 60,
                      left: 16,
                      right: 16,
                      child: Text(
                        widget.pet['name'] ?? 'Sin nombre',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              bottom: _tabController != null ? TabBar(
                controller: _tabController!,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Próximas Citas'),
                  Tab(text: 'Historial'),
                  Tab(text: 'Medicamentos'),
                  Tab(text: 'Historia Clínica'),
                ],
              ) : null,
            ),
          ];
        },
                 body: _tabController != null ? TabBarView(
           controller: _tabController!,
           children: [
             _buildUpcomingAppointments(),
             _buildAppointmentHistory(),
             _buildMedications(),
             _buildMedicalHistory(),
           ],
         ) : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final petId = widget.pet['id'];
    final upcomingAppointments = appointments
        .where((a) => a['petId'] == petId && 
                     a['date'] is DateTime && 
                     (a['date'] as DateTime).isAfter(DateTime.now()))
        .toList();
    
    upcomingAppointments.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    if (upcomingAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay citas próximas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agenda una nueva cita para tu mascota',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

                  return ListView.builder(
           padding: EdgeInsets.all(16),
           itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        final clinic = clinics.firstWhere(
          (c) => c['id'] == appointment['clinicId'],
          orElse: () => {'name': 'Clínica no encontrada'},
        );
        final date = appointment['date'] as DateTime;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.medical_services, color: Colors.purple),
            ),
            title: Text(
              appointment['reason'] ?? 'Sin motivo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinic['name'] ?? 'Clínica no encontrada'),
                Text(
                  '${date.day}/${date.month}/${date.year} a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.purple),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Aquí se podría abrir un detalle de la cita
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentHistory() {
    final petId = widget.pet['id'];
    final pastAppointments = appointments
        .where((a) => a['petId'] == petId && 
                     a['date'] is DateTime && 
                     (a['date'] as DateTime).isBefore(DateTime.now()))
        .toList();
    
    pastAppointments.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    if (pastAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay historial de citas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

         return ListView.builder(
       padding: EdgeInsets.all(16),
       itemCount: pastAppointments.length,
      itemBuilder: (context, index) {
        final appointment = pastAppointments[index];
        final clinic = clinics.firstWhere(
          (c) => c['id'] == appointment['clinicId'],
          orElse: () => {'name': 'Clínica no encontrada'},
        );
        final date = appointment['date'] as DateTime;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.check, color: Colors.green),
            ),
            title: Text(
              appointment['reason'] ?? 'Sin motivo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinic['name'] ?? 'Clínica no encontrada'),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Aquí se podría abrir el detalle de la cita pasada
            },
          ),
        );
      },
    );
  }

  Widget _buildMedications() {
         // Mock data para medicamentos
     final medications = [
       {
         'name': 'Acetaminofen',
         'dosage': '1 tableta cada 3 meses',
         'startDate': '2024-01-15',
         'endDate': '2024-04-15',
         'status': 'Activo',
       },
       {
         'name': 'Vitaminas',
         'dosage': '1 tableta diaria',
         'startDate': '2024-02-01',
         'endDate': '2024-05-01',
         'status': 'Activo',
       },
       {
         'name': 'Antiparasitario',
         'dosage': '1 dosis cada 6 meses',
         'startDate': '2024-03-01',
         'endDate': '2024-09-01',
         'status': 'Activo',
       },
       {
         'name': 'Antiinflamatorio',
         'dosage': '1 tableta cada 12 horas',
         'startDate': '2024-03-10',
         'endDate': '2024-03-20',
         'status': 'Activo',
       },
       {
         'name': 'Probiótico',
         'dosage': '1 sobre diario',
         'startDate': '2024-02-15',
         'endDate': '2024-05-15',
         'status': 'Activo',
       },
     ];

         return ListView.builder(
       padding: EdgeInsets.all(16),
       itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.medication, color: Colors.orange),
            ),
            title: Text(
              medication['name']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication['dosage']!),
                Text(
                  '${medication['startDate']} - ${medication['endDate']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medication['status']!,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalHistory() {
    // Mock data para historia clínica
    final medicalRecords = [
      {
        'date': '2024-03-15',
        'type': 'Vacunación',
        'description': 'Vacuna contra la rabia aplicada',
        'veterinarian': 'Dr. García',
      },
      {
        'date': '2024-02-20',
        'type': 'Consulta',
        'description': 'Revisión general, todo normal',
        'veterinarian': 'Dr. Martínez',
      },
      {
        'date': '2024-01-10',
        'type': 'Cirugía',
        'description': 'Esterilización realizada con éxito',
        'veterinarian': 'Dr. López',
      },
    ];

         return ListView.builder(
       padding: EdgeInsets.all(16),
       itemCount: medicalRecords.length,
      itemBuilder: (context, index) {
        final record = medicalRecords[index];

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.medical_information, color: Colors.blue),
            ),
            title: Text(
              record['type']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['description']!),
                SizedBox(height: 4),
                Text(
                  'Dr. ${record['veterinarian']} • ${record['date']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Aquí se podría abrir el detalle del registro médico
            },
          ),
        );
      },
    );
  }

  void _openEditPetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(petToEdit: widget.pet), // Pasamos los datos de la mascota
      ),
    ).then((_) {
      setState(() {});
    });
  }
} 