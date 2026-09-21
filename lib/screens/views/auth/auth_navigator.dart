import 'package:get/get.dart';
import 'package:gozy/screens/views/auth/forgetpassword/forgetpassword.dart';
import 'package:gozy/screens/views/static_page/static_page.dart';

enum AuthScreen {
  forgetPassword,
  staticPageContent,
}

class AuthNavigator {
  void navigateScreen(AuthScreen screen, String param) {
    switch (screen) {
      case AuthScreen.forgetPassword:
        Get.to(() => ForgetPassword(), routeName: "/ForgetPassword");
      case AuthScreen.staticPageContent:
        Get.to(() => StaticContentPage(), arguments: param);
    }
  }
}