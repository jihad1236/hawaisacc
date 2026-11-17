import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/features/loggin/controller/ai_exercise_session_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiExerciseSessionController Tests', () {
    late AiExerciseSessionController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(AiExerciseSessionController());
    });

    tearDown(() {
      Get.reset();
    });

    test('initializes with static fallback exercises matching Figma 25:6067', () {
      expect(controller.hasExercises, isTrue);
      expect(controller.exercises.length, equals(5));
      expect(controller.currentExercise.name, equals('Squat Jump'));
      expect(controller.currentExercise.order, equals(1));
      expect(controller.currentIndex.value, equals(0));
      expect(controller.completedExercises, isEmpty);
      expect(controller.pendingExercises.length, equals(4));
      expect(controller.pendingExercises.first.name, equals('Push-Up'));
    });

    test('advancing to next exercise matches Figma 25:6217 state', () async {
      // Tap next
      await controller.nextExercise();

      // Squat Jump should now be in completed exercises
      expect(controller.completedExercises.length, equals(1));
      expect(controller.completedExercises.first.name, equals('Squat Jump'));
      expect(controller.completedExercises.first.order, equals(1));

      // Push-Up is now active
      expect(controller.currentIndex.value, equals(1));
      expect(controller.currentExercise.name, equals('Push-Up'));
      expect(controller.currentExercise.order, equals(2));

      // Pending exercises should now have 3 items (Mountain Climber, Glute Bridge, Plank Hold)
      expect(controller.pendingExercises.length, equals(3));
      expect(controller.pendingExercises[0].name, equals('Mountain Climber'));
      expect(controller.pendingExercises[1].name, equals('Glute Bridge'));
      expect(controller.pendingExercises[2].name, equals('Plank Hold'));
    });

    test('progressing through all exercises marks all completed', () async {
      for (var i = 0; i < 5; i++) {
        await controller.nextExercise();
      }

      expect(controller.completedExercises.length, equals(5));
      expect(controller.allExercisesCompleted, isTrue);
      expect(controller.pendingExercises, isEmpty);
    });
  });
}
