import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/shareFeedback/__generated__/sharefeedback.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class ShareFeedBackPageController extends BaseController {
  var shareFeedBackController = CustomTextEditingController();
  CustomFocusNode feedbackFocusNode = CustomFocusNode();

  bool validateCredentials({required String type}) {
    Map<String, bool> results = {
      please_enter_any.trParams(
              {"field": type == "feedback" ? feedback_label.tr.toLowerCase() : bug_label.tr.toLowerCase()}):
          shareFeedBackController.Ttext.toString().isEmpty,
    };
    bool validate = results.isValidate(controller: this, isShowOnToast: true);
    return validate;
  }

  sendFeedback(String bugType) {
    final params = GsendUserFeedbackReq((b) => b
      ..vars.type = bugType
      ..vars.message = shareFeedBackController.Ttext
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, sendFeedback, isViewLoader: true)?.then((res) {
      isLoading.value = false;
      showToast(label_feedback_toast
          .trParams({'field': bugType == "feedback" ? feedback_label.tr : bug_label.tr.toLowerCase()}));
      Get.back();
    });
  }
}