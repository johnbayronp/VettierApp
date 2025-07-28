import 'package:flutter/material.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:mirallapp/features/home/presentation/add_pet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/appointment_repository.dart';
import '../data/clinic_repository.dart';
import 'appointment_model.dart';
import 'clinic_model.dart';
import 'appointment_detail_screen.dart';
import 'appointment_model.dart';
import 'medication_model.dart';
import 'medical_record_model.dart';
import '../data/medication_repository.dart';
import '../data/medical_record_repository.dart';

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
    // Validar que tenemos datos válidos de la mascota
    if (widget.pet == null || widget.pet.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Error'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text('Datos de mascota no válidos', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }
    
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
                   widget.pet['name']?.toString() ?? 'Sin nombre',
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
                             widget.pet['image'].toString(),
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
                         widget.pet['name']?.toString() ?? 'Sin nombre',
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
    try {
      final petId = widget.pet['petId'] ?? '';
      if (petId.isEmpty) {
        return Center(
          child: Text('ID de mascota no válido', style: TextStyle(color: Colors.grey[600])),
        );
      }
      
      return StreamBuilder<List<Appointment>>(
        stream: FirebaseAppointmentRepository().getUpcomingAppointmentsByPet(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar citas: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          }

          final upcomingAppointments = snapshot.data ?? [];

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

              return FutureBuilder<Clinic?>(
                future: FirebaseClinicRepository().getClinic(appointment.clinicId),
                builder: (context, clinicSnapshot) {
                  final clinicName = clinicSnapshot.data?.name ?? 'Clínica no encontrada';

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Icon(Icons.medical_services, color: Colors.purple),
                      ),
                      title: Text(
                        appointment.reason,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinicName),
                          Text(
                            '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} a las ${appointment.date.hour.toString().padLeft(2, '0')}:${appointment.date.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailScreen(appointment: appointment),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Center(
        child: Text('Error al cargar citas: $e', style: TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildAppointmentHistory() {
    try {
      final petId = widget.pet['petId'] ?? '';
      if (petId.isEmpty) {
        return Center(
          child: Text('ID de mascota no válido', style: TextStyle(color: Colors.grey[600])),
        );
      }
      
      return StreamBuilder<List<Appointment>>(
        stream: FirebaseAppointmentRepository().getAppointmentsByPet(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar historial: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          }

          final allAppointments = snapshot.data ?? [];
          
          // Filtrar citas pasadas y canceladas
          final pastAppointments = allAppointments.where((appointment) {
            final isPast = appointment.date.isBefore(DateTime.now());
            final isCanceled = appointment.status.toLowerCase() == 'cancelada';
            return isPast || isCanceled;
          }).toList();

          // Ordenar por fecha (más recientes primero)
          pastAppointments.sort((a, b) => b.date.compareTo(a.date));

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
              
              // Determinar el color y icono según el estado
              Color statusColor;
              IconData statusIcon;
              String statusText;
              
              switch (appointment.status.toLowerCase()) {
                case 'cancelada':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusText = 'Cancelada';
                  break;
                case 'completada':
                  statusColor = Colors.green;
                  statusIcon = Icons.check;
                  statusText = 'Completada';
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.schedule;
                  statusText = 'Pasada';
              }

              return FutureBuilder<Clinic?>(
                future: FirebaseClinicRepository().getClinic(appointment.clinicId),
                builder: (context, clinicSnapshot) {
                  final clinicName = clinicSnapshot.data?.name ?? 'Clínica no encontrada';

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        appointment.reason,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinicName),
                          Text(
                            '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} a las ${appointment.date.hour.toString().padLeft(2, '0')}:${appointment.date.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailScreen(appointment: appointment),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Center(
        child: Text('Error al cargar historial: $e', style: TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildMedications() {
    try {
      final petId = widget.pet['petId'] ?? '';
      if (petId.isEmpty) {
        return Center(
          child: Text('ID de mascota no válido', style: TextStyle(color: Colors.grey[600])),
        );
      }
      
      return StreamBuilder<List<Medication>>(
        stream: FirebaseMedicationRepository().getMedicationsByPet(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar medicamentos: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          }

          final medications = snapshot.data ?? [];

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No hay medicamentos registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los medicamentos prescritos aparecerán aquí',
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
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              
              // Determinar el color según el estado
              Color statusColor;
              String statusText;
              
              switch (medication.status.toLowerCase()) {
                case 'active':
                  statusColor = Colors.green;
                  statusText = 'Activo';
                  break;
                case 'completed':
                  statusColor = Colors.blue;
                  statusText = 'Completado';
                  break;
                case 'discontinued':
                  statusColor = Colors.red;
                  statusText = 'Discontinuado';
                  break;
                default:
                  statusColor = Colors.grey;
                  statusText = 'Desconocido';
              }

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(Icons.medication, color: statusColor),
                  ),
                  title: Text(
                    medication.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${medication.dosage} - ${medication.frequency}'),
                      Text(
                        '${medication.startDate.day}/${medication.startDate.month}/${medication.startDate.year}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (medication.endDate != null)
                        Text(
                          'Hasta: ${medication.endDate!.day}/${medication.endDate!.month}/${medication.endDate!.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      return Center(
        child: Text('Error al cargar medicamentos: $e', style: TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildMedicalHistory() {
    try {
      final petId = widget.pet['petId'] ?? '';
      if (petId.isEmpty) {
        return Center(
          child: Text('ID de mascota no válido', style: TextStyle(color: Colors.grey[600])),
        );
      }
      
      return StreamBuilder<List<MedicalRecord>>(
        stream: FirebaseMedicalRecordRepository().getMedicalRecordsByPet(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar historia clínica: ${snapshot.error}', style: TextStyle(color: Colors.red)),
            );
          }

          final medicalRecords = snapshot.data ?? [];

          if (medicalRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No hay registros médicos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los registros médicos aparecerán aquí',
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
            itemCount: medicalRecords.length,
            itemBuilder: (context, index) {
              final record = medicalRecords[index];
              
              // Determinar el color y icono según el tipo
              Color typeColor;
              IconData typeIcon;
              
              switch (record.type.toLowerCase()) {
                case 'vaccination':
                  typeColor = Colors.green;
                  typeIcon = Icons.vaccines;
                  break;
                case 'consultation':
                  typeColor = Colors.blue;
                  typeIcon = Icons.medical_services;
                  break;
                case 'surgery':
                  typeColor = Colors.red;
                  typeIcon = Icons.local_hospital;
                  break;
                case 'treatment':
                  typeColor = Colors.orange;
                  typeIcon = Icons.healing;
                  break;
                case 'checkup':
                  typeColor = Colors.purple;
                  typeIcon = Icons.health_and_safety;
                  break;
                default:
                  typeColor = Colors.grey;
                  typeIcon = Icons.medical_information;
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getVeterinarianInfo(record.veterinarianId),
                builder: (context, vetSnapshot) {
                  final veterinarianName = vetSnapshot.data?['name'] ?? 'Veterinario no encontrado';

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: typeColor.withOpacity(0.1),
                        child: Icon(typeIcon, color: typeColor),
                      ),
                      title: Text(
                        record.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.description),
                          SizedBox(height: 4),
                          Text(
                            'Dr. $veterinarianName • ${record.date.day}/${record.date.month}/${record.date.year}',
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
            },
          );
        },
      );
    } catch (e) {
      return Center(
        child: Text('Error al cargar historia clínica: $e', style: TextStyle(color: Colors.red)),
      );
    }
  }

  Future<Map<String, dynamic>?> _getVeterinarianInfo(String veterinarianId) async {
    try {
      if (veterinarianId.isEmpty) {
        return null;
      }
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(veterinarianId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _openEditPetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(petToEdit: widget.pet),
      ),
    ).then((_) {
      setState(() {});
    });
  }
} 