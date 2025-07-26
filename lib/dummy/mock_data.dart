// Mock data para desarrollo
final List<Map<String, dynamic>> users = [
  // Clientes
  {
    'uid': 'user1',
    'name': 'Juan Pérez',
    'email': 'juan@example.com',
    'phone': '+57 310 1234567',
    'photoURL': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
    'role': 'client',
    'address': {
      'street': 'Calle 15 #20-30',
      'city': 'Yopal',
      'zip': '850001',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'user2',
    'name': 'María García',
    'email': 'maria@example.com',
    'phone': '+57 310 2345678',
    'photoURL': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
    'role': 'client',
    'address': {
      'street': 'Cra 10 #15-25',
      'city': 'Yopal',
      'zip': '850002',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  // Veterinarios
  {
    'uid': 'doctor1',
    'name': 'Dr. María García',
    'email': 'maria.garcia@clinicavet.com',
    'phone': '+57 310 1111111',
    'photoURL': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Cirugía',
    'clinicId': 'clinic1', // Asociado a ClinicVet
    'experience': '8 años',
    'education': 'Universidad Nacional de Colombia',
    'address': {
      'street': 'Cra 10 #20-30',
      'city': 'Yopal',
      'zip': '850001',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'doctor2',
    'name': 'Dr. Carlos López',
    'email': 'carlos.lopez@clinicavet.com',
    'phone': '+57 310 2222222',
    'photoURL': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Medicina General',
    'clinicId': 'clinic1', // Asociado a ClinicVet
    'experience': '5 años',
    'education': 'Universidad de los Llanos',
    'address': {
      'street': 'Cra 10 #20-30',
      'city': 'Yopal',
      'zip': '850001',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'doctor3',
    'name': 'Dra. Ana Rodríguez',
    'email': 'ana.rodriguez@vetcenter.com',
    'phone': '+57 310 3333333',
    'photoURL': 'https://images.unsplash.com/photo-1594824475545-9d0c7c4951c5?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Dermatología',
    'clinicId': 'clinic2', // Asociado a VetCenter
    'experience': '10 años',
    'education': 'Universidad de Antioquia',
    'address': {
      'street': 'Cra 15 #25-35',
      'city': 'Yopal',
      'zip': '850003',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'doctor4',
    'name': 'Dr. Roberto Silva',
    'email': 'roberto.silva@vetcenter.com',
    'phone': '+57 310 4444444',
    'photoURL': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Cardiología',
    'clinicId': 'clinic2', // Asociado a VetCenter
    'experience': '12 años',
    'education': 'Universidad Javeriana',
    'address': {
      'street': 'Cra 15 #25-35',
      'city': 'Yopal',
      'zip': '850003',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'doctor5',
    'name': 'Dra. Patricia Morales',
    'email': 'patricia.morales@mascotassalud.com',
    'phone': '+57 310 5555555',
    'photoURL': 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Oftalmología',
    'clinicId': 'clinic3', // Asociado a MascotasSalud
    'experience': '7 años',
    'education': 'Universidad de Caldas',
    'address': {
      'street': 'Calle 20 #30-40',
      'city': 'Yopal',
      'zip': '850004',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'doctor6',
    'name': 'Dr. Fernando Ruiz',
    'email': 'fernando.ruiz@mascotassalud.com',
    'phone': '+57 310 6666666',
    'photoURL': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&h=100&fit=crop&crop=face',
    'role': 'veterinario',
    'specialty': 'Ortopedia',
    'clinicId': 'clinic3', // Asociado a MascotasSalud
    'experience': '9 años',
    'education': 'Universidad Nacional de Colombia',
    'address': {
      'street': 'Calle 20 #30-40',
      'city': 'Yopal',
      'zip': '850004',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  // Administradores
  {
    'uid': 'admin1',
    'name': 'Admin ClinicVet',
    'email': 'admin@clinicavet.com',
    'phone': '+57 310 7777777',
    'photoURL': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
    'role': 'admin',
    'clinicId': 'clinic1', // Administra ClinicVet
    'address': {
      'street': 'Cra 10 #20-30',
      'city': 'Yopal',
      'zip': '850001',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'admin2',
    'name': 'Admin VetCenter',
    'email': 'admin@vetcenter.com',
    'phone': '+57 310 8888888',
    'photoURL': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
    'role': 'admin',
    'clinicId': 'clinic2', // Administra VetCenter
    'address': {
      'street': 'Cra 15 #25-35',
      'city': 'Yopal',
      'zip': '850003',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
  {
    'uid': 'admin3',
    'name': 'Admin MascotasSalud',
    'email': 'admin@mascotassalud.com',
    'phone': '+57 310 9999999',
    'photoURL': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
    'role': 'admin',
    'clinicId': 'clinic3', // Administra MascotasSalud
    'address': {
      'street': 'Calle 20 #30-40',
      'city': 'Yopal',
      'zip': '850004',
    },
    'createdAt': DateTime.now(),
    'lastLogin': DateTime.now(),
  },
];

final List<Map<String, dynamic>> clinics = [
  {
    'id': 'clinic1',
    'name': 'ClinicVet',
    'services': ['Salud', 'Consulta', 'Peluquería'],
    'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwWgYUkhYn0I2ZJZW6RdFzMXcqM65SVYIaCg&s',
    'address': 'Cra 10 #20-30',
    'city': 'Yopal',
    'latitude': 5.334966,
    'longitude': -72.378026,
    'nit': '900123456-1',
    'phone': '+57 310 1234567',
    'rating': 4.8,
    'description': 'Clínica veterinaria integral con más de 10 años de experiencia. Ofrecemos servicios de salud preventiva, cirugías, consultas especializadas y peluquería canina. Nuestro equipo de veterinarios altamente calificados está comprometido con el bienestar de tus mascotas.',
  },
  {
    'id': 'clinic2',
    'name': 'VetCenter',
    'services': ['Salud', 'Cirugía', 'Emergencias'],
    'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800',
    'address': 'Cra 15 #25-35',
    'city': 'Yopal',
    'latitude': 5.335966,
    'longitude': -72.379026,
    'nit': '900234567-2',
    'phone': '+57 310 2345678',
    'rating': 4.6,
    'description': 'Centro veterinario especializado en cirugías y emergencias. Contamos con equipos de última generación y un equipo médico experimentado para atender casos complejos y emergencias las 24 horas.',
  },
  {
    'id': 'clinic3',
    'name': 'MascotasSalud',
    'services': ['Salud', 'Peluquería', 'Vacunación'],
    'image': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=800',
    'address': 'Calle 20 #30-40',
    'city': 'Yopal',
    'latitude': 5.318114, 
    'longitude': -72.404355,
    'nit': '900345678-3',
    'phone': '+57 310 3456789',
    'rating': 4.9,
    'description': 'Clínica especializada en el cuidado integral de mascotas. Ofrecemos servicios de peluquería profesional, vacunación, desparasitación y atención médica preventiva. Nuestro enfoque es mantener a tus mascotas saludables y felices.',
  },
];

final List<Map<String, dynamic>> pets = [
  {
    'petId': 'pet1',
    'ownerId': 'user1',
    'name': 'Luna',
    'species': 'Dog',
    'breed': 'Golden Retriever',
    'type': 'Perro',
    'age': 3,
    'birthdate': '2020-05-15',
    'weight': 25.5,
    'photoURL': 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200&h=200&fit=crop',
    'medicalNotes': 'Alérgica a ciertos alimentos',
  },
  {
    'petId': 'pet2',
    'ownerId': 'user1',
    'name': 'Mittens',
    'species': 'Cat',
    'breed': 'Persa',
    'type': 'Gato',
    'age': 2,
    'birthdate': '2021-08-20',
    'weight': 4.2,
    'photoURL': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&h=200&fit=crop',
    'medicalNotes': 'Requiere cepillado diario',
  },
  {
    'petId': 'pet3',
    'ownerId': 'user2',
    'name': 'Rocky',
    'species': 'Dog',
    'breed': 'Bulldog Francés',
    'type': 'Perro',
    'age': 1,
    'birthdate': '2022-03-10',
    'weight': 12.0,
    'photoURL': 'https://images.unsplash.com/photo-1547407139-3c921a66005c?w=200&h=200&fit=crop',
    'medicalNotes': 'Activo y juguetón',
  },{
    'petId': 'pet4',
    'ownerId': 'user2',
    'name': 'RossTop',
    'species': 'Dog',
    'breed': 'Bulldog Francés',
    'type': 'Perro',
    'age': 1,
    'birthdate': '2022-03-10',
    'weight': 12.0,
    'photoURL': 'https://images.unsplash.com/photo-1547407139-3c921a66005c?w=200&h=200&fit=crop',
    'medicalNotes': 'Activo y juguetón',
  },
];

final List<Map<String, dynamic>> appointments = [
  {
    'appointmentId': 'apt1',
    'petId': 'pet1',
    'clientId': 'user1',
    'veterinarianId': 'doctor1',
    'clinicId': 'clinic1',
    'reason': 'Chequeo de salud',
    'date': DateTime.now().add(Duration(days: 1, hours: 2)),
    'status': 'confirmed',
    'notes': 'Revisión anual de vacunas',
  },
  {
    'appointmentId': 'apt2',
    'petId': 'pet2',
    'clientId': 'user1',
    'veterinarianId': 'doctor3',
    'clinicId': 'clinic2',
    'reason': 'Consulta dermatológica',
    'date': DateTime.now().add(Duration(days: 3)),
    'status': 'pending',
    'notes': 'Problemas de piel',
  },
  {
    'appointmentId': 'apt3',
    'petId': 'pet3',
    'clientId': 'user2',
    'veterinarianId': 'doctor5',
    'clinicId': 'clinic3',
    'reason': 'Vacunación',
    'date': DateTime.now().add(Duration(days: 5)),
    'status': 'confirmed',
    'notes': 'Vacuna anual',
  },
];

final List<Map<String, dynamic>> products = [
  {
    'productId': 'prod1',
    'name': 'Croquetas Premium',
    'price': 45000.0,
    'stock': 50,
    'description': 'Alimento balanceado para perros adultos',
    'category': 'Alimentos',
    'image': 'https://images.unsplash.com/photo-1601758228041-3caa3d3d3b1f?w=200&h=200&fit=crop',
    'createdAt': DateTime.now(),
    'createdBy': 'admin1',
  },
  {
    'productId': 'prod2',
    'name': 'Arena Sanitaria',
    'price': 25000.0,
    'stock': 30,
    'description': 'Arena sanitaria para gatos',
    'category': 'Higiene',
    'image': 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=200&h=200&fit=crop',
    'createdAt': DateTime.now(),
    'createdBy': 'admin1',
  },
  {
    'productId': 'prod3',
    'name': 'Juguete Interactivo',
    'price': 15000.0,
    'stock': 25,
    'description': 'Juguete para estimular la mente de tu mascota',
    'category': 'Juguetes',
    'image': 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=200&h=200&fit=crop',
    'createdAt': DateTime.now(),
    'createdBy': 'admin1',
  },
];

final List<Map<String, dynamic>> groomingServices = [
  {
    'serviceId': 'groom1',
    'petId': 'pet1',
    'clientId': 'user1',
    'serviceType': 'Full Grooming',
    'date': DateTime.now().add(Duration(days: 2)),
    'price': 80000.0,
    'status': 'pending',
    'staffId': 'staff1',
    'notes': 'Incluye baño, corte y cepillado',
  },
  {
    'serviceId': 'groom2',
    'petId': 'pet2',
    'clientId': 'user1',
    'serviceType': 'Corte de Uñas',
    'date': DateTime.now().add(Duration(days: 4)),
    'price': 25000.0,
    'status': 'confirmed',
    'staffId': 'staff2',
    'notes': 'Corte de uñas y limpieza de oídos',
  },
];

final List<Map<String, dynamic>> orders = [
  {
    'orderId': 'order1',
    'clientId': 'user1',
    'items': [
      {
        'productId': 'prod1',
        'name': 'Croquetas Premium',
        'quantity': 2,
        'price': 45000.0,
      },
      {
        'productId': 'prod3',
        'name': 'Juguete Interactivo',
        'quantity': 1,
        'price': 15000.0,
      },
    ],
    'total': 105000.0,
    'status': 'paid',
    'shippingAddress': {
      'street': 'Calle 15 #20-30',
      'city': 'Yopal',
      'zip': '850001',
    },
    'createdAt': DateTime.now(),
  },
];

// Función para obtener veterinarios por clínica
List<Map<String, dynamic>> getDoctorsByClinic(String clinicId) {
  print('clinicId: $clinicId');
  return users.where((user) => 
    user['role'] == 'veterinario' && user['clinicId'] == clinicId
  ).toList();
}

// Función para obtener clínica por ID
Map<String, dynamic>? getClinicById(String clinicId) {
  try {
    return clinics.firstWhere((clinic) => clinic['id'] == clinicId);
  } catch (e) {
    return null;
  }
}

// Función para obtener usuarios por rol (client, veterinario, admin)
List<Map<String, dynamic>> getUsersByRole(String role) {
  return users.where((user) => user['role'] == role).toList();
} 