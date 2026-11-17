import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/services/app_loading_service.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';
import 'package:hawiisaac/features/loggin/model/active_workout_session_models.dart';
import 'package:hawiisaac/features/loggin/model/workout_logging_preset.dart';
import 'package:hawiisaac/features/loggin/services/loggin_api_service.dart';
import 'package:hawiisaac/routes/app_routes.dart';

class WorkoutSetState {
  final RxInt setNumber;
  final RxDouble kg;
  final RxInt reps;
  final RxBool isCompleted;
  final RxnInt id;

  WorkoutSetState({
    required int setNumber,
    double kg = 0.0,
    int reps = 8,
    bool isCompleted = false,
    int? id,
  }) : setNumber = setNumber.obs,
       kg = kg.obs,
       reps = reps.obs,
       isCompleted = isCompleted.obs,
       id = RxnInt(id);

  // Backward compatibility getters
  RxInt get kgInt => (kg.value.round()).obs;
}

class ActiveExerciseState {
  final int id;
  final int exerciseId;
  final String title;
  final String logType; // 'strength', 'cardio', 'duration', 'bodyweight'
  final String categoryName;
  final List<String> muscles;
  final RxBool isDone;
  final TextEditingController noteController;
  final int? targetSetCount;
  final int? targetReps;

  // For strength & bodyweight
  final RxList<WorkoutSetState> sets;
  final RxList<int> savingSetIndexes;

  // For cardio
  final TextEditingController timeController;
  final TextEditingController distanceController;
  final TextEditingController speedController;
  final RxInt inclineValue;
  final RxBool isCardioSaving;

  // For duration (timed hold / stopwatch)
  final int targetDurationSeconds;
  final RxInt durationSeconds;
  final RxBool isTimerRunning;
  Timer? durationTimer;

  ActiveExerciseState({
    required this.id,
    required this.exerciseId,
    required this.title,
    required this.logType,
    this.categoryName = '',
    this.muscles = const [],
    bool isDone = false,
    String note = '',
    List<WorkoutSetState>? sets,
    this.targetSetCount,
    this.targetReps,
    int cardioDurationSeconds = 0,
    double cardioDistanceKm = 0.0,
    double cardioSpeedKmh = 0.0,
    double cardioInclinePercent = 0.0,
    int targetDurationSeconds = 45,
    int? initialDurationSeconds,
  }) : isDone = isDone.obs,
       noteController = TextEditingController(text: note),
       sets = (sets ?? <WorkoutSetState>[]).obs,
       savingSetIndexes = <int>[].obs,
       timeController = TextEditingController(
         text: cardioDurationSeconds > 0
             ? '${(cardioDurationSeconds / 60).round()} min'
             : '',
       ),
       distanceController = TextEditingController(
         text: cardioDistanceKm > 0
             ? (cardioDistanceKm % 1 == 0
                   ? '${cardioDistanceKm.toInt()} km'
                   : '$cardioDistanceKm km')
             : '',
       ),
       speedController = TextEditingController(
         text: cardioSpeedKmh > 0
             ? (cardioSpeedKmh % 1 == 0
                   ? '${cardioSpeedKmh.toInt()} km/h'
                   : '$cardioSpeedKmh km/h')
             : '',
       ),
       inclineValue = cardioInclinePercent.round().obs,
       isCardioSaving = false.obs,
       targetDurationSeconds = targetDurationSeconds > 0
           ? targetDurationSeconds
           : 45,
       durationSeconds =
           (initialDurationSeconds ??
                   (targetDurationSeconds > 0 ? targetDurationSeconds : 45))
               .obs,
       isTimerRunning = false.obs;

  void dispose() {
    durationTimer?.cancel();
    noteController.dispose();
    timeController.dispose();
    distanceController.dispose();
    speedController.dispose();
  }
}

class LoggingController extends GetxController with WidgetsBindingObserver {
  LoggingController({
    LogginApiService? apiService,
    WorkoutLoggingPresetStore? presetStore,
  }) : _apiService = apiService ?? LogginApiService(),
       _presetStore = presetStore ?? WorkoutLoggingPresetStore.shared;

  final LogginApiService _apiService;
  final WorkoutLoggingPresetStore _presetStore;

  // ── Observables ────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasActiveSession = false.obs;
  final RxString emptyMessage = 'Add any workout to show your log'.obs;
  final RxString sessionTitle = 'Logging'.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxnInt activeSessionId = RxnInt();
  final RxList<ActiveExerciseState> exercises = <ActiveExerciseState>[].obs;

