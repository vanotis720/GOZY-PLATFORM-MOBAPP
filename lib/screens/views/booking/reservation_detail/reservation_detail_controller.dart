import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/__generated__/reservation_fragment.data.gql.dart';
import 'package:gozy/graphql/__generated__/reservation_fragment.req.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/booking/booking_navigator.dart';

class ReservationDetailController extends BaseController {
  BookingNavigator bookingnavigator = Get.find();

  dynamic itemInfo;
  GreservationFragmentData? reservationResult;
  int reservationId = 0;

  (GreservationFragmentData?, GreservationFragmentReq) getReservationInfo(
      {required int reservationId}) {
    GreservationFragmentReq fragmentReq =
        GreservationFragmentReq((b) => b..idFields = {'id': reservationId});
    return (
      FerryLoggerClient.client?.cache.readFragment(fragmentReq),
      fragmentReq
    );
  }

  void getReservation() {
    final params = GgetReservationReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.convertCurrency = appPreference.preferredCurrency
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getReservation,
            isViewLoader: true)
        ?.then((res) {
      isLoading.value = false;
      reservationResult =
          getReservationInfo(reservationId: reservationId).$1;
      update();
    });
  }
}