import 'package:get/get.dart';
import 'package:hawiisaac/features/profile/controller/user_subscription_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put(UserSubscriptionController(), permanent: true);
  }
}
