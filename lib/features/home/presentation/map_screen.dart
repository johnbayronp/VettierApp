import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mirallapp/features/home/presentation/clinic_detail_screen.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  LatLng? _currentCenter;
  double _currentZoom = 17.0;
  int _selectedRadius = 1000; // 1km por defecto para mostrar solo cercanas
  final List<int> _radiusOptions = [1000, 5000, 10000, 20000];

  @override
  Widget build(BuildContext context) {
    final String city = clinics.isNotEmpty ? clinics[0]['city'] : '';
    final clinicsInCity = clinics.where((c) => c['city'] == city).toList();
    final center = clinicsInCity.isNotEmpty
        ? LatLng(clinicsInCity[0]['latitude'], clinicsInCity[0]['longitude'])
        : LatLng(5.3378, -72.3959); // Yopal por defecto

    LatLng? userPosition;
    return FutureBuilder<Position>(
      future: Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          userPosition = LatLng(
            snapshot.data!.latitude,
            snapshot.data!.longitude,
          );
        }

        // Filtrar clínicas dentro del radio seleccionado
        List<Map<String, dynamic>> clinicsInRadius = [];
        if (userPosition != null) {
          clinicsInCity.forEach((clinic) {
            final double distance = Geolocator.distanceBetween(
              userPosition!.latitude,
              userPosition!.longitude,
              clinic['latitude'],
              clinic['longitude'],
            );
            if (distance <= _selectedRadius) {
              clinicsInRadius.add({
                ...clinic,
                'distance': distance,
              });
            }
          });
          // Ordenar por distancia
          clinicsInRadius.sort((a, b) => a['distance'].compareTo(b['distance']));
        }

        final markers = <Marker>[
          ...clinicsInCity.map((clinic) {
            // Calcular distancia entre usuario y clínica
            bool isWithinRadius = false;
            if (userPosition != null) {
              final double distance = Geolocator.distanceBetween(
                userPosition!.latitude,
                userPosition!.longitude,
                clinic['latitude'],
                clinic['longitude'],
              );
              isWithinRadius = distance <= _selectedRadius;
            }
            
            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(clinic['latitude'], clinic['longitude']),
              child: Icon(
                Icons.location_on, 
                color: isWithinRadius ? Colors.purple : const Color.fromARGB(255, 111, 93, 145), // Púrpura grisáceo para fuera del radio
                size: 36
              ),
              key: ValueKey(clinic['name']),
            );
          }),
          if (userPosition != null)
            Marker(
              width: 40.0,
              height: 40.0,
              point: userPosition!,
              child: Icon(Icons.my_location, color: Colors.blue, size: 36),
              key: const ValueKey('user_location'),
            ),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text('Clínicas en el mapa'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
            elevation: 1,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Selector de radio debajo del AppBar
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            userPosition != null)
                        ? userPosition!
                        : center,
                    initialZoom: _currentZoom,
                    onPositionChanged: (position, hasGesture) {
                      setState(() {
                        _currentCenter = position.center;
                        _currentZoom = position.zoom ?? _currentZoom;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bapesutech.mirallapp',
                    ),

                    // Solo el círculo del radio seleccionado
                    if (userPosition != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: userPosition!,
                            color: const Color(
                              0xFFB39DDB,
                            ).withOpacity(0.28), // púrpura grisáceo más fuerte
                            borderStrokeWidth: 3,
                            borderColor: const Color(0xFF7E57C2),
                            radius: _selectedRadius.toDouble(),
                            useRadiusInMeter: true,
                          ),
                        ],
                      ),
                    Positioned(
                      top: 14,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Badges de selección de radio
                          ..._radiusOptions.map((radius) {
                            final isSelected = _selectedRadius == radius;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  '${(radius / 1000).toStringAsFixed(0)} km',
                                ),
                                selected: isSelected,
                                selectedColor: Colors.purple,
                                onSelected: (_) {
                                  setState(() => _selectedRadius = radius);
                                },
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: const Color.fromARGB(
                                  94,
                                  155,
                                  39,
                                  176,
                                ).withOpacity(0.08),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        markers: markers,
                        popupController: _popupController,
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            Map<String, dynamic>? clinic;
                            try {
                              clinic = clinicsInCity.firstWhere(
                                (c) =>
                                    c['name'] == (marker.key as ValueKey).value,
                              );
                            } catch (_) {
                              clinic = null;
                            }
                            if (clinic == null) return const SizedBox.shrink();
                            return Card(
                              margin: EdgeInsets.only(bottom: 40),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clinic['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      clinic['address'] ?? '',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // Tarjetas de clínicas en la parte inferior
                if (clinicsInRadius.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 10,
                    child: Container(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: clinicsInRadius.length,
                        itemBuilder: (context, index) {
                          final clinic = clinicsInRadius[index];
                          final distance = clinic['distance'] as double;
                          final distanceText = distance < 1000 
                              ? '${distance.toInt()} m'
                              : '${(distance / 1000).toStringAsFixed(1)} km';
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClinicDetailScreen(
                                    clinic: clinic,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 180,
                              margin: EdgeInsets.only(right: 12),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Imagen de la clínica
                                    Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: clinic['image'] != null
                                            ? Image.network(
                                                clinic['image'],
                                                width: double.infinity,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.pink[300],
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.local_hospital,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / 
                                                              loadingProgress.expectedTotalBytes!
                                                            : null,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.pink[300],
                                                child: Center(
                                                  child: Icon(
                                                    Icons.local_hospital,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Información de la clínica
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clinic['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Distancia $distanceText',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: const Color.fromARGB(255, 255, 199, 17),
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    clinic['rating'].toString(),
                                                    style: TextStyle(
                                                      color: const Color.fromARGB(255, 31, 30, 30),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                                         ),
                   ),

                 // Información del radio después de las tarjetas
                 if (clinicsInRadius.isNotEmpty)
                   Positioned(
                     bottom: 160,
                     left: 16,
                     child: Container(
                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.9),
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 4,
                             offset: Offset(0, 2),
                           ),
                         ],
                       ),
                       child: Text(
                         'Radio ${(_selectedRadius / 1000).toStringAsFixed(0)} km | Solo cercanas',
                         style: TextStyle(
                           color: Colors.purple,
                           fontWeight: FontWeight.w500,
                           fontSize: 12,
                         ),
                       ),
                     ),
                   ),

                 // Botones de zoom y centrar
                Positioned(
                  bottom: clinicsInRadius.isNotEmpty ? 150 : 24,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoom_in',
                        mini: true,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, color: Colors.purple),
                        onPressed: () {
                          if (_currentCenter != null) {
                            _mapController.move(
                              _currentCenter!,
                              _currentZoom + 1,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoom_out',
                        mini: true,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.remove, color: Colors.purple),
                        onPressed: () {
                          if (_currentCenter != null) {
                            _mapController.move(
                              _currentCenter!,
                              _currentZoom - 1,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: 'center_user',
                        mini: true,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.my_location, color: Colors.blue),
                        onPressed: userPosition != null
                            ? () {
                                _mapController.move(userPosition!, 16.0);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
