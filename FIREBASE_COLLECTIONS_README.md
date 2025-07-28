# Colecciones de Firebase para MirallApp

Este documento describe las colecciones de Firebase creadas para la aplicación de citas veterinarias MirallApp.

## 📋 Estructura de Colecciones

### 1. Colección: `appointments` (Citas)

**Estructura del documento:**
```json
{
  "appointmentId": "String",       // ID único de la cita
  "petId": "String",               // Referencia al ID de la mascota
  "clientId": "String",            // Referencia al ID del cliente (usuario)
  "veterinarianId": "String",      // Referencia al ID del veterinario
  "clinicId": "String",            // Referencia al ID de la clínica
  "reason": "String",              // Motivo de la cita
  "date": "Timestamp",             // Fecha y hora de la cita
  "status": "String",              // Estado ('pending', 'confirmed', 'cancelled', etc.)
  "notes": "String"                // Notas adicionales del veterinario
}
```

**Estados posibles:**
- `pending`: Pendiente de confirmación
- `confirmed`: Confirmada
- `cancelled`: Cancelada
- `completed`: Completada
- `no_show`: No se presentó

### 2. Colección: `users` (Usuarios)

**Estructura del documento:**
```json
{
  "uid": "String",                 // ID único del usuario (usado como ID del documento)
  "name": "String",                // Nombre completo
  "email": "String",               // Correo electrónico
  "phone": "String",               // Teléfono
  "photoURL": "String",            // URL de la foto de perfil
  "role": "String",                // Rol ('client', 'veterinario', 'admin')
  "address": {                     // Dirección
    "street": "String",
    "city": "String",
    "zip": "String"
  },
  "createdAt": "Timestamp",        // Fecha de creación
  "lastLogin": "Timestamp",        // Último login
  
  // Campos adicionales para veterinarios
  "specialty": "String",           // Especialidad
  "clinicId": "String",            // ID de la clínica
  "experience": "String",          // Años de experiencia
  "education": "String"            // Formación académica
}
```

**Campos importantes:**
- `uid`: Se usa como ID del documento en Firestore, asociado al `uid` de Firebase Auth
- `role`: Define el tipo de usuario ('client', 'veterinario', 'admin')
- `address`: Objeto con información de dirección
- `specialty`, `clinicId`, `experience`, `education`: Solo para usuarios con rol 'veterinario'

### 3. Colección: `clinics` (Clínicas)

**Estructura del documento:**
```json
{
  "id": "String",                  // ID único de la clínica
  "name": "String",                // Nombre de la clínica
  "services": ["Array<String>"],   // Lista de servicios ofrecidos
  "image": "String",               // URL de la imagen principal
  "address": "String",             // Dirección
  "city": "String",                // Ciudad
  "latitude": "Number",            // Coordenada GPS - Latitud
  "longitude": "Number",           // Coordenada GPS - Longitud
  "nit": "String",                 // Número de identificación tributaria
  "phone": "String",               // Teléfono
  "rating": "Number",              // Calificación promedio (ej: 4.8)
  "description": "String"          // Descripción larga
}
```

**Campos importantes:**
- `services`: Array de strings con servicios como: 'Consulta general', 'Vacunación', 'Cirugía', 'Emergencias', 'Peluquería', etc.
- `rating`: Valor entre 0.0 y 5.0
- `latitude` y `longitude`: Coordenadas GPS para ubicación en mapas

### 4. Colección: `pets` (Mascotas)

**Estructura del documento:**
```json
{
  "petId": "String",               // ID único de la mascota
  "ownerId": "String",             // ID del propietario
  "name": "String",                // Nombre de la mascota
  "species": "String",             // Especie ('Dog', 'Cat', etc.)
  "breed": "String",               // Raza
  "type": "String",                // Tipo ('Perro', 'Gato', etc.)
  "age": "Number",                 // Edad en años
  "birthdate": "String",           // Fecha de nacimiento (formato ISO)
  "weight": "Number",              // Peso en kg
  "photoURL": "String",            // URL de la foto
  "medicalNotes": "String"         // Notas médicas
}
```

**Campos importantes:**
- `species`: Valores comunes: 'Dog', 'Cat', 'Bird', 'Fish', 'Rabbit', etc.
- `type`: Valores comunes: 'Perro', 'Gato', 'Ave', 'Pez', 'Conejo', etc.
- `birthdate`: Formato recomendado: 'YYYY-MM-DD'
- `medicalNotes`: Información médica relevante como alergias, tratamientos, etc.

