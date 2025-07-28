import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTest {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Prueba la conexión básica con Firestore
  static Future<bool> testConnection() async {
    try {
      print('🔍 Probando conexión con Firestore...');
      
      // Intentar escribir un documento de prueba
      await _firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });
      
      print('✅ Conexión con Firestore exitosa');
      
      // Limpiar el documento de prueba
      await _firestore.collection('test').doc('connection_test').delete();
      
      return true;
    } catch (e) {
      print('❌ Error de conexión con Firestore: $e');
      return false;
    }
  }

  /// Prueba escribir en la colección users
  static Future<bool> testUsersCollection() async {
    try {
      print('🔍 Probando escritura en colección users...');
      
      final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('users').doc(testUserId).set({
        'uid': testUserId,
        'name': 'Usuario de Prueba',
        'email': 'test@example.com',
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Escritura en colección users exitosa');
      
      // Limpiar el documento de prueba
      await _firestore.collection('users').doc(testUserId).delete();
      
      return true;
    } catch (e) {
      print('❌ Error escribiendo en users: $e');
      return false;
    }
  }

  /// Prueba específicamente la creación de usuarios como en el registro real
  static Future<bool> testUserCreation() async {
    try {
      print('🔍 Probando creación de usuario real...');
      
      final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      final userData = {
        'uid': testUserId,
        'name': 'Usuario de Prueba',
        'email': 'test@example.com',
        'phone': '',
        'photoURL': '',
        'role': 'client',
        'address': {
          'street': '',
          'city': 'Ciudad de Prueba',
          'zip': ''
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'age': 25,
        'location': 'Ciudad de Prueba',
        'specialty': '',
        'clinicId': '',
        'experience': '',
        'education': '',
      };
      
      // Crear documento
      await _firestore.collection('users').doc(testUserId).set(userData);
      print('✅ Documento creado en Firestore');
      
      // Verificar que existe
      final docSnapshot = await _firestore.collection('users').doc(testUserId).get();
      if (docSnapshot.exists) {
        print('✅ Verificación: Documento existe con datos: ${docSnapshot.data()}');
        
        // Limpiar el documento de prueba
        await _firestore.collection('users').doc(testUserId).delete();
        print('✅ Documento de prueba eliminado');
        
        return true;
      } else {
        print('❌ Error: Documento no existe después de crearlo');
        return false;
      }
    } catch (e) {
      print('❌ Error en testUserCreation: $e');
      return false;
    }
  }

  /// Prueba la creación de usuario con el formato exacto del registro real
  static Future<bool> testRealUserCreation() async {
    try {
      print('🔍 Probando creación de usuario con formato real...');
      
      final testUserId = 'test_real_user_${DateTime.now().millisecondsSinceEpoch}';
      final userData = {
        'uid': testUserId,
        'name': 'Usuario Real de Prueba',
        'email': 'testreal@example.com',
        'phone': '',
        'photoURL': '',
        'role': 'client',
        'address': {
          'street': '',
          'city': 'Ciudad Real',
          'zip': ''
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'age': 30,
        'location': 'Ciudad Real',
        'specialty': '',
        'clinicId': '',
        'experience': '',
        'education': '',
      };
      
      print('📝 Creando documento con datos reales...');
      await _firestore.collection('users').doc(testUserId).set(userData);
      print('✅ Documento creado');
      
      // Verificar inmediatamente
      final docSnapshot = await _firestore.collection('users').doc(testUserId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print('✅ Verificación exitosa:');
        print('   - ID: ${docSnapshot.id}');
        print('   - Nombre: ${data?['name']}');
        print('   - Email: ${data?['email']}');
        print('   - Rol: ${data?['role']}');
        
        // Limpiar
        await _firestore.collection('users').doc(testUserId).delete();
        print('✅ Documento de prueba eliminado');
        
        return true;
      } else {
        print('❌ ERROR: Documento no existe después de crearlo');
        return false;
      }
    } catch (e) {
      print('❌ Error en testRealUserCreation: $e');
      return false;
    }
  }

  /// Ejecuta todas las pruebas
  static Future<void> runAllTests() async {
    print('🧪 Iniciando pruebas de Firestore...\n');
    
    final connectionTest = await testConnection();
    final usersTest = await testUsersCollection();
    final userCreationTest = await testUserCreation();
    final realUserTest = await testRealUserCreation();
    
    print('\n📊 Resultados de las pruebas:');
    print('Conexión: ${connectionTest ? "✅" : "❌"}');
    print('Colección users: ${usersTest ? "✅" : "❌"}');
    print('Creación de usuario: ${userCreationTest ? "✅" : "❌"}');
    print('Creación real: ${realUserTest ? "✅" : "❌"}');
    
    if (connectionTest && usersTest && userCreationTest && realUserTest) {
      print('\n🎉 Todas las pruebas pasaron. Firestore está configurado correctamente.');
    } else {
      print('\n⚠️ Algunas pruebas fallaron. Revisa la configuración de Firebase.');
    }
  }
} 