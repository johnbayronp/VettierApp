import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic {
  final String id;
  final String name;
  final List<String> services;
  final String image;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String nit;
  final String phone;
  final double rating;
  final String description;

  Clinic({
    required this.id,
    required this.name,
    required this.services,
    required this.image,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.nit,
    required this.phone,
    required this.rating,
    required this.description,
  });

  factory Clinic.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Clinic(
      id: doc.id,
      name: data['name'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      image: data['image'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      nit: data['nit'] ?? '',
      phone: data['phone'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'services': services,
      'image': image,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'nit': nit,
      'phone': phone,
      'rating': rating,
      'description': description,
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    List<String>? services,
    String? image,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? nit,
    String? phone,
    double? rating,
    String? description,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      services: services ?? this.services,
      image: image ?? this.image,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nit: nit ?? this.nit,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Clinic(id: $id, name: $name, services: $services, image: $image, address: $address, city: $city, latitude: $latitude, longitude: $longitude, nit: $nit, phone: $phone, rating: $rating, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Clinic &&
        other.id == id &&
        other.name == name &&
        other.services == services &&
        other.image == image &&
        other.address == address &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.nit == nit &&
        other.phone == phone &&
        other.rating == rating &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        services.hashCode ^
        image.hashCode ^
        address.hashCode ^
        city.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        nit.hashCode ^
        phone.hashCode ^
        rating.hashCode ^
        description.hashCode;
  }
} 