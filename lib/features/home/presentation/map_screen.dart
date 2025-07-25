import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mirallapp/dummy/mock_data.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
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
  int _selectedRadius = 10000; // 10km por defecto
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
                // Botones de zoom y centrar
                Positioned(
                  bottom: 24,
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
