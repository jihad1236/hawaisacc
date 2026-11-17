import 'package:flutter_test/flutter_test.dart';
import 'package:hawiisaac/features/loggin/controller/logging_controller.dart';
import 'package:hawiisaac/features/loggin/model/active_workout_session_models.dart';
import 'package:hawiisaac/features/loggin/model/workout_logging_preset.dart';
import 'package:hawiisaac/features/loggin/services/loggin_api_service.dart';

class _FakeLogginApiService extends LogginApiService {
  _FakeLogginApiService(this.response);

  ActiveWorkoutSessionResponse response;

  @override
  Future<ActiveWorkoutSessionResponse> getActiveSession() async => response;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workout target parser', () {
    test('uses the upper set bound and lower reps bound', () {
      expect(WorkoutTargetParser.parseSets('3-4'), 4);
      expect(WorkoutTargetParser.parseReps('8-10'), 8);
    });

    test('supports exact values and unicode dash ranges', () {
      expect(WorkoutTargetParser.parseSets('4'), 4);
      expect(WorkoutTargetParser.parseReps('12'), 12);
      expect(WorkoutTargetParser.parseSets('3–4 sets'), 4);
      expect(WorkoutTargetParser.parseReps('6—12 reps'), 6);
    });

    test('returns null for empty or malformed values', () {
      expect(WorkoutTargetParser.parseSets(null), isNull);
      expect(WorkoutTargetParser.parseReps('as many as possible'), isNull);
      expect(WorkoutTargetParser.parseSets('0'), isNull);
    });
  });

  group('LoggingController set template', () {
    late WorkoutLoggingPresetStore store;
    late _FakeLogginApiService api;
    late LoggingController controller;

    setUp(() {
      store = WorkoutLoggingPresetStore();
      store.save(
        WorkoutLoggingPreset.fromDetail(
          exerciseId: 42,
          title: 'Rear Pull Up',
          sets: '3-4',
          reps: '8-10',
          kg: '',
          tags: 'Lats',
          isCardio: false,
        ),
      );
      api = _FakeLogginApiService(_activeResponse());
      controller = LoggingController(apiService: api, presetStore: store);
    });

    tearDown(() {
      controller.onClose();
    });

    test(
      'creates the exact target count with the parsed initial reps',
      () async {
        await controller.loadActiveSession();

        final exercise = controller.exercises.single;
        expect(exercise.logType, 'strength');
        expect(exercise.sets, hasLength(4));
        expect(exercise.sets.map((set) => set.reps.value), everyElement(8));
      },
    );

    test('pads backend rows without overwriting completed data', () async {
      api.response = _activeResponse(
        sets: const [
          ActiveExerciseSet(
            id: 100,
            setNumber: 1,
            weightKg: 20,
            reps: 12,
            isCompleted: true,
          ),
          ActiveExerciseSet(
            id: 101,
            setNumber: 2,
            weightKg: 20,
            reps: 10,
            isCompleted: false,
          ),
          ActiveExerciseSet(
            id: 102,
            setNumber: 3,
            weightKg: 20,
            reps: 10,
            isCompleted: false,
          ),
        ],
      );

      await controller.loadActiveSession();

      final sets = controller.exercises.single.sets;
      expect(sets, hasLength(4));
      expect(sets.first.reps.value, 12);
      expect(sets.first.isCompleted.value, isTrue);
      expect(sets.last.reps.value, 8);
    });

    test(
      'preserves local set edits on a later active-session refresh',
      () async {
        await controller.loadActiveSession();
        controller.exercises.single.sets.first.reps.value = 17;

        await controller.loadActiveSession(showLoading: false);

        expect(controller.exercises.single.sets, hasLength(4));
        expect(controller.exercises.single.sets.first.reps.value, 17);
      },
    );
  });
}

ActiveWorkoutSessionResponse _activeResponse({
  List<ActiveExerciseSet> sets = const [],
}) {
  return ActiveWorkoutSessionResponse(
    id: 1,
    sessionId: 1,
    hasActiveSession: true,
    exercises: [
      ActiveExerciseItem(
        id: 7,
        exerciseId: 42,
        title: 'Rear Pull Up',
        logType: 'strength',
        sets: sets,
      ),
    ],
  );
}
