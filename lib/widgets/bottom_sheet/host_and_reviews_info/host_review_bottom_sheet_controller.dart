import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import 'package:gozy/graphql/Reviews/__generated__/Reviews.data.gql.dart';
import 'package:gozy/graphql/Reviews/__generated__/Reviews.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';

class HostReviewsBottomSheetController extends BaseController {
  Map<int, List<dynamic>> userReviewsInfo = {};
  List<int> profileIdList = [];
  Map<int, RxInt> userReviewPageMap = {};
  RxInt selectedReportReason = (-1).obs;
  RxInt userReviewListpage = 1.obs;
  int? selectedProfileid;
  RxInt getUserReviewPage(int? profileId) {
    if (profileId == null) return 1.obs;
    return userReviewPageMap.putIfAbsent(profileId, () => 1.obs);
  }
  ScrollController userreviewListScrollController = ScrollController();
  List<dynamic> reportReasonList = [];
  int? starRating, reviewCount;

  void getUserReviews() {
    if (selectedProfileid == null) return;
    RxInt currentPage = getUserReviewPage(selectedProfileid);
    final getuserReviewsReq = GuserReviewsReq((b) => b
      ..vars.profileId = selectedProfileid
      ..vars.currentPage = currentPage.value
      ..vars.build());
    FerryLoggerClient.makeRequest(getuserReviewsReq, this, getUserReviews,
        isViewLoader: currentPage.value == 1,
        isViewErrorMessage: false)
        ?.then((res) {
      GuserReviewsData userReviewsDataInfo = res.data as GuserReviewsData;
      debugPrint("userReviewsDataInfo: $userReviewsDataInfo");
      List<dynamic> userReviewslist =
      userReviewsDataInfo.userReviews!.results!.toList();

      if (currentPage.value == 1) {
        userReviewsInfo[selectedProfileid!] = userReviewslist;
        if (!profileIdList.contains(selectedProfileid!)) {
          profileIdList.add(selectedProfileid!);
        }
      } else {
        userReviewsInfo[selectedProfileid!] =
        (userReviewsInfo[selectedProfileid!]! + userReviewslist);
      }
      currentPage.value++;
      isLoading.value = false;
      update();

    });
  }

  String getRating() {
    debugPrint("getRating: $starRating---$reviewCount");
    if (starRating == null || starRating == 0) {
      return '';
    }
    int rating = int.parse((starRating!/reviewCount!).toStringAsFixed(0));
    String titleText =
        '$rating / ${label_review.trPlural(reviewPlural.tr, reviewCount)} ($reviewCount)';
    debugPrint("getRating: titleText $titleText}");
    return titleText;
  }


  void getReportTypes() {
    final getAllReportTypesReq = GgetAllReportTypeReq((b) => b..vars.build());
    FerryLoggerClient.makeRequest(getAllReportTypesReq, this, getReportTypes)
        ?.then((res) {
      GgetAllReportTypeData createReportUserData = res.data as GgetAllReportTypeData;
      reportReasonList = createReportUserData.getAllReportType!.results!.toList();
      debugPrint("createReportUserData status: $reportReasonList");
      isLoading.value = false;
      update();
    });
  }

  void reportUser() {
    final getreportUserReq = GCreateReportUserReq((b) => b
      ..vars.profileId = selectedProfileid
      ..vars.reporterId = appPreference.userID
      ..vars.reportType = reportReasonList[selectedReportReason.value].reportType
      ..vars.build());
    FerryLoggerClient.makeRequest(getreportUserReq, this, reportUser)
        ?.then((res) {
      GCreateReportUserData createReportUserData = res.data as GCreateReportUserData;
      if(createReportUserData.createReportUser?.status == 200) {
        showToast(success_msg_user_reported.tr,3);
        selectedReportReason.value = -1;
        Get.back();
      }
      isLoading.value = false;

    });
  }

}