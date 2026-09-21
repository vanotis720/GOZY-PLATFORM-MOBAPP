import 'dart:convert';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:http/http.dart' as http;
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class GenerateWithAIController extends BaseController {

  String startingDate = "";
  String endingDate = "";
  String startingTime = "";
  String endingTime = "";
  String formatedStartDate = "";
  String formatedEndDate = "";
  String hostName = "";
  String type = "";
  RxString responseMessage = "".obs;

  CustomFocusNode controllerFocusNode = CustomFocusNode();

  CustomTextEditingController selectedReasonController = CustomTextEditingController();
  CustomTextEditingController contentController = CustomTextEditingController(text: "");

  Future<String> getAIMessage({String tripStart = "", String tripEnd = "",  String content = "", String reasonForRental = "", String hostName = "", String type = ""}) async {
    Map<String, String> headers = {
      "auth": appPreference.accessToken ?? "",
      "Content-Type":"application/json"
    };
    Map<String, dynamic> body = {
      "tripStart": tripStart,
      "tripEnd": tripEnd,
      "message": content,
      "reasonForTravel": reasonForRental,
      "hostName": hostName,
      "type": type,
      "platformSecretKey": securityKey
    };
    final encodedBody = jsonEncode(body);
    final response = await http.post(Uri.parse(getReservationMessage), headers: headers, body: encodedBody);
    Map<String,dynamic> result = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(result["status"] == 200 && result["response"] != null){
        responseMessage.value = result["response"]["message"];
        return "";
      }
      else{
        showSnackBar("${result["errorMessage"]["error"]["message"]}");
        return result["errorMessage"]["error"]["message"];
      }
    }
    else {
      return 'error_msg_oops_something_went_wrong_pls_try_again'.tr;
    }
  }

}