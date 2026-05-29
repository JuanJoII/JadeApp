import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusState {
  final double level; // 0.0 to 100.0
  final DateTime lastUpdate;
  final double maxMinutes; // Capacidad configurada del reservorio en minutos (ej. 60, 90, 120, etc.)

  FocusState({
    required this.level,
    required this.lastUpdate,
    required this.maxMinutes,
  });

  FocusState copyWith({
    double? level,
    DateTime? lastUpdate,
    double? maxMinutes,
  }) {
    return FocusState(
      level: level ?? this.level,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      maxMinutes: maxMinutes ?? this.maxMinutes,
    );
  }
}

class FocusNotifier extends StateNotifier<FocusState> with WidgetsBindingObserver {
  FocusNotifier() : super(FocusState(level: 100.0, lastUpdate: DateTime.now(), maxMinutes: 120.0)) {
    _loadFocus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFocus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static const String _focusKey = 'focus_level';
  static const String _lastUpdateKey = 'focus_last_update';
  static const String _maxMinutesKey = 'max_focus_minutes';

  Future<void> _loadFocus() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getDouble(_focusKey) ?? 100.0;
    final maxMinutes = prefs.getDouble(_maxMinutesKey) ?? 120.0;
    final lastUpdateStr = prefs.getString(_lastUpdateKey);
    final lastUpdate = lastUpdateStr != null 
        ? DateTime.parse(lastUpdateStr) 
        : DateTime.now();
    
    state = FocusState(level: level, lastUpdate: lastUpdate, maxMinutes: maxMinutes);
    debugPrint("JADE_DEBUG: Loaded focus level = $level%, maxMinutes = $maxMinutes, lastUpdate = $lastUpdate");
  }

  Future<void> _saveFocus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_focusKey, state.level);
    await prefs.setDouble(_maxMinutesKey, state.maxMinutes);
    await prefs.setString(_lastUpdateKey, state.lastUpdate.toIso8601String());
    debugPrint("JADE_DEBUG: Saved focus level = ${state.level}%, maxMinutes = ${state.maxMinutes}");
  }

  void addFocus(double amount) {
    final newLevel = (state.level + amount).clamp(0.0, 100.0);
    state = state.copyWith(level: newLevel, lastUpdate: DateTime.now());
    _saveFocus();
  }

  void drainFocus(double amount) {
    final newLevel = (state.level - amount).clamp(0.0, 100.0);
    state = state.copyWith(level: newLevel, lastUpdate: DateTime.now());
    _saveFocus();
  }

  void setLevel(double level) {
    state = state.copyWith(level: level.clamp(0.0, 100.0), lastUpdate: DateTime.now());
    _saveFocus();
  }

  void setMaxMinutes(double minutes) {
    state = state.copyWith(maxMinutes: minutes.clamp(15.0, 480.0), lastUpdate: DateTime.now());
    _saveFocus();
  }
}

final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier();
});
