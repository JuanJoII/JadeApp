import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'focus_provider.dart';

enum DeepWorkStatus { idle, active, completed, failed }

class Interruption {
  final DateTime timestamp;
  final String? appName;
  final Duration offsetFromStart;

  Interruption({
    required this.timestamp,
    this.appName,
    required this.offsetFromStart,
  });
}

class DeepWorkState {
  final DeepWorkStatus status;
  final int durationMinutes;
  final int remainingSeconds;
  final List<Interruption> interruptions;
  final String? taskTitle;
  final DateTime? startTime;

  DeepWorkState({
    this.status = DeepWorkStatus.idle,
    this.durationMinutes = 0,
    this.remainingSeconds = 0,
    this.interruptions = const [],
    this.taskTitle,
    this.startTime,
  });

  DeepWorkState copyWith({
    DeepWorkStatus? status,
    int? durationMinutes,
    int? remainingSeconds,
    List<Interruption>? interruptions,
    String? taskTitle,
    DateTime? startTime,
  }) {
    return DeepWorkState(
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      interruptions: interruptions ?? this.interruptions,
      taskTitle: taskTitle ?? this.taskTitle,
      startTime: startTime ?? this.startTime,
    );
  }
}

class DeepWorkNotifier extends StateNotifier<DeepWorkState> {
  final Ref ref;
  Timer? _timer;

  DeepWorkNotifier(this.ref) : super(DeepWorkState());

  void startChallenge(int minutes, String taskTitle) {
    final now = DateTime.now();
    state = DeepWorkState(
      status: DeepWorkStatus.active,
      durationMinutes: minutes,
      remainingSeconds: minutes * 60,
      taskTitle: taskTitle,
      startTime: now,
      interruptions: [],
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeChallenge();
      }
    });
  }

  void recordInterruption({String? appName}) {
    if (state.status == DeepWorkStatus.active && state.startTime != null) {
      final now = DateTime.now();
      final newInterruption = Interruption(
        timestamp: now,
        appName: appName,
        offsetFromStart: now.difference(state.startTime!),
      );
      state = state.copyWith(
        interruptions: [...state.interruptions, newInterruption],
      );
    }
  }

  void _completeChallenge() {
    _timer?.cancel();
    
    // Calculate reward
    // Focus Total: Max reward
    // Fragmented: Reduced reward
    double baseReward = state.durationMinutes.toDouble();
    double multiplier = 1.0;
    
    if (state.interruptions.isNotEmpty) {
      multiplier = (1.0 - (state.interruptions.length * 0.2)).clamp(0.1, 0.9);
    }
    
    double finalReward = baseReward * multiplier;
    ref.read(focusProvider.notifier).addFocus(finalReward);
    
    state = state.copyWith(status: DeepWorkStatus.completed);
  }

  void abandonChallenge() {
    _timer?.cancel();
    // We transition to completed so the user can see the report
    // but maybe with 0 reward or reduced reward if they didn't finish?
    // For now, let's just show the report with the current interruptions.
    state = state.copyWith(status: DeepWorkStatus.completed);
  }

  void cancelChallenge() {
    _timer?.cancel();
    state = DeepWorkState(status: DeepWorkStatus.idle);
  }

  void reset() {
    state = DeepWorkState(status: DeepWorkStatus.idle);
  }
}

final deepWorkProvider = StateNotifierProvider<DeepWorkNotifier, DeepWorkState>((ref) {
  return DeepWorkNotifier(ref);
});