### 5. Colección: `products` (Productos)

**Estructura del documento:**
```json
{
  "productId": "String",           // ID único del producto
  "name": "String",                // Nombre del producto
  "price": "Number",               // Precio
  "stock": "Number",               // Stock disponible
  "description": "String",         // Descripción
  "category": "String",            // Categoría
  "image": "String",               // URL de la imagen
  "createdAt": "Timestamp",        // Fecha de creación
  "createdBy": "String"            // ID del usuario que lo creó
}
```

### 6. Colección: `groomingServices` (Servicios de Peluquería)

**Estructura del documento:**
```json
{
  "serviceId": "String",           // ID único del servicio
  "petId": "String",               // ID de la mascota
  "clientId": "String",            // ID del cliente
  "serviceType": "String",         // Tipo de servicio
  "date": "Timestamp",             // Fecha del servicio
  "price": "Number",               // Precio
  "status": "String",              // Estado
  "staffId": "String",             // ID del personal
  "notes": "String",               // Notas
  "createdAt": "Timestamp"         // Fecha de creación
}
```

### 7. Colección: `orders` (Órdenes)

**Estructura del documento:**
```json
{
  "orderId": "String",             // ID único de la orden
  "clientId": "String",            // ID del cliente
  "items": [                       // Array de productos
    {
      "productId": "String",
      "name": "String",
      "quantity": "Number",
      "price": "Number"
    }
  ],
  "total": "Number",               // Total de la orden
  "status": "String",              // Estado
  "shippingAddress": {             // Dirección de envío
    "street": "String",
    "city": "String",
    "zip": "String"
  },
  "createdAt": "Timestamp"         // Fecha de creación
}
```

## 🚀 Cómo Usar las Colecciones

### 1. Poblar Datos Iniciales

```dart
import 'package:mirallapp/core/firebase_data_seeder.dart';

void main() async {
  final seeder = FirebaseDataSeeder();
  await seeder.seedAllData();
}
```

### 2. Crear una Nueva Cita

```dart
import 'package:mirallapp/features/home/data/appointment_repository.dart';
import 'package:mirallapp/features/home/presentation/appointment_model.dart';

void createAppointment() async {
  final repository = FirebaseAppointmentRepository();
  
  final appointment = Appointment(
    appointmentId: 'apt_${DateTime.now().millisecondsSinceEpoch}',
    petId: 'pet1',
    clientId: 'user1',
    veterinarianId: 'doctor1',
    clinicId: 'clinic1',
    reason: 'Consulta de rutina',
    date: DateTime.now().add(Duration(days: 7)),
    status: 'pending',
    notes: 'Primera consulta del año',
  );

  await repository.createAppointment(appointment);
}
```

### 3. Obtener Citas por Cliente

```dart
void getClientAppointments(String clientId) {
  final repository = FirebaseAppointmentRepository();
  
  repository.getAppointmentsByClient(clientId).listen(
    (appointments) {
      for (var appointment in appointments) {
        print('Cita: ${appointment.reason} - ${appointment.date}');
      }
    },
  );
}
```

### 4. Actualizar Estado de Cita

```dart
void updateAppointmentStatus(String appointmentId, String status) async {
  final repository = FirebaseAppointmentRepository();
  await repository.updateAppointmentStatus(appointmentId, status);
}
```

### 5. Crear una Nueva Mascota

```dart
import 'package:mirallapp/features/home/data/pet_repository.dart';
import 'package:mirallapp/features/home/presentation/pet_model.dart';

void createPet() async {
  final repository = FirebasePetRepository();
  
  final pet = Pet(
    petId: 'pet_${DateTime.now().millisecondsSinceEpoch}',
    ownerId: 'user1',
    name: 'Max',
    species: 'Dog',
    breed: 'Labrador Retriever',
    type: 'Perro',
    age: 2,
    birthdate: '2021-06-15',
    weight: 28.5,
    photoURL: 'https://example.com/max.jpg',
    medicalNotes: 'Vacunas al día, sin alergias conocidas',
  );

  await repository.createPet(pet);
}
```

### 6. Obtener Mascotas por Dueño

```dart
void getOwnerPets(String ownerId) {
  final repository = FirebasePetRepository();
  
  repository.getPetsByOwner(ownerId).listen(
    (pets) {
      for (var pet in pets) {
        print('Mascota: ${pet.name} (${pet.breed}) - ${pet.age} años');
      }
    },
  );
}
```

