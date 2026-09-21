import 'package:get/get.dart';
import 'package:gozy/screens/views/owner/generate_with_ai_owner/generate_with_ai_listings_controller.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/screens/views/owner/step_two/step_two_controller.dart';

class PropertyStepsBinding extends Bindings{
  PropertyStepsBinding._privateConstructor();
  static final PropertyStepsBinding _instance = PropertyStepsBinding._privateConstructor();
  factory PropertyStepsBinding() {
    return _instance;
  }
  @override
  void dependencies() {
    Get.lazyPut<StepOneController>(() => StepOneController(), fenix: true);
    Get.lazyPut<StepTwoController>(() => StepTwoController(), fenix: true);
    Get.lazyPut<StepThreeController>(() => StepThreeController(), fenix: true);
    Get.lazyPut<GenerateWithAIListingsController>(() => GenerateWithAIListingsController(), fenix: true);

  }
}