import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'focus_provider.dart';

enum DeepWorkStatus { idle, active, completed, failed }

class DeepWorkState {
  final DeepWorkStatus status;
  final int durationMinutes;
  final int remainingSeconds;
  final int interruptions;
  final String? taskTitle;

  DeepWorkState({
    this.status = DeepWorkStatus.idle,
    this.durationMinutes = 0,
    this.remainingSeconds = 0,
    this.interruptions = 0,
    this.taskTitle,
  });

  DeepWorkState copyWith({
    DeepWorkStatus? status,
    int? durationMinutes,
    int? remainingSeconds,
    int? interruptions,
    String? taskTitle,
  }) {
    return DeepWorkState(
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      interruptions: interruptions ?? this.interruptions,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }
}

class DeepWorkNotifier extends StateNotifier<DeepWorkState> {
  final Ref ref;
  Timer? _timer;

  DeepWorkNotifier(this.ref) : super(DeepWorkState());

  void startChallenge(int minutes, String taskTitle) {
    state = DeepWorkState(
      status: DeepWorkStatus.active,
      durationMinutes: minutes,
      remainingSeconds: minutes * 60,
      taskTitle: taskTitle,
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

  void recordInterruption() {
    if (state.status == DeepWorkStatus.active) {
      state = state.copyWith(interruptions: state.interruptions + 1);
    }
  }

  void _completeChallenge() {
    _timer?.cancel();
    
    // Calculate reward
    // Focus Total: Max reward
    // Fragmented: Reduced reward
    double baseReward = state.durationMinutes.toDouble();
    double multiplier = 1.0;
    
    if (state.interruptions > 0) {
      multiplier = (1.0 - (state.interruptions * 0.2)).clamp(0.1, 0.9);
    }
    
    double finalReward = baseReward * multiplier;
    ref.read(focusProvider.notifier).addFocus(finalReward);
    
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