### 7. Actualizar Notas Médicas

```dart
void updatePetMedicalNotes(String petId, String medicalNotes) async {
  final repository = FirebasePetRepository();
  await repository.updatePetMedicalNotes(petId, medicalNotes);
}
```

### 8. Obtener Mascotas por Especie

```dart
void getPetsBySpecies(String species) {
  final repository = FirebasePetRepository();
  
  repository.getPetsBySpecies(species).listen(
    (pets) {
      for (var pet in pets) {
        print('${pet.name} - ${pet.breed} - Dueño: ${pet.ownerId}');
      }
    },
  );
}
```

### 9. Crear una Nueva Clínica

```dart
import 'package:mirallapp/features/home/data/clinic_repository.dart';
import 'package:mirallapp/features/home/presentation/clinic_model.dart';

void createClinic() async {
  final repository = FirebaseClinicRepository();
  
  final clinic = Clinic(
    id: 'clinic_${DateTime.now().millisecondsSinceEpoch}',
    name: 'Clínica Veterinaria San Francisco',
    services: ['Consulta general', 'Vacunación', 'Cirugía', 'Emergencias'],
    image: 'https://example.com/clinic_image.jpg',
    address: 'Calle 123 #45-67',
    city: 'Bogotá',
    latitude: 4.7110,
    longitude: -74.0721,
    nit: '900123456-7',
    phone: '+57 1 2345678',
    rating: 4.8,
    description: 'Clínica veterinaria especializada en atención integral para mascotas',
  );

  await repository.createClinic(clinic);
}
```

### 10. Obtener Clínicas por Ciudad

```dart
void getClinicsByCity(String city) {
  final repository = FirebaseClinicRepository();
  
  repository.getClinicsByCity(city).listen(
    (clinics) {
      for (var clinic in clinics) {
        print('${clinic.name} - ${clinic.address} - Rating: ${clinic.rating}');
      }
    },
  );
}
```

### 11. Obtener Clínicas por Servicio

```dart
void getClinicsByService(String service) {
  final repository = FirebaseClinicRepository();
  
  repository.getClinicsByService(service).listen(
    (clinics) {
      for (var clinic in clinics) {
        print('${clinic.name} - ${clinic.city} - Rating: ${clinic.rating}');
      }
    },
  );
}
```

### 12. Actualizar Calificación de Clínica

```dart
void updateClinicRating(String clinicId, double newRating) async {
  final repository = FirebaseClinicRepository();
  await repository.updateClinicRating(clinicId, newRating);
}
```

### 13. Crear un Nuevo Usuario

```dart
import 'package:mirallapp/features/home/data/user_repository.dart';
import 'package:mirallapp/features/home/presentation/user_model.dart';

void createUser() async {
  final repository = FirebaseUserRepository();
  
  final user = User(
    uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
    name: 'Juan Pérez',
    email: 'juan@example.com',
    phone: '+57 310 1234567',
    photoURL: 'https://example.com/photo.jpg',
    role: 'client',
    address: {
      'street': 'Calle 15 #20-30',
      'city': 'Bogotá',
      'zip': '110001',
    },
    createdAt: DateTime.now(),
    lastLogin: DateTime.now(),
  );

  await repository.createUser(user);
}
```

### 14. Obtener Usuarios por Rol

```dart
void getUsersByRole(String role) {
  final repository = FirebaseUserRepository();
  
  repository.getUsersByRole(role).listen(
    (users) {
      for (var user in users) {
        print('${user.name} - ${user.email} - ${user.role}');
      }
    },
  );
}
```

### 15. Obtener Veterinarios por Clínica

```dart
void getVeterinariansByClinic(String clinicId) {
  final repository = FirebaseUserRepository();
  
  repository.getVeterinariansByClinic(clinicId).listen(
    (users) {
      for (var user in users) {
        print('${user.name} - ${user.specialty} - ${user.experience}');
      }
    },
  );
}
```

### 16. Actualizar Perfil de Usuario

```dart
void updateUserProfile(String uid, Map<String, dynamic> updates) async {
  final repository = FirebaseUserRepository();
  await repository.updateUserProfile(uid, updates);
}
```

### 17. Obtener Usuario por Email

```dart
void getUserByEmail(String email) {
  final repository = FirebaseUserRepository();
  
  repository.getUserByEmail(email).listen(
    (user) {
      if (user != null) {
        print('Usuario encontrado: ${user.name} - ${user.role}');
      } else {
        print('Usuario no encontrado');
      }
    },
  );
}
```

