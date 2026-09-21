import 'package:get/get.dart';
import 'package:gozy/screens/views/booking/about_license_trip/about_license_controller.dart';
import 'package:gozy/screens/views/booking/booking_navigator.dart';
import 'package:gozy/screens/views/booking/confirm_pay/confirm_pay_page_controller.dart';
import 'package:gozy/screens/views/booking/generate_with_ai/generate_with_ai_controller.dart';
import 'package:gozy/screens/views/booking/pay_from_webpage/pay_from_web_controller.dart';
import 'package:gozy/screens/views/booking/reservation_detail/reservation_detail_controller.dart';
import '../views/booking/payment_type/payment_type_controller.dart';



class BookingBinding extends Bindings{
  BookingBinding._privateConstructor();
  static final BookingBinding _instance = BookingBinding._privateConstructor();
  factory BookingBinding() {
    return _instance;
  }
  @override
  void dependencies() {
    Get.lazyPut<ConfirmAndPayPageController>(() => ConfirmAndPayPageController(), fenix: true);
    Get.lazyPut<PaymentTypeController>(() => PaymentTypeController(), fenix: true);
    Get.lazyPut<BookingNavigator>(() => BookingNavigator(), fenix: true);
    Get.lazyPut<ReservationDetailController>(() => ReservationDetailController(), fenix: true);
    Get.lazyPut<PayFromWebController>(() => PayFromWebController(), fenix: true);
    Get.lazyPut<AboutLicenseController>(() => AboutLicenseController(), fenix: true);
    Get.lazyPut<GenerateWithAIController>(() => GenerateWithAIController(), fenix: true);
  }
}