import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../screens/dashboard_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth_screen.dart';

class GymProgressApp extends StatefulWidget {
  const GymProgressApp({super.key});

  @override
  State<GymProgressApp> createState() => _GymProgressAppState();
}

class _GymProgressAppState extends State<GymProgressApp> {
  int _currentIndex = 0;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final box = await Hive.openBox('authBox');
    setState(() {
      isAuthenticated = box.get('uid') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
     return MaterialApp(
  title: 'GymProgress Planner',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    useMaterial3: true,
  ),
  initialRoute: isAuthenticated ? '/home' : '/auth',
  routes: {
    '/auth': (context) => const AuthScreen(),
    '/home': (context) => GymAppScaffold(
      currentIndex: _currentIndex,
      onTabChange: (index) => setState(() => _currentIndex = index),
    ),
  },
);

  }
}

class GymAppScaffold extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChange;

  const GymAppScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    const pages = [
      DashboardScreen(),
      PlanScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        shadowColor: const Color.fromARGB(255, 51, 51, 51),
        centerTitle: true,
        title: Image.asset('assets/img/logo_light.png', height: 100),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        selectedItemColor: const Color.fromARGB(255, 255, 225, 155),
        unselectedItemColor: Colors.white,
        onTap: onTabChange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ustawienia'),
        ],
      ),
    );
  }
}