## 🔒 Reglas de Seguridad

Configura las siguientes reglas de seguridad en Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para la colección de citas
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.veterinarianId == request.auth.uid ||
        resource.data.clinicId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clinicId
      );
      allow create: if request.auth != null && 
        request.resource.data.clientId == request.auth.uid;
      allow update: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.veterinarianId == request.auth.uid ||
        resource.data.clinicId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clinicId
      );
      allow delete: if request.auth != null && 
        resource.data.clientId == request.auth.uid;
    }

    // Reglas para la colección de usuarios
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }

    // Reglas para la colección de mascotas
    match /pets/{petId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }

    // Reglas para la colección de clínicas
    match /clinics/{clinicId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📊 Índices Recomendados

Crea los siguientes índices compuestos en Firebase Console:

1. **Colección: appointments**
   - `clientId` (Ascending) + `date` (Ascending)
   - `veterinarianId` (Ascending) + `date` (Ascending)
   - `clinicId` (Ascending) + `date` (Ascending)
   - `status` (Ascending) + `date` (Ascending)
   - `date` (Ascending) + `status` (Ascending)

2. **Colección: users**
   - `role` (Ascending) + `clinicId` (Ascending)

3. **Colección: pets**
   - `ownerId` (Ascending) + `createdAt` (Descending)
   - `species` (Ascending) + `breed` (Ascending)
   - `breed` (Ascending) + `age` (Ascending)
   - `ownerId` (Ascending) + `species` (Ascending)

4. **Colección: clinics**
   - `city` (Ascending) + `rating` (Descending)
   - `services` (Array contains) + `city` (Ascending)
   - `rating` (Descending) + `city` (Ascending)
   - `latitude` (Ascending) + `longitude` (Ascending)

## 🛠️ Archivos Creados

### Para Citas (Appointments)
1. `lib/features/home/presentation/appointment_model.dart` - Modelo de datos para citas
2. `lib/features/home/data/appointment_repository.dart` - Repositorio para operaciones de citas
3. `lib/features/home/presentation/appointment_provider.dart` - Provider para estado de citas

### Para Mascotas (Pets)
4. `lib/features/home/presentation/pet_model.dart` - Modelo de datos para mascotas
5. `lib/features/home/data/pet_repository.dart` - Repositorio para operaciones de mascotas
6. `lib/features/home/presentation/pet_provider.dart` - Provider para estado de mascotas

### Para Clínicas (Clinics)
7. `lib/features/home/presentation/clinic_model.dart` - Modelo de datos para clínicas
8. `lib/features/home/data/clinic_repository.dart` - Repositorio para operaciones de clínicas
9. `lib/features/home/presentation/clinic_provider.dart` - Provider para estado de clínicas

### Para Usuarios (Users)
10. `lib/features/home/presentation/user_model.dart` - Modelo de datos para usuarios
11. `lib/features/home/data/user_repository.dart` - Repositorio para operaciones de usuarios
12. `lib/features/home/presentation/user_provider.dart` - Provider para estado de usuarios

### Utilidades
13. `lib/core/firebase_data_seeder.dart` - Servicio para poblar datos iniciales
14. `lib/core/firebase_example_usage.dart` - Ejemplos de uso
15. `lib/core/pet_integration_example.dart` - Ejemplo completo de integración de mascotas con UI
16. `lib/core/clinic_integration_example.dart` - Ejemplo completo de integración de clínicas con UI
17. `lib/core/user_integration_example.dart` - Ejemplo completo de integración de usuarios con UI

## 📝 Notas Importantes

- Asegúrate de tener configurado Firebase en tu proyecto
- Las fechas se almacenan como `Timestamp` en Firestore
- Los IDs únicos se generan automáticamente o usando `DateTime.now().millisecondsSinceEpoch`
- **Para usuarios**: El `uid` del documento debe coincidir con el `uid` de Firebase Auth para mantener la asociación
- Implementa manejo de errores en todas las operaciones
- Usa transacciones para operaciones que requieren consistencia
- Considera implementar paginación para grandes volúmenes de datos

## 🔗 Enlaces Útiles

- [Documentación de Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Reglas de Seguridad](https://firebase.google.com/docs/firestore/security/get-started)
- [Índices Compuestos](https://firebase.google.com/docs/firestore/query-data/index-overview) 