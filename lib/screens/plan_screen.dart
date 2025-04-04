import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../data/models/exercise.dart';
import 'dart:math';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  List<String> trainingDays = [];
  final List<String> weekDays = [
    'Pon',
    'Wt',
    'Śr',
    'Czw',
    'Pt',
    'Sob',
    'Niedz'
  ];
  int selectedDayIndex = DateTime.now().weekday - 1; // 0 = Pon

  Map<String, List<Exercise>> exercisesByGroup = {};
  Map<String, List<Exercise>> generatedPlans = {};

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final box = await Hive.openBox('settingsBox');
    final storedDays =
        box.get('selectedTrainingDays', defaultValue: ['Pon', 'Śr', 'Pt']);
    await fetchAllExercises();
    setState(() {
      trainingDays = List<String>.from(storedDays);
    });
  }

  Future<void> fetchAllExercises() async {
    final List<String> groups = [
      'Chest',
      'Triceps',
      'Biceps',
      'Backs',
      'Shoulders',
      'Legs',
      'ABS',
      'Cardio'
    ];
    final FirebaseAuth auth = FirebaseAuth.instance;
    final DocumentReference firestore = FirebaseFirestore.instance.collection('Users').doc(auth.currentUser!.uid);

    for (final group in groups) {
      final snapshot = await firestore
          .collection('exercises')
          .doc(group)
          .collection('exercise')
          .get();

      exercisesByGroup[group] = snapshot.docs
          .map((doc) => Exercise(name: doc['name'], muscleGroup: group))
          .toList();
    }

    setState(() {});
  }

  List<Exercise> getPlanForDay(String day) {
    if (generatedPlans.containsKey(day)) return generatedPlans[day]!;

    List<Exercise> pick(String group, int count) {
      final list = exercisesByGroup[group] ?? [];
      list.shuffle(_random);
      return list.take(count).toList();
    }

    final index = trainingDays.indexOf(day);
    if (index == -1) return [];

    List<Exercise> plan = [];
    switch (trainingDays.length) {
      case 3:
        switch (index) {
          case 0:
            plan = [
              ...pick('Chest', 3),
              ...pick('Triceps', 3),
              ...pick('Cardio', 1)
            ];
            break;
          case 1:
            plan = [
              ...pick('Backs', 3),
              ...pick('Biceps', 3),
              ...pick('Cardio', 1)
            ];
            break;
          case 2:
            plan = [
              ...pick('Legs', 3),
              ...pick('Shoulders', 3),
              ...pick('ABS', 3)
            ];
            break;
        }
        break;

      case 5:
        switch (index) {
          case 0:
            plan = [...pick('Chest', 5), ...pick('Cardio', 1)];
            break;
          case 1:
            plan = [...pick('Triceps', 5), ...pick('ABS', 3)];
            break;
          case 2:
            plan = [...pick('Backs', 5), ...pick('Cardio', 1)];
            break;
          case 3:
            plan = [...pick('Biceps', 5), ...pick('ABS', 3)];
            break;
          case 4:
            plan = [...pick('Legs', 5), ...pick('Shoulders', 3)];
            break;
        }
        break;

      case 7:
        switch (index) {
          case 0:
            plan = [
              ...pick('Chest', 3),
              ...pick('Triceps', 2),
              ...pick('ABS', 2)
            ];
            break;
          case 1:
            plan = [...pick('Backs', 4), ...pick('Cardio', 2)];
            break;
          case 2:
            plan = [...pick('Legs', 4), ...pick('Shoulders', 2)];
            break;
          case 3:
            plan = [
              ...pick('Chest', 3),
              ...pick('Biceps', 2),
              ...pick('ABS', 2)
            ];
            break;
          case 4:
            plan = [...pick('Triceps', 4), ...pick('Shoulders', 2)];
            break;
          case 5:
            plan = [...pick('Legs', 3), ...pick('Backs', 2), ...pick('ABS', 2)];
            break;
          case 6:
            plan = [...pick('Cardio', 3), ...pick('ABS', 2)];
            break;
        }
        break;
    }

    generatedPlans[day] = plan;
    print('Generated plan for $day: $plan');
    return plan;
  }

  void showSetEntryDialog(
      BuildContext context, Exercise exercise, int exerciseIndex) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
              decoration: const InputDecoration(
                labelText: 'Powtórzenia',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
              ),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
              decoration: const InputDecoration(
                labelText: 'Obciążenie (kg)',
                labelStyle:
                    TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj',
                style: TextStyle(color: Color.fromARGB(255, 255, 225, 155))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 225, 155),
                foregroundColor: const Color.fromARGB(255, 51, 51, 51)),
            onPressed: () async {
              final int reps = int.tryParse(repsController.text) ?? 0;
              final double weight =
                  double.tryParse(weightController.text) ?? 0.0;

              final box = await Hive.openBox('progressBox');
              final key = exercise.name;
              List<Map> currentSets =
                  List<Map>.from(box.get(key, defaultValue: []));
              currentSets.add({'reps': reps, 'weight': weight});
              await box.put(key, currentSets);

              Navigator.of(context).pop();
            },
            child: const Text('Zapisz',
                style: TextStyle(color: Color.fromARGB(255, 51, 51, 51))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = weekDays[selectedDayIndex];
    final isTrainingDay = trainingDays.contains(today);
    final todayPlan = isTrainingDay ? getPlanForDay(today) : [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(weekDays[index]),
                    selected: selectedDayIndex == index,
                    onSelected: (_) => setState(() => selectedDayIndex = index),
                    selectedColor: const Color.fromARGB(255, 255, 225, 155),
                    backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    showCheckmark: false,
                    labelStyle: selectedDayIndex == index
                        ? const TextStyle(
                            color: Color.fromARGB(255, 51, 51, 51),
                            fontSize: 14)
                        : const TextStyle(
                            color: Color.fromARGB(255, 255, 225, 155),
                            fontSize: 14),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isTrainingDay
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todayPlan.length,
                    itemBuilder: (context, index) {
                      final ex = todayPlan[index];
                      return Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          title: Text(ex.name,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 225, 155))),
                          subtitle: Text(ex.muscleGroup,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 225, 155))),
                          onTap: () => showSetEntryDialog(context, ex, index),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/img/resting_icon.png',
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Czas na odpoczynek',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 225, 155),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
