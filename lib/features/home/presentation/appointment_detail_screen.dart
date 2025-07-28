import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/appointment_repository.dart';
import '../data/clinic_repository.dart';
import '../data/pet_repository.dart';
import 'appointment_model.dart';
import 'clinic_model.dart';
import 'pet_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle de Cita',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Solo mostrar botón de cancelar en AppBar si la cita NO está cancelada y NO está completada
          if (appointment.status.toLowerCase() != 'cancelada' && 
              appointment.status.toLowerCase() != 'completada')
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _showCancelDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado de la cita
              _buildStatusHeader(),
              const SizedBox(height: 24),
              
              // Información de la cita
              _buildAppointmentInfo(),
              const SizedBox(height: 24),
              
              // Información de la mascota
              _buildPetInfo(),
              const SizedBox(height: 24),
              
                             // Información de la clínica
               _buildClinicInfo(),
               const SizedBox(height: 24),
               
               // Información del veterinario
               _buildVeterinarianInfo(),
               const SizedBox(height: 32),
               
               // Botones de acción
               _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    String statusText;
    
    switch (appointment.status.toLowerCase()) {
      case 'confirmada':
        statusColor = Colors.green;
        statusText = 'Confirmada';
        break;
      case 'pendiente':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case 'cancelada':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        break;
      case 'completada':
        statusColor = Colors.blue;
        statusText = 'Completada';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Sin estado';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.reason,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    final DateTime date = appointment.date;
    final String formattedDate = '${date.day}/${date.month}/${date.year}';
    final String formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de la Cita',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow('Fecha', formattedDate, Icons.calendar_today),
          _buildInfoRow('Hora', formattedTime, Icons.access_time),
          _buildInfoRow('Motivo', appointment.reason, Icons.medical_services),
          if (appointment.notes != null && appointment.notes!.isNotEmpty)
            _buildInfoRow('Notas', appointment.notes!, Icons.note),
        ]),
      ],
    );
  }

  Widget _buildPetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de la Mascota',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Pet?>(
          future: FirebasePetRepository().getPet(appointment.petId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final pet = snapshot.data;
            if (pet == null) {
              return _buildInfoCard([
                _buildInfoRow('Mascota', 'No encontrada', Icons.pets),
              ]);
            }
            
            return _buildInfoCard([
              _buildInfoRow('Nombre', pet.name, Icons.pets),
              _buildInfoRow('Tipo', pet.type, Icons.category),
              _buildInfoRow('Raza', pet.breed, Icons.pets),
              _buildInfoRow('Edad', '${pet.age} años', Icons.cake),
            ]);
          },
        ),
      ],
    );
  }

  Widget _buildClinicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de la Clínica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Clinic?>(
          future: FirebaseClinicRepository().getClinic(appointment.clinicId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final clinic = snapshot.data;
            if (clinic == null) {
              return _buildInfoCard([
                _buildInfoRow('Clínica', 'No encontrada', Icons.local_hospital),
              ]);
            }
            
                         return _buildInfoCard([
               _buildInfoRow('Nombre', clinic.name, Icons.local_hospital),
               _buildInfoRow('Dirección', clinic.address, Icons.location_on),
               _buildInfoRow('Teléfono', clinic.phone, Icons.phone),
             ]);
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
     }

       Widget _buildVeterinarianInfo() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Veterinario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: _getVeterinarianInfo(appointment.veterinarianId),
           builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
             }
             
             final veterinarian = snapshot.data;
             if (veterinarian == null) {
               return _buildInfoCard([
                 _buildInfoRow('Veterinario', 'No asignado', Icons.person),
               ]);
             }
             
             return _buildInfoCard([
               _buildInfoRow('Nombre', 'Dr. ${veterinarian['name'] ?? 'Sin nombre'}', Icons.person),
               _buildInfoRow('Especialidad', veterinarian['specialty'] ?? 'No especificada', Icons.medical_services),
               if (veterinarian['phone'] != null && veterinarian['phone'].isNotEmpty)
                 _buildInfoRow('Teléfono', veterinarian['phone'], Icons.phone),
               if (veterinarian['email'] != null && veterinarian['email'].isNotEmpty)
                 _buildInfoRow('Email', veterinarian['email'], Icons.email),
             ]);
           },
         ),
       ],
     );
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

   Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Solo mostrar botón de cancelar si la cita NO está cancelada y NO está completada
        if (appointment.status.toLowerCase() != 'cancelada' && 
            appointment.status.toLowerCase() != 'completada')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showCancelDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel),
                  SizedBox(width: 8),
                  Text(
                    'Cancelar Cita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Si la cita está cancelada, mostrar mensaje informativo
        if (appointment.status.toLowerCase() == 'cancelada')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta cita ya fue cancelada',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Si la cita está completada, mostrar mensaje informativo
        if (appointment.status.toLowerCase() == 'completada')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta cita ya fue completada',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Cancelar Cita'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que quieres cancelar esta cita?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• La cita se marcará como cancelada\n• Aparecerá en el historial\n• Esta acción no se puede deshacer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No, mantener',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await FirebaseAppointmentRepository().updateAppointmentStatus(
        appointment.appointmentId,
        'cancelada',
      );
      
      if (context.mounted) {
        // Cerrar el indicador de carga
        Navigator.of(context).pop();
        
        // Regresar a la pantalla anterior primero
        Navigator.of(context).pop();
        
        // Mostrar mensaje de éxito después de regresar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Cerrar el indicador de carga
        Navigator.of(context).pop();
        
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cancelar la cita: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
} 