  Timer? _timer;
  bool _isLoadingSession = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadActiveSession();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    for (final ex in exercises) {
      ex.dispose();
    }
    super.onClose();
  }

  // ── Timer Methods ───────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  String get formattedTime {
    final total = elapsedSeconds.value;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── Load Active Session ────────────────────────────────────────────────
  Future<void> loadActiveSession({bool showLoading = true}) async {
    if (_isLoadingSession) return;
    _isLoadingSession = true;

    if (showLoading) {
      isLoading.value = true;
    }

    try {
      debugPrint('[LoggingController] Fetching active workout session...');
      final response = await _apiService.getActiveSession();

      if (response.hasActiveSession && response.exercises.isNotEmpty) {
        hasActiveSession.value = true;
        activeSessionId.value = response.sessionId ?? response.id;
        sessionTitle.value = response.title.isNotEmpty
            ? response.title
            : 'Logging';

        // Parse elapsed seconds or timer display
        if (response.elapsedSeconds > elapsedSeconds.value ||
            elapsedSeconds.value == 0) {
          if (response.elapsedSeconds > 0) {
            elapsedSeconds.value = response.elapsedSeconds;
          } else if (response.timerDisplay.isNotEmpty &&
              response.timerDisplay != '00:00') {
            elapsedSeconds.value = _parseTimerDisplay(response.timerDisplay);
          }
        }

        // Safely dispose old controllers on next frame to prevent
        // "A TextEditingController was used after being disposed"
        final oldExercises = List<ActiveExerciseState>.from(exercises);
        final mappedList = response.exercises.asMap().entries.map((entry) {
          return _mapExerciseItemToState(
            entry.value,
            existing: _findExistingExercise(
              entry.value,
              oldExercises,
              entry.key,
            ),
          );
        }).toList();

        exercises.assignAll(mappedList);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final ex in oldExercises) {
            ex.dispose();
          }
        });
        _startTimer();
      } else {
        // No active session in backend
        _handleEmptySession(response.message);
      }
    } on AuthException catch (e) {
      debugPrint(
        '[LoggingController] AuthException loading session: ${e.message}',
      );
      _handleEmptySession(e.message);
    } catch (e) {
      debugPrint('[LoggingController] Unexpected error loading session: $e');
      _handleEmptySession('Add any workout to show your log');
    } finally {
      isLoading.value = false;
      _isLoadingSession = false;
    }
  }

  void _handleEmptySession(String? message) {
    hasActiveSession.value = false;
    emptyMessage.value = (message != null && message.isNotEmpty)
        ? message
        : 'Add any workout to show your log';

    // Check if arguments were passed (e.g. from direct navigation or fallback)
    _applyArgumentsFallback();
  }

  void _applyArgumentsFallback() {
    final arguments = Get.arguments;
    if (arguments is! Map) return;

    final title = arguments['title']?.toString() ?? '';
    if (title.isNotEmpty) {
      final preset = WorkoutLoggingPreset.fromArguments(arguments);
      final exerciseId = preset.exerciseId;
      _presetStore.save(preset);
      hasActiveSession.value = true;
      final isCardio = preset.isCardio;
      final defaultSets = _buildTemplateSets(preset);

      final state = ActiveExerciseState(
        id: exerciseId,
        exerciseId: exerciseId,
        title: title,
        logType: isCardio ? 'cardio' : 'strength',
        sets: defaultSets,
        targetSetCount: preset.targetSetCount,
        targetReps: preset.targetReps,
      );

      exercises.assignAll([state]);
      _startTimer();
      _ensureActiveSessionOnServer(exerciseId);
    }
  }

  Future<void> _ensureActiveSessionOnServer(int exerciseId) async {
    try {
      debugPrint(
        '[LoggingController] Ensuring active session exists on server for exercise $exerciseId...',
      );
      final response = await _apiService.addExerciseToSession(
        exerciseId: exerciseId,
      );
      if (response.hasActiveSession) {
        activeSessionId.value = response.sessionId ?? response.id;
        debugPrint(
          '[LoggingController] Active session confirmed on server: id=${activeSessionId.value}',
        );
      }
    } catch (e) {
      debugPrint('[LoggingController] _ensureActiveSessionOnServer: $e');
    }
  }

  ActiveExerciseState _mapExerciseItemToState(
    ActiveExerciseItem item, {
    ActiveExerciseState? existing,
  }) {
    final preset = _presetStore.find(item.exerciseId);
    final isSetBased =
        item.logType == 'strength' || item.logType == 'bodyweight';
    final setsList = _resolveSets(
      item: item,
      preset: preset,
      existing: existing,
      isSetBased: isSetBased,
    );

    final cardio = item.cardioLogs.isNotEmpty ? item.cardioLogs.first : null;

    return ActiveExerciseState(
      id: item.id,
      exerciseId: item.exerciseId,
      title: item.title,
      logType: item.logType,
      categoryName: item.categoryName,
      muscles: item.muscles,
      isDone: item.isDone,
      note: item.note,
      sets: setsList,
      targetSetCount: preset?.targetSetCount,
      targetReps: preset?.targetReps,
      targetDurationSeconds: item.targetTimeSeconds > 0
          ? item.targetTimeSeconds
          : 45,
      initialDurationSeconds:
          existing?.durationSeconds.value ??
          (item.targetTimeSeconds > 0 ? item.targetTimeSeconds : 45),
      cardioDurationSeconds: cardio?.durationSeconds ?? 0,
      cardioDistanceKm: cardio?.distanceKm ?? 0.0,
      cardioSpeedKmh: cardio?.speedKmh ?? 0.0,
      cardioInclinePercent: cardio?.inclinePercent ?? 0.0,
    );
  }

  ActiveExerciseState? _findExistingExercise(
    ActiveExerciseItem item,
    List<ActiveExerciseState> previous,
    int index,
  ) {
    if (item.id > 0) {
      for (final exercise in previous) {
        if (exercise.id == item.id) return exercise;
      }
    }

    if (index < previous.length &&
        previous[index].exerciseId == item.exerciseId) {
      return previous[index];
    }

    for (final exercise in previous) {
      if (exercise.exerciseId == item.exerciseId) return exercise;
    }
    return null;
  }

  List<WorkoutSetState> _resolveSets({
    required ActiveExerciseItem item,
    required WorkoutLoggingPreset? preset,
    required ActiveExerciseState? existing,
    required bool isSetBased,
  }) {
    if (!isSetBased) return const [];

    final targetCount = preset?.targetSetCount;
    final targetReps = preset?.targetReps;
    List<WorkoutSetState> sets;

    if (existing != null && existing.sets.isNotEmpty && item.sets.isEmpty) {
      sets = existing.sets.map(_copySet).toList();
    } else if (item.sets.isNotEmpty) {
      sets = item.sets.map((serverSet) {
        return WorkoutSetState(
          setNumber: serverSet.setNumber,
          kg: serverSet.weightKg,
          reps: serverSet.reps,
          isCompleted: serverSet.isCompleted,
          id: serverSet.id,
        );
      }).toList();
      sets = _mergeExistingSetValues(sets, existing);
    } else {
      sets = _buildTemplateSets(
        preset,
        count: targetCount ?? 3,
        reps: targetReps ?? 8,
      );
    }

    if (targetCount != null && sets.length < targetCount) {
      final lastSet = sets.isNotEmpty ? sets.last : null;
      for (var index = sets.length; index < targetCount; index++) {
        sets.add(
          WorkoutSetState(
            setNumber: index + 1,
            kg: lastSet?.kg.value ?? preset?.initialKg ?? 0.0,
            reps: targetReps ?? lastSet?.reps.value ?? 8,
          ),
        );
      }
    }

    for (var index = 0; index < sets.length; index++) {
      sets[index].setNumber.value = index + 1;
    }
    return sets;
  }

  List<WorkoutSetState> _mergeExistingSetValues(
    List<WorkoutSetState> serverSets,
    ActiveExerciseState? existing,
  ) {
    if (existing == null || existing.sets.isEmpty) return serverSets;

    for (
      var index = 0;
      index < serverSets.length && index < existing.sets.length;
      index++
    ) {
      final current = existing.sets[index];
      final server = serverSets[index];
      server.kg.value = current.kg.value;
      server.reps.value = current.reps.value;
      server.isCompleted.value =
          current.isCompleted.value || server.isCompleted.value;
      server.id.value ??= current.id.value;
    }
    if (existing.sets.length > serverSets.length) {
      serverSets.addAll(existing.sets.skip(serverSets.length).map(_copySet));
    }
    return serverSets;
  }

  WorkoutSetState _copySet(WorkoutSetState source) {
    return WorkoutSetState(
      setNumber: source.setNumber.value,
      kg: source.kg.value,
      reps: source.reps.value,
      isCompleted: source.isCompleted.value,
      id: source.id.value,
    );
  }

  void startDuration(ActiveExerciseState exercise) {
    if (exercise.logType != 'duration' ||
        exercise.isDone.value ||
        exercise.isTimerRunning.value) {
      return;
    }

    if (exercise.durationSeconds.value <= 0) {
      resetDuration(exercise);
    }

    exercise.durationTimer?.cancel();
    exercise.isTimerRunning.value = true;
    exercise.durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (exercise.durationSeconds.value <= 1) {
        exercise.durationSeconds.value = 0;
        pauseDuration(exercise);
        unawaited(completeDuration(exercise));
        return;
      }
      exercise.durationSeconds.value--;
    });
  }

  void pauseDuration(ActiveExerciseState exercise) {
    exercise.durationTimer?.cancel();
    exercise.durationTimer = null;
    exercise.isTimerRunning.value = false;
  }

  void resetDuration(ActiveExerciseState exercise) {
    if (exercise.isDone.value) return;
    pauseDuration(exercise);
    exercise.durationSeconds.value = exercise.targetDurationSeconds;
  }

  Future<void> completeDuration(ActiveExerciseState exercise) async {
    if (exercise.isDone.value) return;
    pauseDuration(exercise);

    try {
      // The documented route expects the active-session exercise row id.
      final sessionExerciseId = exercise.id > 0
          ? exercise.id
          : exercise.exerciseId;
      final response = await _apiService.completeActiveExercise(
        sessionExerciseId,
      );
      exercise.isDone.value = true;
      AppLoadingService.showSuccess(
        'Exercise Complete',
        '${exercise.title} completed.',
      );

      if (response.exercises.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isClosed) {
            unawaited(loadActiveSession(showLoading: false));
          }
        });
      }
    } on AuthException catch (e) {
      AppLoadingService.showError('Exercise Failed', e.message);
    } catch (_) {
      AppLoadingService.showError(
        'Exercise Failed',
        'Unable to complete this exercise. Please try again.',
      );
    }
  }

  List<WorkoutSetState> _buildTemplateSets(
    WorkoutLoggingPreset? preset, {
    int? count,
    int? reps,
  }) {
    final setCount = (count ?? preset?.targetSetCount ?? 3).clamp(1, 10);
    final initialReps = reps ?? preset?.targetReps ?? 8;
    final initialKg = preset?.initialKg ?? 0.0;

    return List.generate(
      setCount,
      (index) => WorkoutSetState(
        setNumber: index + 1,
        kg: initialKg,
        reps: initialReps,
        isCompleted: false,
      ),
    );
  }

  int _parseTimerDisplay(String timer) {
    if (timer.contains(':')) {
      final parts = timer.split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        return (m * 60) + s;
      } else if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        return (h * 3600) + (m * 60) + s;
      }
    }
    return 0;
  }

  // ── Strength / Bodyweight Set Operations ──────────────────────────────
  void incrementKg(ActiveExerciseState ex, int index) {
    if (_isSetLocked(ex, index)) return;
    ex.sets[index].kg.value += 1.0;
  }

  void decrementKg(ActiveExerciseState ex, int index) {
    if (_isSetLocked(ex, index)) return;
    if (ex.sets[index].kg.value > 0) {
      ex.sets[index].kg.value = (ex.sets[index].kg.value - 1.0).clamp(
        0.0,
        999.0,
      );
    }
  }

  void incrementReps(ActiveExerciseState ex, int index) {
    if (_isSetLocked(ex, index)) return;
    ex.sets[index].reps.value++;
  }

  void decrementReps(ActiveExerciseState ex, int index) {
    if (_isSetLocked(ex, index)) return;
    if (ex.sets[index].reps.value > 0) {
      ex.sets[index].reps.value--;
    }
  }

  bool _isSetLocked(ActiveExerciseState ex, int index) {
    return ex.savingSetIndexes.contains(index) ||
        ex.sets[index].isCompleted.value;
  }

  Future<void> toggleSetCompleted(ActiveExerciseState ex, int index) async {
    final set = ex.sets[index];
    if (set.isCompleted.value) {
      AppLoadingService.showInfo('Set Saved', 'This set is already logged.');
      return;
    }

    if (ex.savingSetIndexes.contains(index)) return;
    ex.savingSetIndexes.add(index);

    try {
      ActiveExerciseSet savedSet;
      try {
        savedSet = await _apiService.logStrengthSet(
          exerciseId: ex.exerciseId,
          setNumber: set.setNumber.value,
          weightKg: ex.logType == 'bodyweight' ? 0.0 : set.kg.value,
          reps: set.reps.value,
          isCompleted: true,
        );
      } on AuthException catch (e) {
        if (e.statusCode == 404 ||
            e.message.toLowerCase().contains('session not found')) {
          debugPrint(
            '[LoggingController] Session not found (404). Auto-starting session on server for exerciseId=${ex.exerciseId}...',
          );
          try {
            await _apiService.startWorkoutSession(workoutId: ex.exerciseId);
          } catch (_) {
            await _apiService.addExerciseToSession(exerciseId: ex.exerciseId);
          }
          savedSet = await _apiService.logStrengthSet(
            exerciseId: ex.exerciseId,
            setNumber: set.setNumber.value,
            weightKg: ex.logType == 'bodyweight' ? 0.0 : set.kg.value,
            reps: set.reps.value,
            isCompleted: true,
          );
        } else {
          rethrow;
        }
      }

      set.isCompleted.value = true;
      if (savedSet.id != null) set.id.value = savedSet.id;
      AppLoadingService.showSuccess(
        'Set Logged',
        'Set ${set.setNumber.value} completed!',
      );
    } on AuthException catch (e) {
      AppLoadingService.showError('Set Log Failed', e.message);
    } catch (_) {
      AppLoadingService.showError(
        'Set Log Failed',
        'Failed to log set. Please try again.',
      );
    } finally {
      ex.savingSetIndexes.remove(index);
    }
  }

  void addSet(ActiveExerciseState ex) {
    final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
    final nextNumber = ex.sets.length + 1;
    final newSet = WorkoutSetState(
      setNumber: nextNumber,
      kg: lastSet != null ? lastSet.kg.value : 0.0,
      reps: lastSet != null ? lastSet.reps.value : (ex.targetReps ?? 8),
      isCompleted: false,
    );
    ex.sets.add(newSet);
  }

  // ── Cardio Operations ─────────────────────────────────────────────────
  void incrementIncline(ActiveExerciseState ex) => ex.inclineValue.value++;
  void decrementIncline(ActiveExerciseState ex) {
    if (ex.inclineValue.value > 0) ex.inclineValue.value--;
  }

  Future<void> saveCardioMetrics(ActiveExerciseState ex) async {
    if (ex.isCardioSaving.value) return;
    ex.isCardioSaving.value = true;

    try {
      final durationSec = _parseCardioDurationSeconds(ex.timeController.text);
      final distanceKm = _parseNumeric(ex.distanceController.text);
      final speedKmh = _parseNumeric(ex.speedController.text);
      final inclinePct = ex.inclineValue.value.toDouble();

      try {
        await _apiService.logCardioSet(
          exerciseId: ex.exerciseId,
          durationSeconds: durationSec,
          distanceKm: distanceKm,
          speedKmh: speedKmh,
          inclinePercent: inclinePct,
        );
      } on AuthException catch (e) {
        if (e.statusCode == 404 ||
            e.message.toLowerCase().contains('session not found')) {
          debugPrint(
            '[LoggingController] Session not found (404). Auto-starting session for cardio ${ex.exerciseId}...',
          );
          try {
            await _apiService.startWorkoutSession(workoutId: ex.exerciseId);
          } catch (_) {
            await _apiService.addExerciseToSession(exerciseId: ex.exerciseId);
          }
          await _apiService.logCardioSet(
            exerciseId: ex.exerciseId,
            durationSeconds: durationSec,
            distanceKm: distanceKm,
            speedKmh: speedKmh,
            inclinePercent: inclinePct,
          );
        } else {
          rethrow;
        }
      }

      AppLoadingService.showSuccess(
        'Cardio Logged',
        'Cardio metrics saved for ${ex.title}',
      );
    } on AuthException catch (e) {
      AppLoadingService.showError('Cardio Log Failed', e.message);
    } catch (_) {
      AppLoadingService.showError(
        'Cardio Log Failed',
        'Failed to save cardio metrics.',
      );
    } finally {
      ex.isCardioSaving.value = false;
    }
  }

  int _parseCardioDurationSeconds(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return elapsedSeconds.value.clamp(60, 86400);

    if (trimmed.contains(':')) {
      final parts = trimmed
          .split(':')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      if (parts.length == 2) {
        return (parts[0] * 60) + parts[1];
      } else if (parts.length == 3) {
        return (parts[0] * 3600) + (parts[1] * 60) + parts[2];
      }
    }

    final num = _parseNumeric(trimmed);
    return (num * 60).round().clamp(60, 86400);
  }

  double _parseNumeric(String text) {
    final normalized = text.replaceAll(',', '.');
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
    if (match == null) return 0.0;
    return double.tryParse(match.group(0)!) ?? 0.0;
  }

  // ── Note Operations ───────────────────────────────────────────────────
  Future<void> saveExerciseNote(ActiveExerciseState ex) async {
    final note = ex.noteController.text.trim();
    if (note.isEmpty) return;

    await _apiService.updateExerciseNote(
      exerciseId: ex.exerciseId > 0 ? ex.exerciseId : ex.id,
      note: note,
    );
  }

  // ── Finish Whole Workout Session ──────────────────────────────────────
  Future<void> onFinishWorkout() async {
    if (isSaving.value) return;

    // Check if there are unchecked sets in strength/bodyweight exercises
    final hasUnchecked = exercises.any((ex) {
      if (ex.logType == 'strength' || ex.logType == 'bodyweight') {
        return ex.sets.any((s) => !s.isCompleted.value);
      }
      return false;
    });

    if (hasUnchecked) {
      final confirm = await _showIncompleteSetsDialog();
      if (!confirm) return;
    }

    isSaving.value = true;
    _timer?.cancel();

    try {
      // 1. Save notes and cardio for exercises that have input
      for (final ex in exercises) {
        final note = ex.noteController.text.trim();
        if (note.isNotEmpty) {
          await _apiService.updateExerciseNote(
            exerciseId: ex.exerciseId,
            note: note,
          );
        }

        if (ex.logType == 'cardio' && _hasCardioInput(ex)) {
          await _apiService.logCardioSet(
            exerciseId: ex.exerciseId,
            durationSeconds: _parseCardioDurationSeconds(
              ex.timeController.text,
            ),
            distanceKm: _parseNumeric(ex.distanceController.text),
            speedKmh: _parseNumeric(ex.speedController.text),
            inclinePercent: ex.inclineValue.value.toDouble(),
          );
        }
      }

      // 2. Call finish workout session endpoint
      await _apiService.finishActiveSession();

      hasActiveSession.value = false;
      exercises.clear();
      _presetStore.clearAll();

      AppLoadingService.showSuccess(
        'Workout Complete!',
        'Great job on your workout session!',
      );

      Get.offAllNamed(AppRoute.getBottomNavigationScreen());
    } on AuthException catch (e) {
      AppLoadingService.showError('Session Failed', e.message);
      _startTimer();
    } catch (_) {
      AppLoadingService.showError(
        'Session Failed',
        'Something went wrong. Please try again.',
      );
      _startTimer();
    } finally {
      isSaving.value = false;
    }
  }

  bool _hasCardioInput(ActiveExerciseState ex) {
    return ex.timeController.text.trim().isNotEmpty ||
        ex.distanceController.text.trim().isNotEmpty ||
        ex.speedController.text.trim().isNotEmpty ||
        ex.inclineValue.value > 0;
  }

  Future<bool> _showIncompleteSetsDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Incomplete sets'),
        content: const Text(
          'Some sets are still unchecked. Do you want to finish the workout anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Finish Anyway'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  // ── Backward Compatibility API ─────────────────────────────────────────
  RxString get exerciseName =>
      (exercises.isNotEmpty ? exercises.first.title : 'Workout').obs;
  RxString get workoutTags =>
      (exercises.isNotEmpty ? exercises.first.muscles.join(' • ') : '').obs;
  TextEditingController get noteController => exercises.isNotEmpty
      ? exercises.first.noteController
      : TextEditingController();
  TextEditingController get timeController => exercises.isNotEmpty
      ? exercises.first.timeController
      : TextEditingController();
  TextEditingController get distanceController => exercises.isNotEmpty
      ? exercises.first.distanceController
      : TextEditingController();
  TextEditingController get speedController => exercises.isNotEmpty
      ? exercises.first.speedController
      : TextEditingController();
  RxInt get inclineValue =>
      exercises.isNotEmpty ? exercises.first.inclineValue : 0.obs;
  RxBool get isCardioWorkout =>
      (exercises.isNotEmpty && exercises.first.logType == 'cardio').obs;
}
