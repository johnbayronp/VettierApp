import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/explore/presentation/explore_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'package:mirallapp/shared/widgets/custom_animated_nav_bar.dart';
// Importar los providers adicionales
import 'features/home/presentation/user_provider.dart';
import 'features/home/presentation/pet_provider.dart';
import 'features/home/presentation/clinic_provider.dart';
import 'features/home/presentation/appointment_provider.dart';
import 'features/home/data/user_repository.dart';
import 'features/home/data/pet_repository.dart';
import 'features/home/data/clinic_repository.dart';
import 'features/home/data/appointment_repository.dart';
import 'core/firestore_test.dart';
// Importar las nuevas pantallas
import 'features/home/presentation/add_pet_screen.dart';
import 'features/home/presentation/schedule_appointment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Ejecutar pruebas de Firestore en desarrollo
  await FirestoreTest.runAllTests();
  
  runApp(const MirallaApp());
}

class MirallaApp extends StatelessWidget {
  const MirallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthRepository()),
        ),
        // Providers para las entidades de la aplicación
        ChangeNotifierProvider(
          create: (_) => UserProvider(repository: FirebaseUserRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PetProvider(repository: FirebasePetRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ClinicProvider(repository: FirebaseClinicRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(repository: FirebaseAppointmentRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MirallaApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/main': (_) => const MainNavigation(),
          '/add-pet': (_) => const AddPetScreen(),
          '/schedule-appointment': (_) => const ScheduleAppointmentScreen(),
        },
      ),
    );
  }
}

// Widget que maneja la lógica de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return StreamBuilder<bool>(
          stream: authProvider.isLoggedIn,
          builder: (context, snapshot) {
            // Mientras se está verificando el estado de autenticación
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF990045),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 80, color: Colors.white),
                      SizedBox(height: 24),
                      Text(
                        'Miralla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 32),
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Si hay un error en la verificación o no hay datos, mostrar login
            if (snapshot.hasError || !snapshot.hasData) {
              return const LoginScreen();
            }

            // Si el usuario está autenticado, mostrar la navegación principal
            if (snapshot.data == true) {
              return const MainNavigation();
            }

            // Si el usuario no está autenticado, mostrar la pantalla de login
            return const LoginScreen();
          },
        );
      },
    );
  }
}

class VetWelcomeScreen extends StatelessWidget {
  const VetWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF990045),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.pets, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Bienvenido a VetApp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Gestión de citas y pacientes para veterinarias',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(),
      ProductsScreen(),
      AppointmentsScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: CustomAnimatedNavBar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onNav,
          ),
        ),
      ),
    );
  }
}

// Pantallas dummy para Productos y Citas
class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Productos', style: TextStyle(fontSize: 24)));
  }
}

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Citas', style: TextStyle(fontSize: 24)));
  }
}
