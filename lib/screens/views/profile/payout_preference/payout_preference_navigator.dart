import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_account_details/payout_account_details.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_address_details/payout_address_details.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_country_search/payout_country_search.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_payment_choose/payout_payment_choose.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_paypal_details/payout_paypal_details.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_preference_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';

import 'payout_web_view/payout_web_view.dart';

enum PayoutPreferenceScreen {
  payoutCountrySearch,
  payoutAddressDetails,
  payoutPaymentChoose,
  payoutPaypalDetails,
  payoutAccountDetails,
  payoutWebView,
  payoutPreference
}

class PayoutPreferenceNavigator extends PayoutPreferenceController {
  void navigateScreen(PayoutPreferenceScreen screen, [Map? param]) {
    switch (screen) {
      case PayoutPreferenceScreen.payoutCountrySearch:
        FocusManager.instance.primaryFocus!.unfocus();
        showCustomBottomSheet(contentWidget: PayoutCountrySearch());
      case PayoutPreferenceScreen.payoutAddressDetails:
        Get.to(() => PayoutAddressDetails(), arguments: param);
      case PayoutPreferenceScreen.payoutPaymentChoose:
        Get.to(() => PayoutPaymentChoose(), arguments: param);
      case PayoutPreferenceScreen.payoutPaypalDetails:
        Get.to(() => PayoutPaypalDetails(), arguments: param);
      case PayoutPreferenceScreen.payoutAccountDetails:
        Get.to(() => PayoutAccountDetails(), arguments: param);
      case PayoutPreferenceScreen.payoutWebView:
        Get.to(PayoutWebView(), arguments: param, transition: Transition.leftToRight);
      case PayoutPreferenceScreen.payoutPreference:
        Get.until((route) => route.settings.name == '/payoutPreference');
    }
  }
}