// lib/src/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  late String _groupController = muscleGroup.first;
  final List<String> muscleGroup = <String>[
    'ABS',
    'Backs',
    'Biceps',
    'Cardio',
    'Chest',
    'Legs',
    'Shoulders',
    'Triceps',
  ];

  int selectedPlanDays = 3;
  final List<String> daysOfWeek = [
    'Pon',
    'Wt',
    'Śr',
    'Czw',
    'Pt',
    'Sob',
    'Niedz'
  ];
  Set<String> selectedTrainingDays = {'Pon', 'Śr', 'Pt'};

  @override
  void initState() {
    super.initState();
    loadSettingsFromHive();
  }

  Future<void> loadSettingsFromHive() async {
    final box = await Hive.openBox('settingsBox');
    final storedPlanDays = box.get('selectedPlanDays', defaultValue: 3);
    final storedDays =
        box.get('selectedTrainingDays', defaultValue: ['Pon', 'Śr', 'Pt']);
    setState(() {
      selectedPlanDays = storedPlanDays;
      selectedTrainingDays = Set<String>.from(storedDays);
    });
  }

  Future<void> addExerciseManually() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _groupController.isEmpty) return;
    final CollectionReference collection = FirebaseFirestore.instance
        .collection('exercises')
        .doc(_groupController)
        .collection('exercise');

    await collection.add({
      'name': name,
    });

    _nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ćwiczenie zostało dodane!')),
    );
  }

  Future<void> saveSettingsToHive() async {
    final box = await Hive.openBox('settingsBox');
    await box.put('selectedPlanDays', selectedPlanDays);
    await box.put('selectedTrainingDays', selectedTrainingDays.toList());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ustawienia zostały zapisane!')),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final box = await Hive.openBox('authBox');
    await box.delete('uid');
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = selectedTrainingDays.length == selectedPlanDays;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ustawienia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 225, 155),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color.fromARGB(255, 51, 51, 51),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan tygodniowy:',
                    style: TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [3, 5, 7].map((count) {
                      return ChoiceChip(
                        label: Text('$count dni'),
                        selected: selectedPlanDays == count,
                        selectedColor: const Color.fromARGB(255, 255, 225, 155),
                        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                        showCheckmark: false,
                        labelStyle: selectedPlanDays == count
                            ? const TextStyle(
                                color: Color.fromARGB(255, 51, 51, 51),
                                fontSize: 14)
                            : const TextStyle(
                                color: Color.fromARGB(255, 255, 225, 155),
                                fontSize: 14),
                        onSelected: (_) {
                          setState(() {
                            selectedPlanDays = count;
                            if (count == 7) {
                              selectedTrainingDays = daysOfWeek.toSet();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color.fromARGB(255, 51, 51, 51),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dni treningowe (przy 3/5/7):',
                    style: TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: daysOfWeek.map((day) {
                      return FilterChip(
                        label: Text(day),
                        selected: selectedTrainingDays.contains(day),
                        selectedColor: const Color.fromARGB(255, 255, 225, 155),
                        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                        showCheckmark: false,
                        labelStyle: selectedTrainingDays.contains(day)
                            ? const TextStyle(
                                color: Color.fromARGB(255, 51, 51, 51),
                                fontSize: 14)
                            : const TextStyle(
                                color: Color.fromARGB(255, 255, 225, 155),
                                fontSize: 14),
                        onSelected: selectedPlanDays == 7
                            ? null
                            : (bool value) {
                                setState(() {
                                  if (value) {
                                    selectedTrainingDays.add(day);
                                  } else {
                                    selectedTrainingDays.remove(day);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color.fromARGB(255, 51, 51, 51),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dodaj ćwiczenie ręcznie:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 225, 155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 225, 155)),
                    cursorColor: const Color.fromARGB(255, 255, 225, 155),
                    
                    decoration: const InputDecoration(
                      labelText: 'Nazwa ćwiczenia',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _groupController,
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 225, 155)),
                    iconEnabledColor: const Color.fromARGB(255, 255, 225, 155),
                    focusColor: const Color.fromARGB(255, 255, 225, 155),
                    elevation: 16,
                    underline: Container(
                        height: 0,
                        color: const Color.fromARGB(255, 255, 225, 155)),
                    onChanged: (String? value) {
                      setState(() {
                        _groupController = value!;
                      });
                    },
                    items: muscleGroup
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: addExerciseManually,
                    icon: const Icon(Icons.add),
                    label: const Text('Dodaj ćwiczenie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 225, 155),
                      foregroundColor: const Color.fromARGB(255, 51, 51, 51),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            color: Color.fromARGB(255, 51, 51, 51),
            child: ListTile(
              leading:
                  Icon(Icons.lock, color: Color.fromARGB(255, 255, 225, 155)),
              title: Text('Wersja Premium',
                  style: TextStyle(color: Color.fromARGB(255, 255, 225, 155))),
              subtitle: Text(
                  'Dostęp do posiłków, integracja z Fitatu (wkrótce)',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 225, 155),
              foregroundColor: const Color.fromARGB(255, 51, 51, 51),
            ),
            onPressed: canSave ? saveSettingsToHive : null,
            icon: const Icon(Icons.save),
            label: const Text('Zapisz ustawienia'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 225, 155),
              foregroundColor: const Color.fromARGB(255, 51, 51, 51),
            ),
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Wyloguj się'),
          ),
        ],
      ),
    );
  }
}
