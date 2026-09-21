import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.data.gql.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';




class ForgetPasswordController extends AuthController {

  CustomTextEditingController emailController = CustomTextEditingController();

  void validateCredentials(BuildContext context) {
    Map<String,bool> results =  {
      error_msg_valid.trParams({'field':error_email_address.tr.toLowerCase()}) : !(isValidEmail(emailController.text)),
    };
    bool validate = results.isValidate(controller: this);
   if(validate) {
    checkNetwork(checkForgetPassword);
   }
  }

  void checkForgetPassword() {
    final params = GForgotPasswordReq((b) => b
    ..vars.email = emailController.Ttext
      ..context = b.context?.updateEntry<HttpLinkHeaders>(
            (headers) => const HttpLinkHeaders(
          headers: <String, String>{},
        ),
      )
      ..vars.build());
    FerryLoggerClient.makeRequest(params,this,checkForgetPassword)?.then((res) async {
      GForgotPasswordData forgetpassdata = res.data as GForgotPasswordData;
     isLoading.value = false;
     Get.back();
     Future.delayed(Duration(seconds: 1), () {
       showSnackBar('${success_msg_forget_password.tr} ${emailController.Ttext}');
     });
    });
  }
}