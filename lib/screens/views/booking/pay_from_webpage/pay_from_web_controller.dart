import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/booking/confirmPayPalExecute/__generated__/confirm_paypal_execute.data.gql.dart';
import 'package:gozy/graphql/booking/confirmPayPalExecute/__generated__/confirm_paypal_execute.req.gql.dart';
import 'package:gozy/screens/views/booking/payment_type/payment_type_controller.dart';

import 'package:gozy/constant.dart';
import '../../base_controller.dart';

class PayFromWebController extends PaymentTypeController {

  String? paypalPaymentId, payerid;
  var webviewprogress = ReactiveVariable("webviewprogress", 0);
  PaymentTypeController? paymentTypeController;

  void confirmPaypalPayment() {
    GconfirmPayPalExecuteReq confirmpaypalparams = GconfirmPayPalExecuteReq((b) {
      b
      ..vars.paymentId = paypalPaymentId
      ..vars.payerId = payerid;
      if (isPaymentFrom == "servicePlan") {
        b.vars.isServicePlan = true;
        b.vars.userType = paymentTypeController?.userType;
      }
    });
    FerryLoggerClient.makeRequest(confirmpaypalparams, paymentTypeController ?? this, confirmPaypalPayment,
        isToGet400Message: true, isViewErrorMessage: false, isAutoCloseLoader: false)
        ?.then((res) async {
      GconfirmPayPalExecuteData confirmReservationData = res.data as GconfirmPayPalExecuteData;

      int? purchaseId;
      if (isPaymentFrom == "servicePlan") {
        purchaseId = confirmReservationData.confirmPayPalExecute?.purchasePlanId ??
            (paymentTypeController ?? this).reservationId;
      } else {
        purchaseId = confirmReservationData.confirmPayPalExecute?.reservationId;
      }

      (paymentTypeController ?? this).navigateReservationDetail(purchaseId: purchaseId);
    });
  }
}