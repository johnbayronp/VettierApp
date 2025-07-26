import 'package:flutter/material.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:mirallapp/features/home/presentation/schedule_appointment_screen.dart';

class ClinicDetailScreen extends StatefulWidget {
  final Map<String, dynamic> clinic;

  const ClinicDetailScreen({Key? key, required this.clinic}) : super(key: key);

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar con imagen de fondo
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.purple,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    Image.network(
                      widget.clinic['image'] ??
                          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800',
                      fit: BoxFit.cover,
                    ),
                    // Overlay gradiente
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.phone, color: Colors.white),
                    onPressed: () {
                      print('clinic: ${widget.clinic}');
                      // Aquí iría la lógica para hacer la llamada
                      final phone = widget.clinic['phone'] ?? '';
                      if (phone.isNotEmpty) {
                        // En una app real, aquí usarías url_launcher para hacer la llamada
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Llamando a $phone'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // Contenido principal
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(20), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de la clínica y rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.clinic['name'] ?? 'Clínica',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  (widget.clinic['rating'] ?? 0.0).toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Horarios
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '8:00 AM - 10:00 PM',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Dirección
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.clinic['address'] ??
                                  'Dirección no disponible',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Reviews
                      Row(
                        children: [
                          ...List.generate(
                            3,
                            (index) => Container(
                              margin: EdgeInsets.only(right: 4),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '150 Reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Descripción
                      Text(
                        'Sobre la Clínica',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.clinic['description'] ??
                            'Descripción no disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Médicos
                      Text(
                        'Nuestros Veterinarios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...getDoctorsByClinic(widget.clinic['id'] ?? '' ).map((doctor) => 
                              Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: _DoctorCard(
                                  name: doctor['name'] ?? 'Sin nombre',
                                  specialty: doctor['specialty'] ?? 'Sin especialidad',
                                  image: doctor['photoURL'] ?? 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop&crop=face',
                                ),
                              ),
                            ).toList(),
                          ],
                        ),
                      ),
                                             SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
                     child: ElevatedButton(
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => ScheduleAppointmentScreen(
                     clinic: widget.clinic,
                   ),
                 ),
               );
             },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Agendar Cita',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String image;

  const _DoctorCard({
    required this.name,
    required this.specialty,
    required this.image,
  });

     @override
   Widget build(BuildContext context) {
     return Container(
       width: 120,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           CircleAvatar(
             radius: 35,
             backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
             backgroundColor: Colors.grey[300],
             child: image.isEmpty ? Icon(Icons.person, size: 35, color: Colors.grey[600]) : null,
           ),
           SizedBox(height: 12),
           Text(
             name,
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: Colors.black87,
             ),
             textAlign: TextAlign.center,
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
           ),
           SizedBox(height: 1),
           Text(
             specialty,
             style: TextStyle(
               fontSize: 12, 
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
