// lib/src/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedExercise;
  List<String> allExercises = [];
  List<FlSpot> dataPoints = [];
  Map<String, int> repCounts = {};

  @override
  void initState() {
    super.initState();
    loadExercisesFromFirestore();
  }

  Future<void> loadExercisesFromFirestore() async {
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
    final Set<String> exerciseSet = {};

    for (final group in groups) {
      final snapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .doc(group)
          .collection('exercise')
          .get();
      for (var doc in snapshot.docs) {
        exerciseSet.add(doc['name']);
      }
    }

    setState(() {
      allExercises = exerciseSet.toList();
      selectedExercise = allExercises.isNotEmpty ? allExercises.first : null;
      loadExerciseProgress();
    });
  }

  Future<void> loadExerciseProgress() async {
    if (selectedExercise == null) return;
    final box = await Hive.openBox('progressBox');
    final entries =
        box.toMap().entries.where((e) => e.key == selectedExercise).toList();

    List<FlSpot> spots = [];
    Map<String, int> repMap = {};
    int index = 0;
    for (var entry in entries) {
      final sets = List<Map>.from(entry.value);
      for (var set in sets) {
        final weight = set['weight']?.toDouble() ?? 0.0;
        final reps = set['reps'] ?? 0;
        spots.add(FlSpot(index.toDouble(), weight));
        index++;
        repMap["reps"] = (repMap["reps"] ?? 0) + (reps as int);
      }
    }

    setState(() {
      dataPoints = spots;
      repCounts = repMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
              iconEnabledColor: const Color.fromARGB(255, 255, 225, 155),
              focusColor: const Color.fromARGB(255, 255, 225, 155),
              value: selectedExercise,
              items: allExercises
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() {
                selectedExercise = val;
                loadExerciseProgress();
              }),
            ),
            const SizedBox(height: 24),
            Text('Progress ciężaru',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color.fromARGB(255, 255, 225, 155))),
            const SizedBox(height: 12),
            Expanded(
              child: dataPoints.isEmpty
                  ? const Center(
                      child: Text('Brak danych',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 225, 155))))
                  : LineChart(
                      LineChartData(
                        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 225, 155)),
                                );
                              },
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
                            isCurved: true,
                            barWidth: 3,
                            color: const Color.fromARGB(255, 255, 225, 155),
                            belowBarData: BarAreaData(show: false),
                          )
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Text('Średnia liczba powtórzeń',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color.fromARGB(255, 255, 225, 155))),
            const SizedBox(height: 12),
            repCounts.isEmpty
                ? const Text('Brak danych',
                    style: TextStyle(color: Color.fromARGB(255, 255, 225, 155)))
                : SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: repCounts['reps']?.toDouble() ?? 0,
                            title: '${repCounts['reps'] ?? 0}',
                            color: const Color.fromARGB(255, 255, 225, 155),
                            radius: 50,
                            titleStyle: const TextStyle(
                                color: Color.fromARGB(255, 51, 51, 51),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
