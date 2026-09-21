import 'package:gozy/screens/views/base_controller.dart';

enum HomeItemDetailScreen {
  itemDetail,
  Calendar,
  ConfirmAndPay,
  PaymentType,
  ContactHost,
  uploadProfile,
  aboutLicencePage,
  aboutTrip,
}

class HomeItemDetailNavigator {
  void updateitemPhotos() {}

  void navigateScreen(HomeItemDetailScreen screen, dynamic param, {BaseController? baseController}) {}

  void navigateSigninScreen() {}
}