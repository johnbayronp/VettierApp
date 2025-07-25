final List<Map<String, dynamic>> clinics = [
  {
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
    'description': 'Clínica veterinaria integral con más de 10 años de experiencia. Ofrecemos servicios de salud preventiva, cirugías, consultas especializadas y peluquería canina. Nuestro equipo de veterinarios altamente calificados está comprometido con el bienestar de tus mascotas.'
  },
  {
    'name': 'Peluquería Canina Happy',
    'services': ['Peluquería', 'Salud'],
    'image': 'https://picsum.photos/200/300?random=2',
    'address': 'Av. 15 #45-10',
    'city': 'Yopal',
    'latitude': 5.320056, 
    'longitude': -72.409906,
    'nit': '900654321-2',
    'phone': '+57 311 7654321',
    'rating': 4.6,
    'description': 'Especialistas en peluquería y estética canina. Ofrecemos servicios de baño, corte de pelo, corte de uñas, limpieza de oídos y tratamientos especiales para la piel. También realizamos consultas básicas de salud y vacunación.'
  },
  {
    'name': 'Consultorio Felino',
    'services': ['Consulta'],
    'image': 'https://picsum.photos/200/300?random=3',
    'address': 'Calle 8 #12-50',
    'city': 'Yopal',
    'latitude': 5.3354,
    'longitude': -72.3751,
    'nit': '900789123-3',
    'phone': '+57 312 9876543',
    'rating': 4.9,
    'description': 'Consultorio especializado exclusivamente en gatos. Nuestros veterinarios felinos tienen amplia experiencia en el comportamiento, nutrición y salud de los gatos. Ofrecemos consultas especializadas, vacunación y tratamientos específicos para felinos.'
  },
  {
    'name': 'NutriVet',
    'services': ['Nutrición', 'Consulta'],
    'image': 'https://picsum.photos/200/300?random=4',
    'address': 'Cra 7 #33-21',
    'city': 'Yopal',
    'latitude': 5.3354,
    'longitude': -72.3751,
    'nit': '900321987-4',
    'phone': '+57 313 4567890',
    'rating': 4.7,
    'description': 'Centro especializado en nutrición veterinaria. Ofrecemos asesoría nutricional personalizada, dietas especiales para mascotas con condiciones médicas, control de peso y consultas generales. Contamos con una amplia variedad de alimentos premium y suplementos.'
  },
  {
    'name': 'Clínica Integral',
    'services': ['Salud', 'Nutrición', 'Peluquería'],
    'image': 'https://picsum.photos/200/300?random=5',
    'address': 'Av. 9 #22-11',
    'city': 'Yopal',
    'latitude': 5.319418, 
    'longitude': -72.392215,
    'nit': '900456789-5',
    'phone': '+57 314 6543210',
    'rating': 4.5,
    'description': 'Clínica veterinaria integral que ofrece servicios completos para el cuidado de mascotas. Incluimos medicina preventiva, cirugías, nutrición especializada, peluquería y emergencias 24/7. Nuestro equipo multidisciplinario garantiza la mejor atención para tu mascota.'
  },
];

final List<Map<String, String>> pets = [
  {'name': 'Max', 'image': 'https://picsum.photos/200/300?random=6', 'age': '3', 'breed': 'Labrador', 'type': 'Perro'},
  {'name': 'Luna', 'image': 'https://picsum.photos/200/300?random=7', 'age': '2', 'breed': 'Siames', 'type': 'Gato'},
  {'name': 'Rocky', 'image': 'https://picsum.photos/200/300?random=8', 'age': '1', 'breed': 'Bulldog', 'type': 'Perro'},
  {'name': 'Milo', 'image': 'https://picsum.photos/200/300?random=9', 'age': '4', 'breed': 'Loro Amazónico', 'type': 'Loro'},
];

final List<Map<String, dynamic>> users = [
  {
    'uid': 'user1',
    'name': 'Jennifer López',
    'email': 'jennifer@email.com',
    'phone': '+57 300 1234567',
    'photoURL': 'https://picsum.photos/200/300?random=10',
    'role': 'client',
    'address': {
      'street': 'Calle 123',
      'city': 'Bogotá',
      'zip': '110111',
    },
    'createdAt': '2023-01-10',
    'lastLogin': '2023-07-24',
  },
  {
    'uid': 'user2',
    'name': 'Carlos Pérez',
    'email': 'carlos@email.com',
    'phone': '+57 301 7654321',
    'photoURL': 'https://picsum.photos/200/300?random=11',
    'role': 'veterinarian',
    'address': {
      'street': 'Av. 45',
      'city': 'Medellín',
      'zip': '050021',
    },
    'createdAt': '2023-02-05',
    'lastLogin': '2023-07-23',
  },
];

final List<Map<String, dynamic>> appointments = [
  {
    'appointmentId': 'a1',
    'petId': 'p1',
    'clientId': 'user1',
    'veterinarianId': 'user2',
    'reason': 'Chequeo de salud',
    'date': '2025-08-01T09:00:00',
    'status': 'pending',
    'notes': '',
  },
  {
    'appointmentId': 'a2',
    'petId': 'p2',
    'clientId': 'user1',
    'veterinarianId': 'user2',
    'reason': 'Vacunación anual',
    'date': '2025-08-02T11:30:00',
    'status': 'confirmed',
    'notes': '',
  },
  {
    'appointmentId': 'a3',
    'petId': 'p3',
    'clientId': 'user1',
    'veterinarianId': 'user2',
    'reason': 'Consulta dermatológica',
    'date': '2025-08-03T15:00:00',
    'status': 'pending',
    'notes': '',
  },
]; 