import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/binding/booking_binding.dart';
import 'package:gozy/screens/views/booking/confirm_pay/confirm_pay_page.dart';
import 'package:gozy/screens/views/booking/reservation_detail/reservation_detail.dart';
import 'package:gozy/screens/views/guest/my_trips/claim_damage.dart';
import 'package:gozy/screens/views/guest/my_trips/claim_details.dart';
import 'package:gozy/screens/views/guest/view_message/view_message.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail_controller.dart';



enum MyTripListScreen {
  propertyDetail,
  reservationDetail,
  confirmAndPay,
  viewMessage,
  claimDamage,
  claimDetails
}

class MyTripListNavigator {
  void navigateScreen(MyTripListScreen screen, {dynamic param}) {
    switch (screen) {

      case MyTripListScreen.propertyDetail:
        Get.to(() => HomeItemDetailView(), arguments: param,);
        break;
      case MyTripListScreen.reservationDetail:
        Get.to(() => const ReservationDetail(),arguments:param,binding: BookingBinding());
        break;
      case MyTripListScreen.confirmAndPay:
        final HomeItemDetailController homeItemDetailController = _resolveHomeItemDetailController(param);
        Get.to(
          () => ConfirmAndPayPage(controller: homeItemDetailController),
          binding: BookingBinding(),
          arguments: param,
        );
        break;
      case MyTripListScreen.viewMessage:
        Get.to(() =>  ViewMessagePage(), binding: BookingBinding(), arguments: param,)?.then((value) {
          WidgetsFlutterBinding.ensureInitialized().performReassemble();
        });
        break;
      case MyTripListScreen.claimDamage:
        Get.to(() => ClaimDamage(), binding: BookingBinding(), arguments: param,);
        break;
      case MyTripListScreen.claimDetails:
        Get.to(() => ClaimDetails(), transition: Transition.downToUp, arguments: param);
        break;
      }
  }

  HomeItemDetailController _resolveHomeItemDetailController(dynamic param) {
    if (param is Map && param['homeItemDetailController'] is HomeItemDetailController) {
      return param['homeItemDetailController'] as HomeItemDetailController;
    }
    if (Get.isRegistered<HomeItemDetailController>()) {
      return Get.find<HomeItemDetailController>();
    }
    Get.lazyPut<HomeItemDetailController>(() => HomeItemDetailController(), fenix: true);
    return Get.find<HomeItemDetailController>();
  }

}