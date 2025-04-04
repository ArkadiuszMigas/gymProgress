import 'exercise.dart';
import 'set_entry.dart';

class Workout {
  final DateTime date;
  final List<WorkoutExercise> exercises;

  const Workout({
    required this.date,
    required this.exercises,
  });
}

class WorkoutExercise {
  final Exercise exercise;
  final List<SetEntry> sets;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
  });
}