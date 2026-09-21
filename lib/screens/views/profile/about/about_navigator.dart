import 'package:get/get.dart';
import 'package:gozy/screens/binding/profile_binding.dart';
import 'package:gozy/screens/views/profile/about/profile_why_host/profile_why_host_page.dart';
import 'package:gozy/screens/views/static_page/static_page.dart';

enum AboutScreen {
  whyHost,
  staticPageContent,
}

class AboutNavigator {
  void navigateScreen(AboutScreen screen, [String? param]) {
    switch (screen) {
      case AboutScreen.whyHost:
        Get.to(() => ProfileWhyHostPage(), binding: ProfileBinding());
      case AboutScreen.staticPageContent:
        Get.to(() => StaticContentPage(), arguments: param);
    }
  }

}