import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/addPhoneNumber/__generated__/add_phone_number.data.gql.dart';
import 'package:gozy/graphql/addPhoneNumber/__generated__/add_phone_number.req.gql.dart';
import 'package:gozy/graphql/verifyphoneNumber/__generated__/verify_phone_number.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/profile/edit_profile/edit_profile_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/bottom_sheet/add_phone_number/otp_screen_bottom_sheet.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../constant.dart';

class AddPhoneController extends BaseController {
  CustomTextEditingController phoneNumberController = CustomTextEditingController();
  CustomTextEditingController countrySearchController = CustomTextEditingController();
  CustomTextEditingController otpController = CustomTextEditingController();
  String? selectedCountryCode, countryName;
  String? initFlag;
  RxBool isUpdateSelectedItem = false.obs;
  EditProfileController editProfileController = Get.find();

  bool validateCredentials(String route) {
    Map<String, bool> results = {
      route == 'otp'
              ? error_msg_empty.trParams({'field': label_empty_otp.tr})
              : error_msg_empty.trParams({'field': label_phone_number.tr.toLowerCase()}):
          route == 'otp' ? otpController.Ttext.isEmpty : phoneNumberController.Ttext.isEmpty,
    };
    if (otpController.Ttext.toString().isNotEmpty) {
      results = {}..addAll(results);
    }
    bool validate = results.isValidate(controller: this, isShowOnToast: true);
    return validate;
  }

  void addPhoneNumber({bool isFromOtp = false}) {
    final params = GAddPhoneNumberReq((b) => b
      ..vars.countryCode = selectedCountryCode ?? defaultDialCode
      ..vars.phoneNumber = phoneNumberController.text
      ..vars.countryName = countryName
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, addPhoneNumber,
            isViewLoader: true, isBottomSheetOpen: true, isViewErrorMessage: false, isToGet400Message: true)
        ?.then((res) {
      GAddPhoneNumberData addPhoneNumberData = res.data as GAddPhoneNumberData;
      if (addPhoneNumberData.AddPhoneNumber!.status == 200) {
        if (addPhoneNumberData.AddPhoneNumber!.phoneNumberStatus!.contains("1")) {
          if(!isFromOtp) {
            OtpScreenBottomSheet(controller: this);
          }else{
            showToast(label_otp_content.trParams({
              'field': "$selectedCountryCode ${phoneNumberController.text}."
            }) ?? "");
          }
        } else {
          editProfileController.getProfile();
          onBack();
        }
      } else {
        showToast(addPhoneNumberData.AddPhoneNumber!.errorMessage ?? "");
      }
    });
  }

  void validateOTP() {
    final params = GVerifyPhoneNumberReq((b) => b
      ..vars.verificationCode = int.parse(otpController.Ttext.toString())
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, validateOTP, isViewLoader: true, isToGet400Message: true)
        ?.then((res) {
          if(res.data.VerifyPhoneNumber.status==400){
            showToast(error_msg_empty.trParams({'field': label_empty_valid_otp.tr}));
            return;
          }
      editProfileController.getProfile();
      Get.close(2);
    });
  }
}