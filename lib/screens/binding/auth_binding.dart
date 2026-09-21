import 'package:get/get.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/screens/views/auth/auth_navigator.dart';
import 'package:gozy/screens/views/auth/forgetpassword/forgetpassword_controller.dart';
import 'package:gozy/screens/views/auth/login/login_controller.dart';
import 'package:gozy/screens/views/auth/resetPassword/resetpassword_controller.dart';
import 'package:gozy/screens/views/auth/signup/signup_controller.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';

class AuthBinding extends Bindings{
  AuthBinding._privateConstructor();
  static final AuthBinding _instance = AuthBinding._privateConstructor();
  factory AuthBinding() {
    return _instance;
  }
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<AuthNavigator>(() => AuthNavigator(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController(), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);
    Get.lazyPut<ForgetPasswordController>(() => ForgetPasswordController(), fenix: true);
  }
  void deleteGetXController(){
    WishlistModifyController wishlistModifyController = Get.find();
    wishlistModifyController.dispose();
    Get.delete<AuthController>();
    Get.delete<LoginController>();
    Get.delete<ResetPasswordController>();
    Get.delete<SignupController>();
    Get.delete<ForgetPasswordController>();
    Get.delete<WishlistModifyController>();
  }
}