import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_text/custom_user_profile_info_text.dart';
import 'package:gozy/widgets/common/custom_text/custom_showmore_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/report_user_view.dart';

import '../../../graphql/__generated__/schema.ast.gql.dart' as AppLayout;

class HostReviewBottomSheet {
  GlobalKey globalKey = GlobalKey();
  final HostReviewsBottomSheetController _controller = Get.find();
  late int listId;

  Widget ProfileInfoWidget(
      {required String user,
      required String? profilepic,
      required String? username,
      required dynamic userItem,
      required int? profileId,
      required listid,
      required int? starRating,
      required int? reviewCount,
      Color? linkTextColor,
      bool isCancel = false}) {
    listId = listid;
    _controller.starRating = starRating;
    _controller.reviewCount = reviewCount;
    return CustomUserProfileInfoText(
        profileIconType: overALLAppLayoutModel?.profileIconType ?? '',
        userImage: profilepic ?? '',
        isCancel: isCancel,
        userName: user,
        linkText: username,
        userNameTextSize: AppDimen.textSize_18,
        userNameFontWeight: AppFont.medium,
        onLinkTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showHostInfo(
              hostItem: userItem,
              profileId: profileId,
              isHost: !(_controller.appPreference.isOwner!));
        },
        linkTextFontSize: AppDimen.textSize_12,
        linkTextColor: linkTextColor ?? appColors.secondaryColor);
  }

  void showHostInfo({dynamic hostItem, int? profileId, required bool isHost, Color? ownerNameColor, double? borderRadius,String? title}) {
    _controller.isLoading.value = true;
    _controller.userReviewListpage.value = 1;
    _controller.selectedProfileid = profileId;
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.checkNetwork(_controller.getUserReviews);
    print(
        "Selected Value:::${_controller.userReviewsInfo[_controller.selectedProfileid]}");
    showCustomBottomSheet(
        backButtonWidget: getBackIconWidget(
          backIcon: overALLAppLayoutModel!.backIcon,
          themeType: appLayoutMap[AppLayout.profile]?.themeType,
        ),
        contentWidget: GetBuilder<BottomSheetController>(
          builder: (newController) =>
              GetBuilder<HostReviewsBottomSheetController>(
            builder: (newController) => hostInfoItem(
                hostItem: hostItem,
                profileId: profileId,

                profileIconType: overALLAppLayoutModel?.profileIconType ?? '',
                controller: _controller,
                isHost: isHost,
                isBackarrow: true,
                ownerNameColor: ownerNameColor,
                borderRadius: borderRadius,
                isNotEmptyUserReviews: _controller
                            .userReviewsInfo[profileId] !=
                        null &&
                    _controller.userReviewsInfo[profileId]!
                        .isNotEmpty,
                userReviewList: _getUserReviewSection(profileId),
                title: title,
                reportUseronTap: () {
                  _reportAboutUser();
                }),
          ),
        ),
        titleFontSize: AppDimen.textSize_18,
        sheetCloseListener: () {
          FocusManager.instance.primaryFocus?.unfocus();
          debugPrint("_controller.profileIdList: ${_controller.profileIdList}");
          if (_controller.profileIdList.isNotEmpty) {
            _controller.profileIdList
                .removeAt(_controller.profileIdList.length - 1);
            if (_controller.profileIdList.isNotEmpty) {
              _controller.selectedProfileid = _controller.profileIdList.last;
            } else {
              _controller.selectedProfileid = null;
            }
          } else {
            _controller.userReviewsInfo.clear();
            _controller.userReviewPageMap.clear();
          }
        });
  }

  Widget _getUserReviewSection(int? profileId) {
      final reviewList = _controller.userReviewsInfo[profileId];
      final int reviewCount = (reviewList != null && reviewList.isNotEmpty)
          ? (_controller.userReviewsInfo[profileId!]![0].yourReviewsCount ?? 0)
          : 0;

      return [
        _getUserReviewList(profileId: profileId, isAddListener: true),
        if (reviewCount > 3)
          getShowMoreWidget(
                  onTap: () {
                    showCustomBottomSheet(
                      backButtonWidget: getBackIconWidget(
                        backIcon: overALLAppLayoutModel!.backIcon,
                        themeType: appLayoutMap[AppLayout.profile]?.themeType,
                      ),
                      titleWidget: GetBuilder<BottomSheetController>(
                        builder: (newController) => getRatingTextView(
                            icon: overALLAppLayoutModel?.ratingIcon,
                            dotSize: 0,
                            iconSize: 20,
                            textColor: appColors.black,
                            size: AppDimen.textSize_22,
                            rating: '',
                            reviewFontWeight: FontWeight.w500,
                            reviews: '$reviewCount ${label_review.trPlural(reviewPlural.tr, reviewCount)}'),
                      ),
                      contentWidget: _getUserReviewList(profileId: profileId, isVertical: true, isAddListener: true)
                          .toPad(horizontal: AppDimen.startMargin, top: 12),
                    );
                  },
                  showAllText: '${"label_read_all".tr} $reviewCount ${label_review.trPlural(reviewPlural.tr, reviewCount)}')
              .toPad(top: 10)
      ].toColumn();
  }

  Widget _getUserReviewList({int? profileId, bool? isAddListener, bool isVertical = false}) {
    if (isVertical) {
      _controller.userreviewListScrollController = ScrollController();
    }
    return Obx(() {
      print("????>>>>>>> ${_controller.userReviewsInfo}");
      return toReviewList(
          reviewList: _controller.userReviewsInfo[profileId],
          reviewType: 'ListDetail',
          isDisableLoader: true,
          itemWidth: isVertical ? deviceWidth : deviceWidth - 100,
          scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
          reviewListScrollController: isVertical ? _controller.userreviewListScrollController : null,
          reviewsCount: _controller.userReviewsInfo.isNotEmpty &&
                  _controller.userReviewsInfo[profileId] != null &&
                _controller.userReviewsInfo[profileId]!.isNotEmpty
              ? (_controller.userReviewsInfo[profileId]?[0].yourReviewsCount)
              : null,
          isAddListener: isAddListener ?? false,
          onApiFunction: _controller.getUserReviews,
          controller: _controller,
          toShowPaginationLoader: false,
          currentPage: _controller.getUserReviewPage(profileId),
          itemBuilder: (context, index) {
            return commonReviewSectionItem(
                isVertical: isVertical,
                index: index,
                itemReviews:
                    _controller.userReviewsInfo[profileId],
                maxLines: 2,
                showMoreOnTap: isVertical
                    ? null
                    : () {
                        showCustomBottomSheet(
                          backButtonWidget: getBackIconWidget(
                            backIcon: overALLAppLayoutModel!.backIcon,
                            themeType:
                                appLayoutMap[AppLayout.profile]?.themeType,
                          ),
                          titleWidget: GetBuilder<BottomSheetController>(
                            builder: (newController) => getRatingTextView(
                                icon: overALLAppLayoutModel?.ratingIcon,
                                dotSize: 0,
                                iconSize: 20,
                                textColor: appColors.black,
                                size: AppDimen.textSize_22,
                                rating: '',
                                reviewFontWeight: FontWeight.w500,
                                reviews: _getUpdateTitleWidget(title: '1', profileId: profileId)),
                          ),
                          contentWidget: _getUserReviewList(
                                  profileId: profileId, isVertical: true, isAddListener: true)
                              .toPad(horizontal: AppDimen.startMargin, top: 12),
                        );
                      },
                onSelectedHost: (dynamic hostItem) {
                  if (hostItem?.toJson()['authorData'] != null) {
                    showHostInfo(
                        hostItem: hostItem,
                        profileId: hostItem?.authorData?.profileId,
                        isHost: false);
                  }
                }).toPad(bottom: isVertical ? 15 : 0, end: !isVertical ? 10 : 0);
          },
          onSelectedHost: (dynamic hostItem) {
            if (hostItem?.toJson()['authorData'] != null) {
              showHostInfo(
                  hostItem: hostItem,
                  profileId: hostItem?.authorData?.profileId,
                  isHost: false);
            }
          }).toResizeWidget(height: isVertical ? null : 167);
    });
  }

  String _getUpdateTitleWidget({required String title, int? profileId}) {
    if (title == '1') {
      dynamic reviewcount = _controller
          .userReviewsInfo[profileId]?[0].yourReviewsCount;
      if (reviewcount != null) {
        title =
            '$reviewcount ${label_review.trPlural(reviewPlural.tr, reviewcount)}';
      }
    } else {
      title = _controller.getRating();
    }
    return title;
  }
  Widget getShowMoreWidget({GestureTapCallback? onTap, String? showAllText}) {
    return CustomShowMoreText(
      text: showAllText ?? label_readmore.tr,
      fontWeight: AppFont.regular,
      size: AppDimen.textSize_16,
      color: appColors.secondaryColor,
      isReverseRotation: true,
      showMoreIcon: overALLAppLayoutModel?.backIcon,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }

  void _reportAboutUser() {
    _controller.selectedReportReason.value = -1;
    // if(_controller.reportReasonList.isEmpty) {
      _controller.isLoading.value = true;
      _controller.checkNetwork(_controller.getReportTypes);
    // }
    showCustomBottomSheet(
      backButtonWidget: getBackIconWidget(
        backIcon: overALLAppLayoutModel!.backIcon,
        themeType: overALLThemeType
      ),
      contentWidget: GetBuilder<HostReviewsBottomSheetController>(
        builder: (newController) =>
      ReportUserView(
          controller:_controller,
          selectedReportReason: _controller.selectedReportReason,
          ReportReasonList: _controller.reportReasonList,
          onTap: (){
            if(_controller.selectedReportReason.value != -1) {
              _controller.checkNetwork(_controller.reportUser);
            } else {
              _controller.showToast(error_msg_not_select_option.tr);
            }
          })),
      titleFontSize: AppDimen.textSize_18,
    );
  }
}