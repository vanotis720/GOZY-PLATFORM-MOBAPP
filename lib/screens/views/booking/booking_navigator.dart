import 'package:get/get.dart';
import 'package:gozy/screens/binding/main_binding.dart';
import 'package:gozy/screens/views/booking/pay_from_webpage/pay_from_web.dart';
import 'package:gozy/screens/views/booking/reservation_detail/reservation_detail.dart';
import 'package:gozy/screens/views/guest/view_message/view_message.dart';
import 'package:gozy/screens/views/home/home_page.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail.dart';

enum BookingScreen {

  reservationDetail,
  PayFromWeb,
  guestHome,
  itemDetail,
  viewMessage,
}

class BookingNavigator {
  void navigateScreen(BookingScreen screen, dynamic param) {
    switch (screen) {
      case BookingScreen.reservationDetail:
        Get.offAll(() => ReservationDetail(), arguments: param);
        break;
      case BookingScreen.PayFromWeb:
        Get.to(() => PayFromWeb(), arguments: param, routeName: '/PayFromWeb');
        break;
      case BookingScreen.itemDetail:
        Get.to(
          () => HomeItemDetailView(),
          arguments: param,
        );
        break;
      case BookingScreen.viewMessage:
        Get.to(
          () => ViewMessagePage(),
          arguments: param,
        );
        break;
      case BookingScreen.guestHome:
        Get.to(() => HomePage(),
            binding: MainBinding(isDisableClearController: true),
            arguments: {"isLogin": param},
            routeName: "/guestHomePage");
        break;
    }
  }
}