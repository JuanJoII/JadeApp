import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'focus_provider.dart';

class RitualTask {
  final String id;
  final String title;
  final String importance;
  final int points;
  final bool isCompleted;

  RitualTask({
    required this.id,
    required this.title,
    required this.importance,
    required this.points,
    this.isCompleted = false,
  });

  RitualTask copyWith({
    bool? isCompleted,
  }) {
    return RitualTask(
      id: id,
      title: title,
      importance: importance,
      points: points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'importance': importance,
    'points': points,
    'isCompleted': isCompleted,
  };

  factory RitualTask.fromJson(Map<String, dynamic> json) => RitualTask(
    id: json['id'],
    title: json['title'],
    importance: json['importance'],
    points: json['points'],
    isCompleted: json['isCompleted'],
  );
}

class RitualNotifier extends StateNotifier<List<RitualTask>> {
  final Ref ref;
  RitualNotifier(this.ref) : super([]) {
    _loadRitual();
  }

  static const String _ritualKey = 'daily_ritual';

  Future<void> _loadRitual() async {
    final prefs = await SharedPreferences.getInstance();
    final ritualStr = prefs.getString(_ritualKey);
    if (ritualStr != null) {
      final List<dynamic> decoded = jsonDecode(ritualStr);
      state = decoded.map((item) => RitualTask.fromJson(item)).toList();
    } else {
      // Default tasks
      state = [
        RitualTask(
          id: '1',
          title: 'Meditar 10 minutos',
          importance: 'Importante',
          points: 15, // Focus units instead of XP
        ),
        RitualTask(
          id: '2',
          title: 'Planear el día sin pantallas',
          importance: 'Esencial',
          points: 30,
        ),
      ];
      _saveRitual();
    }
  }

  Future<void> _saveRitual() async {
    final prefs = await SharedPreferences.getInstance();
    final ritualStr = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_ritualKey, ritualStr);
  }

  void addTask(String title, String importance, int points) {
    final newTask = RitualTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      importance: importance,
      points: points,
    );
    state = [...state, newTask];
    _saveRitual();
  }

  void toggleTask(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          _handleTaskToggle(task)
        else
          task,
    ];
    _saveRitual();
  }

  RitualTask _handleTaskToggle(RitualTask task) {
    final newStatus = !task.isCompleted;
    if (newStatus) {
      // Add focus when completed
      ref.read(focusProvider.notifier).addFocus(task.points.toDouble());
    } else {
      // Remove focus if uncompleted (optional, but let's stick to adding)
      // Actually, maybe we shouldn't remove it to avoid frustration
    }
    return task.copyWith(isCompleted: newStatus);
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
    _saveRitual();
  }
}

final ritualProvider = StateNotifierProvider<RitualNotifier, List<RitualTask>>((ref) {
  return RitualNotifier(ref);
});
