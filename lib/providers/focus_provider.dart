import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusState {
  final double level; // 0.0 to 100.0
  final DateTime lastUpdate;

  FocusState({
    required this.level,
    required this.lastUpdate,
  });

  FocusState copyWith({
    double? level,
    DateTime? lastUpdate,
  }) {
    return FocusState(
      level: level ?? this.level,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class FocusNotifier extends StateNotifier<FocusState> with WidgetsBindingObserver {
  FocusNotifier() : super(FocusState(level: 100.0, lastUpdate: DateTime.now())) {
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

  Future<void> _loadFocus() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getDouble(_focusKey) ?? 100.0;
    final lastUpdateStr = prefs.getString(_lastUpdateKey);
    final lastUpdate = lastUpdateStr != null 
        ? DateTime.parse(lastUpdateStr) 
        : DateTime.now();
    
    state = FocusState(level: level, lastUpdate: lastUpdate);
  }

  Future<void> _saveFocus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_focusKey, state.level);
    await prefs.setString(_lastUpdateKey, state.lastUpdate.toIso8601String());
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
}

final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier();
});
