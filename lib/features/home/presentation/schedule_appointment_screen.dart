import 'package:flutter/material.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:mirallapp/features/home/presentation/add_pet_screen.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> clinic;

  const ScheduleAppointmentScreen({Key? key, required this.clinic})
    : super(key: key);

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  String? selectedVeterinarian;
  String? selectedService;
  String? selectedPet;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  DateTime currentMonth = DateTime.now();

  final List<String> availableTimes = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
  ];

  final List<String> services = [
    'Peluqueria',
    'Consulta general',
    'Vacunación',
    'Cirugía',
    'Emergencia',
  ];

  @override
  Widget build(BuildContext context) {
    final doctors = getDoctorsByClinic(widget.clinic['id'] ?? '');
    final userPets = pets
        .where((pet) => pet['ownerId'] == 'user1')
        .toList(); // Obtener mascotas del usuario 1

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
                      '${_getTruncatedClinicName()} | Agendar cita',
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

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleccionar veterinario
                    _buildDropdownField(
                      label: 'Seleccionar veterinario',
                      value: selectedVeterinarian,
                      items: doctors
                          .map((doctor) => doctor['name'] ?? 'Sin nombre')
                          .cast<String>()
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedVeterinarian = value),
                    ),

                    SizedBox(height: 20),

                    // Servicio
                    _buildDropdownField(
                      label: 'Servicio',
                      value: selectedService,
                      items: services,
                      onChanged: (value) =>
                          setState(() => selectedService = value),
                    ),

                    SizedBox(height: 20),

                                         // Mi mascota
                     _buildPetDropdownField(),

                    SizedBox(height: 30),

                    // Calendario
                    _buildCalendar(),

                    SizedBox(height: 30),

                    // Horarios disponibles
                    Text(
                      'Horarios disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Botones de horarios
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableTimes.map((time) {
                        final isSelected = selectedTime == time;
                        final isAvailable =
                            time != '11:00 AM'; // Simular horario no disponible

                        return GestureDetector(
                          onTap: isAvailable
                              ? () => setState(() => selectedTime = time)
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? (isSelected ? Colors.purple : Colors.white)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: isAvailable && !isSelected
                                  ? Border.all(
                                      color: Colors.purple[300]!,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isAvailable
                                    ? (isSelected
                                          ? Colors.white
                                          : Colors.purple)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 30),

                    // Veterinario asignado
                    if (selectedVeterinarian != null) ...[
                      Text(
                        'Veterinario asignado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 16),

                      _buildVeterinarianCard(selectedVeterinarian!),

                      SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),

            // Botón de confirmar
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _canConfirmAppointment()
                      ? () {
                          // Aquí iría la lógica para confirmar la cita
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cita confirmada para ${selectedDate.day}/${selectedDate.month} a las $selectedTime',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      : null,
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
                    'Confirmar cita',
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navegación del mes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  currentMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month - 1,
                  );
                });
              },
            ),
            Text(
              '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  currentMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),

        SizedBox(height: 16),

        // Días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 12),

        // Grilla de fechas
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _getDaysInMonth(currentMonth),
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = DateTime(currentMonth.year, currentMonth.month, day);
            final isSelected =
                selectedDate.day == day &&
                selectedDate.month == currentMonth.month &&
                selectedDate.year == currentMonth.year;
            final isToday =
                day == DateTime.now().day &&
                currentMonth.month == DateTime.now().month &&
                currentMonth.year == DateTime.now().year;
            final isSpecial = day == 10 || day == 12; // Fechas especiales

            return GestureDetector(
              onTap: () => setState(() => selectedDate = date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple
                      : (isSpecial ? Colors.orange : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.purple, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isSpecial ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVeterinarianCard(String veterinarianName) {
    final doctors = getDoctorsByClinic(widget.clinic['id'] ?? '');
    final doctor = doctors.firstWhere(
      (d) => d['name'] == veterinarianName,
      orElse: () => {
        'name': 'Sin nombre',
        'specialty': 'Sin especialidad',
        'photoURL': '',
      },
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: doctor['photoURL']?.isNotEmpty == true
                ? NetworkImage(doctor['photoURL'])
                : null,
            backgroundColor: Colors.grey[300],
            child: doctor['photoURL']?.isEmpty != false
                ? Icon(Icons.person, size: 25, color: Colors.grey[600])
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'] ?? 'Sin nombre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  doctor['specialty'] ?? 'Sin especialidad',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canConfirmAppointment() {
    return selectedVeterinarian != null &&
        selectedService != null &&
        selectedPet != null &&
        selectedTime != null;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

     String _getTruncatedClinicName() {
     final clinicName = widget.clinic['name'] ?? 'Clínica';
     if (clinicName.length > 10) {
       return '${clinicName.substring(0, 10)}...';
     }
     return clinicName;
   }

   Widget _buildPetDropdownField() {
     final userPets = pets
         .where((pet) => pet['ownerId'] == 'user1')
         .toList();

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               'Mi mascota',
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
                 color: Colors.black,
               ),
             ),
             IconButton(
               icon: Icon(Icons.add_circle, color: Colors.purple),
               onPressed: () => _openAddPetScreen(),
             ),
           ],
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
             value: selectedPet,
             isExpanded: true,
             underline: SizedBox(),
             hint: Text('Seleccionar...'),
             items: userPets.map((pet) {
               return DropdownMenuItem<String>(
                 value: pet['name'] ?? 'Sin nombre',
                 child: Text(pet['name'] ?? 'Sin nombre'),
               );
             }).toList(),
             onChanged: (value) => setState(() => selectedPet = value),
           ),
         ),
       ],
     );
   }

   void _openAddPetScreen() {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => AddPetScreen(),
       ),
     ).then((_) {
       // Refrescar la lista de mascotas cuando regrese
       setState(() {});
     });
   }
 }
