import 'package:get/get.dart';
import 'package:gozy/screens/views/base_controller.dart';
import '../../../../config/client.dart';
import '../../../../constant.dart';
import '../../../../graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import '../../../../graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import '../../../../resources/app_lang.dart';

class ReportBottomSheetController extends BaseController {

  var selectedReportingReason = (-1).obs;

  int? selectedProfileid;

  @override
  onInit(){
      checkNetwork(getReportTypes);
    super.onInit();
  }

  void getReportTypes() {
    final getAllReportTypesReq = GgetAllReportTypeReq((b) => b..vars.build());
    FerryLoggerClient.makeRequest(getAllReportTypesReq, this, getReportTypes)
        ?.then((res) {
      GgetAllReportTypeData createReportUserData = res.data as GgetAllReportTypeData;
      reportReasons = createReportUserData.getAllReportType!.results!.toList();
      isLoading.value = false;
      update();
    });
  }

  void reportUser() {
    final getreportUserReq = GCreateReportUserReq((b) => b
      ..vars.profileId = selectedProfileid
      ..vars.reporterId = appPreference.userID
      ..vars.reportType = reportReasons[selectedReportingReason.value].reportType
      ..vars.build());
    FerryLoggerClient.makeRequest(getreportUserReq, this, reportUser)
        ?.then((res) {
      GCreateReportUserData createReportUserData = res.data as GCreateReportUserData;
      if(createReportUserData.createReportUser?.status == 200) {
        selectedReportingReason.value = -1;
        showToast(success_msg_user_reported.tr,3);
        Get.back();
      }
      isLoading.value = false;

    });
  }
}