import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';

import '../../../../constant.dart';
import '../../../../generated/assets.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_font.dart';
import '../../../../widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet.dart';
import '../../../../widgets/common/custom_text/custom_title_text.dart';
import '../../../../widgets/custom_empty_view.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/shimmer.dart';
import '../../base_controller.dart';
import 'app_review_navigator.dart';
import 'app_reviews_controller.dart';

class AppReviews extends CustomStatefulWidget {
  const AppReviews({super.key});
  @override
  AppReviewsState createState() => AppReviewsState();
}

class AppReviewsState extends CustomStatefulWidgetState<AppReviews> with TickerProviderStateMixin {
  AppReviewsController controller = Get.find();
  static AppLayoutModel? profileLayout;
  bool isDottedView = false;
  bool isNotRespondedReplyBoxColored = false;
  Color? listingTileColor;
  Color? ownerNameColor;
  double? borderRadius;
  String replyIcon = "";
  String itineraryIcon = "";
  double replyIconSize = 16;

  @override
  void initState() {
    profileLayout = appLayoutMap[AppLayout.profile];
    Map<String, dynamic> arguments = Get.arguments ?? {};
    if (arguments['page'] != null) {
      if (arguments['page'] == ReviewAboutYouEnum.past) {
        ReviewAboutYouEnum reviewAboutYouEnum = arguments['page'];
        controller.selectedReviewAPIEnum.value = reviewAboutYouEnum.reviewAPIEnum;
        controller.selectedReviewAboutEnum = reviewAboutYouEnum;
      } else if (arguments['page'] == ReviewAboutYouEnum.upcoming) {
        ReviewAboutYouEnum reviewAboutYouEnum = arguments['page'];
        controller.selectedReviewAPIEnum.value = reviewAboutYouEnum.reviewAPIEnum;
        controller.selectedReviewAboutEnum = reviewAboutYouEnum;
      } else {
        ReviewByYouEnum reviewByYouEnum = arguments['page'];
        controller.selectedReviewAPIEnum.value = reviewByYouEnum.reviewAPIEnum;
        controller.selectedReviewByYouEnum = reviewByYouEnum;
      }
    }
    controller.tabController = TabController(
        length: controller.tabs.length,
        vsync: this,
        initialIndex: controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewAboutYouUpcoming ||
                controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewAboutYouPast
            ? 0
            : 1);
    controller.selectedReviewAPIEnum.listen((enums) {
      if ((controller.getReviewMapData(enums).reviewDataList?.isEmpty ?? true) &&
          !controller.isLoading.value) {
        isShowLoader = false;
        controller.isLoading.value = true;
        controller.checkNetwork(() {
          controller.getReviewMapData(enums).reviewDataCurrentPage.value = 1;
          if (enums == ReviewAPIEnum.reviewByYouUpcoming) {
            controller.getPendingUserReviews(reviewAPIEnum: enums);
          } else {
            controller.getUserReviews(reviewAPIEnum: enums);
          }
        });
      }
      controller.update();
    });
    controller.tabController.addListener(() {
      if (controller.previousIndex != controller.tabController.index) {
        controller.previousIndex = controller.tabController.index;
        if (controller.tabController.index == 1) {
          for (var element in ReviewByYouEnum.values) {
            if (controller.selectedReviewByYouEnum == element) {
              controller.selectedReviewAPIEnum.value = element.reviewAPIEnum;
            }
          }
        } else {
          for (var element in ReviewAboutYouEnum.values) {
            if (controller.selectedReviewAboutEnum == element) {
              controller.selectedReviewAPIEnum.value = element.reviewAPIEnum;
            }
          }
        }
      }
    });
    controller.selectedReviewAPIEnum.refresh();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();
    return CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
        ),
        body: showBodyContent(context));
  }

  Widget showBodyContent(BuildContext context) {
    return [
      CustomTitleText(
        text: reviewPlural.tr,
        fontWeight: AppFont.semiBold,
        size: AppDimen.textSize_22,
      ).toPad(start: AppDimen.startMargin),
      15.toHeight(),
      GetBuilder<AppReviewsController>(builder: (context) {
        return toTabBarView(
          tabs: controller.tabs,
          themeType: overALLAppLayoutModel?.themeType,
          tabBarWidgets: [
            _showReviewsListWidget(
                reviewAPIEnum: controller.selectedReviewAboutEnum.reviewAPIEnum,
                type: AppReviewEnum.aboutYou,
                appReviewModel: controller.getReviewMapData(controller.selectedReviewAboutEnum.reviewAPIEnum),
                index: 0,
                propertyList: controller
                    .getReviewMapData(controller.selectedReviewAboutEnum.reviewAPIEnum)
                    .reviewDataList,
                isFrom: true),
            _showReviewsListWidget(
                reviewAPIEnum: controller.selectedReviewByYouEnum.reviewAPIEnum,
                type: AppReviewEnum.byYou,
                appReviewModel: controller.getReviewMapData(controller.selectedReviewByYouEnum.reviewAPIEnum),
                index: 1,
                propertyList: controller
                    .getReviewMapData(controller.selectedReviewByYouEnum.reviewAPIEnum)
                    .reviewDataList,
                isFrom: false),
          ],
          tabController: controller.tabController,
        );
      }).toStretch()
    ].toColumn();
  }

  Obx _showReviewsListWidget(
      {required AppReviewEnum type,
      required AppReviewModel appReviewModel,
      required ReviewAPIEnum reviewAPIEnum,
      required int index,
      required propertyList,
      required bool isFrom}) {
    return Obx(() {
      return toReviewList(
        reviewListScrollController: appReviewModel.scrollController,
        reviewList: propertyList,
        reviewsCount: appReviewModel.reviewDataCount,
        onApiFunction: () {
          isShowLoader = false;
          if (reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming) {
            controller.getPendingUserReviews(reviewAPIEnum: reviewAPIEnum);
          } else {
            controller.getUserReviews(reviewAPIEnum: reviewAPIEnum);
          }
        },
        controller: controller,
        currentPage: appReviewModel.reviewDataCurrentPage,
        isDisableLoader: true,
        isEnableListener: true,
        isPaginationLoader: controller.isPaginationLoader,
        emptyWidget: _showEmptyWidget(type),
        isShowEmpty: () {
          return (propertyList?.isEmpty == true && !controller.isLoading.value);
        },
        listView: _showListView(
            propertyList: propertyList ?? [],
            scrollController: appReviewModel.scrollController,
            type: type,
            appReviewModel: appReviewModel,
            reviewAPIEnum: reviewAPIEnum),
      ).toShimmer(controller: controller);
    });
  }

  Widget _showEmptyWidget(AppReviewEnum type) {
    return [
      _showByYouButton(type),
      _showAboutYouButton(type),
      CustomEmptyView(
        emptyImageWidget: Assets.drawableReviewsEmpty.toSVG(),
        emptyTitle: type == AppReviewEnum.aboutYou
            ? label_there_are_no_reviews.tr
            : label_there_are_no_by_you_reviews.tr,
        emptyDescription:
            "${label_empty_reviews_end_reservation.tr} ${label_empty_review_will_be_visisble.tr}",
      ),
    ].toColumn();
  }

  Widget _showByYouButton(AppReviewEnum type) {
    if (type != AppReviewEnum.byYou) return const SizedBox.shrink();

    Widget row = [
      ...List.generate(
        ReviewByYouEnum.values.length,
        (index) => _customButton(
            isExpand: false,
            text: ReviewByYouEnum.values[index].title.tr,
            borderColor: appColors.black,
            borderRadius: overALLAppLayoutModel?.borderRadius,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            marginStart: index == 0 ? 0 : AppDimen.startMargin,
            btnBgColor: ReviewByYouEnum.values[index] == controller.selectedReviewByYouEnum
                ? appColors.black
                : appColors.white,
            btnTextColor: ReviewByYouEnum.values[index] == controller.selectedReviewByYouEnum
                ? appColors.white
                : appColors.black,
            onTap: () {
              controller.selectedReviewByYouEnum = ReviewByYouEnum.values[index];
              controller.selectedReviewAPIEnum.value = ReviewByYouEnum.values[index].reviewAPIEnum;
            }).toStretch(isExpanded: true),
      ),
    ]
        .toRow(
            mainAxisAlignment: (appLayoutMap[AppLayout.buttonType]?.themeType != 4)
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween)
        .toPad(top: 20, bottom: 15, horizontal: AppDimen.startMargin);

    return (appLayoutMap[AppLayout.buttonType]?.themeType == 4)
        ? row
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: IntrinsicWidth(child: row),
          );
  }

  Widget _showAboutYouButton(AppReviewEnum type) {
    if (type != AppReviewEnum.aboutYou) return const SizedBox.shrink();

    Widget row = [
      ...List.generate(
        ReviewAboutYouEnum.values.length,
        (index) => _customButton(
            textSize: AppDimen.textSize_14,
            isExpand: false,
            borderColor: appColors.black,
            text: ReviewAboutYouEnum.values[index].title.tr,
            borderRadius: overALLAppLayoutModel?.borderRadius,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            marginStart: index == 0 ? 0 : AppDimen.startMargin,
            btnBgColor: ReviewAboutYouEnum.values[index] == controller.selectedReviewAboutEnum
                ? appColors.black
                : appColors.white,
            btnTextColor: ReviewAboutYouEnum.values[index] == controller.selectedReviewAboutEnum
                ? appColors.white
                : appColors.black,
            onTap: () {
              controller.selectedReviewAboutEnum = ReviewAboutYouEnum.values[index];
              controller.selectedReviewAPIEnum.value = ReviewAboutYouEnum.values[index].reviewAPIEnum;
            }).toStretch(isExpanded: true),
      ),
    ]
        .toRow(
            mainAxisAlignment: (overALLThemeType != 4) ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween)
        .toPad(top: 20, bottom: 15, horizontal: AppDimen.startMargin);

    return (overALLThemeType == 4)
        ? row
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: IntrinsicWidth(child: row),
          );
  }

  Widget _showListView(
      {required List<dynamic> propertyList,
      required ScrollController scrollController,
      required AppReviewEnum type,
      required AppReviewModel appReviewModel,
      required ReviewAPIEnum reviewAPIEnum}) {
    int itemCount = propertyList.isNotEmpty
        ? propertyList.length
        : controller.isLoading.value
            ? 5
            : 0;
    bool isload = (controller.isLoading.value && (propertyList.isEmpty));
    bool isshimmerloading = isload;
    return [
      _showByYouButton(type),
      _showAboutYouButton(type),
      ShimmerLoading(
          widgetType: 'Reviews',
          isLoading: isshimmerloading,
          isDarkMode: controller.isDarkMode(),
          darkModeblend: BlendMode.dstIn,
          child: toListView(
              itemCount: itemCount,
              controller: scrollController,
              key: appReviewModel.pageStorageKey,
              physics: AlwaysScrollableScrollPhysics(),
              padding: pad(bottom: 30, top: 10, w: AppDimen.startMargin - 1),
              itemBuilder: (context, index) {
                var propertyList0;
                if (propertyList.isNotEmpty) {
                  propertyList0 = propertyList[index];
                  controller.setReviewViewData(propertyList0, reviewAPIEnum);
                }
                return ConditionalParentWidget(
                  condition: isDottedView,
                  parentBuilder: (child) {
                    return DottedBorderView(
                      borderRadius: overALLAppLayoutModel?.borderRadius,
                      dottedlineColor: appColors.colorCommonLinkColor,
                      child: child,
                    ).toPad(bottom: 18);
                  },
                  child: CustomBorderContainer(
                    color: controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewAboutYouPast
                        ? appColors.theme3ReviewListColor
                        : controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouUpcoming
                            ? appColors.theme3ReviewListColor
                            : listingTileColor,
                    borderRadius: overALLAppLayoutModel?.borderRadius,
                    borderColor: isDottedView ? Colors.transparent : appColors.customBorderColor,
                    margin: isDottedView ? null : pad(bottom: AppDimen.startMargin),
                    body: [
                      _reviewHeaderView(
                              controller.reviewViewData, isshimmerloading, propertyList0, reviewAPIEnum)
                          .toPad(top: 18, start: 18, end: 18),
                      reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming
                          ? controller.reviewViewData.title == null && !isshimmerloading
                              ? const SizedBox.shrink()
                              : _reviewPendingUserView(controller.reviewViewData, isshimmerloading)
                          : _reviewUserView(controller.reviewViewData, isshimmerloading, reviewAPIEnum),
                    ].toColumn(),
                  ),
                );
              })).toStretch(),
    ].toColumn();
  }

  Widget _reviewHeaderView(
      ReviewViewData reviewData, bool isshimmerloading, var propertyList, ReviewAPIEnum reviewAPIEnum) {
    return [
      toOnTap(
        onTap: () async {
          if (reviewData.isAdmin != true) {
            HostReviewBottomSheet().showHostInfo(
                isHost: false,
                profileId: controller
                    .getPropertyListType(propertyList, reviewAPIEnum)
                    .profileId,
                hostItem: controller
                    .getPropertyListType(propertyList, reviewAPIEnum),
                ownerNameColor: ownerNameColor,
                borderRadius: borderRadius);
          }
        },
        child: CustomProfileNetworkImage(
            profileImageType: 'circle',
            imageUrl: (reviewData.profilePicture ?? ''),
            all: 50,
            isShimmerView: isshimmerloading,
            placeholder: reviewData.isAdmin == true
                ? getAdminImage(adminimage: Assets.drawableReviewAdmin, size: 45, pad: 0.0)
                : null),
      ),
      10.toWidth(),
      (reviewData.isAdmin ?? false) || (reviewData.title == null) || isshimmerloading
          ? CustomText(
              text: isshimmerloading
                  ? 20.toGenerateEmptyString()
                  : reviewData.title == null && reviewData.isAdmin == false
                      ? label_listing_not_available.tr
                      : '${label_verifed_by.tr} $APP_NAME',
              isShimmerView: isshimmerloading,
            ).toStretch()
          : RichText(
              text: TextSpan(
                style: TextStyle(
                    fontWeight: AppFont.medium,
                    fontFamily: AppFont.font,
                    color: appColors.textColor,
                    fontSize: AppDimen.textSize_16),
                children: [
                  TextSpan(
                    text: reviewData.firstName,
                  ),
                  TextSpan(
                    text: reviewData.reviewTitle,
                  ),
                  TextSpan(
                    text: reviewData.title,
                    style: TextStyle(color: appColors.secondaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        controller.listId = reviewData.listId ?? 0;
                        controller.checkNetwork(controller.getHomeItemDetail);
                      },
                  ),
                ],
              ),
            ).toStretch(),
    ]
        .toRow(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center)
        .toPad(bottom: 10);
  }

  Widget _reviewUserView(ReviewViewData reviewData, bool isshimmerloading, ReviewAPIEnum reviewAPIEnum) {
    return [
      isshimmerloading
          ? CustomText(
              text: deviceWidth.toGenerateEmptyString(),
              fontWeight: FontWeight.normal,
              size: AppDimen.textSize_12,
              isShimmerView: isshimmerloading,
            ).toPad(bottom: 10, start: 18, end: 18)
          : ExpandableCollapseText(
              reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
                  ? reviewData.response?.reviewContent ?? ''
                  : reviewData.reviewContent??"",
            ).toPad(bottom: 12.0, start: 18, end: 18),
      [
        if (!isshimmerloading) ...[
          getRatingTextView(
            icon: overALLAppLayoutModel?.ratingIcon,
            rating: int.parse((reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
                    ? reviewData.response?.rating ?? 0
                    : reviewData.rating)
                .toStringAsFixed(0)),
            ratingColor: appColors.black,
            size: AppDimen.textSize_14,
            dotSize: 8,
            reviewFontWeight: AppFont.regular
          ),
        ],
        CustomText(
          text: isshimmerloading
              ? 40.toGenerateEmptyString()
              : getDateFormat(
                      dateFormat: commonDateFormat,
                      milliSec: reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
                          ? reviewData.response?.createdAt ?? '0'
                          : reviewData.createdAt)
                  .$1
                  .replaceAll(' ', ''),
          size: AppDimen.textSize_14,
          fontWeight: AppFont.regular,
          color: appColors.textColor,
          isShimmerView: isshimmerloading,
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(bottom: 12.0, start: 18, end: 18),
      if ((overALLThemeType != 4)&&
          (reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming ||
              reviewAPIEnum == ReviewAPIEnum.reviewByYouPast) &&
          reviewData.response != null &&
          !isshimmerloading) ...[
        5.toHeight(),
        appReviewDivider,
        18.toHeight(),
      ],
      ((reviewData.response != null &&
                  controller.selectedReviewAPIEnum.value != ReviewAPIEnum.reviewAboutYouPast &&
                  controller.selectedReviewAPIEnum.value != ReviewAPIEnum.reviewByYouPast) &&
              !isshimmerloading)
          ? _reviewResponseView(reviewData, reviewAPIEnum)
          : const SizedBox.shrink(),
      ((reviewData.response != null && controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast) &&
              !isshimmerloading)
          ? _reviewResponseView(reviewData, reviewAPIEnum)
          : const SizedBox.shrink(),
      (controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewAboutYouPast && !isshimmerloading)
          ? _reviewResponsePastView(reviewData)
          : const SizedBox.shrink()
    ].toColumn();
  }

  Widget _reviewResponsePastView(ReviewViewData reviewData) {
    return [
      ConditionalParentWidget(
        condition: isDottedView,
        parentBuilder: (child) => DottedBorderView(
          borderRadius: overALLAppLayoutModel?.borderRadius,
          dottedlineColor: appColors.colorCommonLinkColor,
          isOnlyTop: true,
          child: CustomBorderContainer(
            borderRadius: overALLAppLayoutModel?.borderRadius,
            color: appColors.theme4AppBarBg,
            borderColor: Colors.transparent,
            body: child,
          ),
        ).toPad(horizontal: 0, bottom: 0, top: 10),
        child: [
          ConditionalParentWidget(
            condition: !isDottedView && isNotRespondedReplyBoxColored,
            parentBuilder: (child) => CustomBorderContainer(
              borderRadiusGeometry: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
                bottomEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
              ),
              color: appColors.replyContainer.withAlpha(60),
              body: child,
            ),
            child: [
              isDottedView || isNotRespondedReplyBoxColored ? 0.toHeight() : appReviewDivider,
              18.toHeight(),
              toOnTap(
                onTap: () {
                  controller.checkNetwork(() {
                    controller.isPaginationLoader.value = false;
                    isShowLoader = true;
                    controller.checkListingAndReply(reviewData.listId ?? 0, reviewData.id ?? 0, (reservationItem) {
                      controller.appReviewsNavigator?.navigateScreen(AppReviewsScreen.writeReview,
                          {'itemInfo': reservationItem, 'page': 'appReview', 'isFrom': 'aboutYou'});
                      controller.isPaginationLoader.value = true;
                      isShowLoader = false;
                    });
                  });
                },
                child: ConditionalParentWidget(
                  condition: true,
                  parentBuilder: (child) => Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                  child: overALLThemeType == 1
                      ? _buildUnderlinedIconText(
                          iconPath: replyIcon,
                          text: label_review_reply.tr,
                          color: appColors.secondaryColor,
                          iconSize: replyIconSize,
                        )
                      : [
                          replyIcon
                              .toString()
                              .toSVG(colour: appColors.secondaryColor, size: replyIconSize)
                              .toPad(end: 5),
                          CustomText(
                            text: label_review_reply.tr,
                            size: AppDimen.textSize_16,
                            fontWeight: AppFont.medium,
                            maxLines: 3,
                            color: appColors.secondaryColor,
                          ).toStretch(isExpanded: false),
                        ].toRow(mainAxisSize: MainAxisSize.min),
                ),
              ),
              18.toHeight(),
            ].toColumn(),
          )
        ].toColumn(),
      )
    ].toColumn();
  }

  Widget _reviewResponseView(ReviewViewData reviewData, ReviewAPIEnum reviewAPIEnum) {
    bool isAdmin = (controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
        ? reviewData.response?.isAdmin
        : reviewData.isAdmin) ?? false;
    return [
      ConditionalParentWidget(
        condition: isDottedView,
        parentBuilder: (child) => DottedBorderView(
          borderRadius: overALLAppLayoutModel?.borderRadius,
          dottedlineColor: appColors.colorCommonLinkColor,
          isOnlyTop: true,
          child: CustomBorderContainer(
            borderRadius: overALLAppLayoutModel?.borderRadius,
            color: appColors.theme4AppBarBg,
            borderColor: Colors.transparent,
            body: child,
          ),
        ).toPad(horizontal: 0, bottom: 0, top: 10),
        child: [
          isDottedView ? 18.toHeight() : 0.toHeight(),
          [
            toOnTap(
              onTap: () async {
                if (isAdmin != true && reviewData.respondentData != null) {
                    HostReviewBottomSheet().showHostInfo(
                        isHost: false,
                        profileId: reviewData.respondentData?.profileId ?? 0,
                        hostItem: reviewData.respondentData,
                        ownerNameColor: ownerNameColor,
                        borderRadius: borderRadius);
                }
              },
              child: CustomProfileNetworkImage(
                  profileImageType: 'circle',
                  imageUrl: reviewData.respondentPicture,
                  all: 50,
                  placeholder:
                      isAdmin ? getAdminImage(adminimage: Assets.drawableReviewAdmin, size: 45, pad: 0.0) : null),
            ),
            10.toWidth(),
            [
              Container(
                height: 50,
                alignment: AlignmentDirectional.centerStart,
                child: RichText(
                  textDirection: controller.isRTL()
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  text: TextSpan(
                    style: TextStyle(
                        fontWeight: AppFont.medium,
                        fontFamily: AppFont.font,
                        color: appColors.textColor,
                        fontSize: AppDimen.textSize_16),
                    children: [
                      TextSpan(
                        text: controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
                            ? "${reviewData.respondentFirstName} "/*${reviewData.respondentFirstName.isNotEmpty ? ': ' : ''}*/
                            : "",
                      ),
                      TextSpan(
                        text: controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
                            ? "${label_review_response.tr}:"
                            : "${label_your.tr} ${label_review_response.tr}:",
                      ),
                    ],
                  ),
                ),
              ),
            ].toColumn().toStretch(isExpanded: false),
          ]
              .toRow(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start)
              .toPad(bottom: 10, start: 18, end: 18),
          ExpandableCollapseText(
            (controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
                    ? reviewData.response?.reviewContent
                    : reviewData.reviewContent) ??
                '',
            textAlign: TextAlign.start,
          ).toPad(bottom: 12.0, start: 18, end: 18),
          [
            getRatingTextView(
                icon: overALLAppLayoutModel?.ratingIcon,
                rating: int.parse((controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
                        ? reviewData.response?.rating ?? 0
                        : reviewData.rating)
                    .toStringAsFixed(0)),
                size: AppDimen.textSize_14,
                reviewFontWeight: AppFont.regular,
                dotSize: 8,
                ratingColor: appColors.black),
            CustomText(
              text: getDateFormat(
                      dateFormat: commonDateFormat,
                      milliSec: controller.selectedReviewAPIEnum.value == ReviewAPIEnum.reviewByYouPast
                          ? reviewData.response?.createdAt ?? '0'
                          : reviewData.createdAt)
                  .$1
                  .replaceAll(' ', ''),
              size: AppDimen.textSize_14,
              fontWeight: AppFont.regular,
              color: appColors.textColor,
            ),
          ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: 18, bottom: 12),
          isDottedView ? 6.toHeight() : 0.toHeight(),
        ].toColumn(),
      )
    ].toColumn();
  }

  Widget _reviewPendingUserView(ReviewViewData reviewData, bool isshimmerloading) {
    List pendingUserBtnList = [
      {
        "btnSvgImage": replyIcon,
        "btnTitle": label_write_a_review.tr,
        "onTap": () {
          controller.checkNetwork(() {
            controller.isPaginationLoader.value = false;
            isShowLoader = true;
            controller.getPendingUserReview(reviewData.id ?? 0, (reservationItem) {
              controller.appReviewsNavigator?.navigateScreen(AppReviewsScreen.writeReview,
                  {'itemInfo': reservationItem, 'page': 'appReview', 'isFrom': 'byYou'});
              controller.isPaginationLoader.value = true;
              isShowLoader = false;
            });
          });
        }
      },
      {
        "btnSvgImage": itineraryIcon,
        "btnTitle": label_view_itinerary.tr,
        "onTap": () {
          controller.checkNetwork(() {
            controller.isPaginationLoader.value = false;
            isShowLoader = true;
            controller.getReservation(reviewData.id ?? 0, (reservationItem) {
              controller.appReviewsNavigator?.navigateScreen(AppReviewsScreen.reservationDetail, {
                'itemInfo': reservationItem?.listData,
                'reservationId': reservationItem?.id,
                'page': 'appReview'
              });
              controller.isPaginationLoader.value = true;
              isShowLoader = false;
            });
          });
        }
      },
    ];
    return [
      ConditionalParentWidget(
        condition: isDottedView,
        parentBuilder: (child) => DottedBorderView(
          borderRadius: overALLAppLayoutModel?.borderRadius,
          dottedlineColor: appColors.colorCommonLinkColor,
          isOnlyTop: true,
          child: CustomBorderContainer(
            borderRadius: overALLAppLayoutModel?.borderRadius,
            color: appColors.theme4AppBarBg,
            borderColor: Colors.transparent,
            body: child,
          ),
        ).toPad(horizontal: 0, bottom: 0, top: 10),
        child: [
          ConditionalParentWidget(
            condition: !isDottedView &&
                (isDottedView || isNotRespondedReplyBoxColored),
            parentBuilder: (child) => CustomBorderContainer(
              borderRadiusGeometry: BorderRadiusDirectional.vertical(
                bottom:
                    Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
                top: Radius.circular(overALLThemeType == 3
                    ? 0
                    : overALLAppLayoutModel?.borderRadius ?? 0),
              ),
              color: isDottedView
                  ? appColors.theme4AppBarBg
                  : (overALLThemeType == 3
                      ? appColors.replyContainer.withAlpha(80)
                      : appColors.replyContainer),
              borderColor: Colors.transparent,
              body: child,
            ),
            child: [
              isDottedView || isNotRespondedReplyBoxColored ? 0.toHeight() : 8.toHeight(),
              isDottedView || isNotRespondedReplyBoxColored ? 0.toHeight() : appReviewDivider,
              18.toHeight(),
              [
                ...List.generate(pendingUserBtnList.length, (index) {
                  return toOnTap(
                    onTap: pendingUserBtnList[index]["onTap"],
                    child: Align(
                      alignment: index == 0 ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                      child: overALLThemeType == 1 && !isshimmerloading
                          ? _buildUnderlinedIconText(
                              iconPath: pendingUserBtnList[index]["btnSvgImage"].toString(),
                              text: '${pendingUserBtnList[index]["btnTitle"]}',
                              color: appColors.secondaryColor,
                              iconSize: replyIconSize,
                            )
                          : [
                              if (!isshimmerloading)
                                pendingUserBtnList[index]["btnSvgImage"]
                                    .toString()
                                    .toSVG(colour: appColors.secondaryColor, size: replyIconSize),
                              CustomText(
                                text: isshimmerloading
                                    ? 30.toGenerateEmptyString()
                                    : '${pendingUserBtnList[index]["btnTitle"]}',
                                size:  AppDimen.textSize_16 ,
                                maxLines: 3,
                                color: appColors.secondaryColor,
                                isShimmerView: isshimmerloading,
                                fontWeight:  AppFont.medium ,
                              ).toStretch(isExpanded: false),
                            ].toRow(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: index == 0 ? MainAxisAlignment.start : MainAxisAlignment.end),
                    ),
                  ).toResizeWidget(width: (deviceWidth / 2) - 36).toStretch();
                }),
              ].toRow(spacing: 12).toPad(bottom: 18, horizontal: 30)
            ].toColumn(mainAxisSize: MainAxisSize.min),
          )
        ].toColumn(),
      )
    ].toColumn(mainAxisSize: MainAxisSize.min);
  }

  Widget _customButton(
      {required String text,
      GestureTapCallback? onTap,
      bool isExpand = false,
      double? textSize,
      double? borderRadius,
      double? marginStart,
      int? maxLines,
      TextOverflow? overflow,
      Color? borderColor,
      required Color btnBgColor,
      required Color btnTextColor}) {
    return toOnTap(
        onTap: onTap,
        child: CustomBorderContainer(
          padding: pad(h: 8, w: 18),
          margin: pad(start: marginStart ?? AppDimen.startMargin),
          height: AppDimen.button_height,
          color: btnBgColor,
          borderWidth: 1,
          borderRadius: overALLAppLayoutModel?.borderRadius ?? 0,
          alignment: Alignment.center,
          borderColor: borderColor,
          body: CustomText(
            text: text,
            color: btnTextColor,
            textAlign: TextAlign.center,
            size: textSize,
            maxLines: maxLines,
            overflow: overflow,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget _buildUnderlinedIconText({
    required String iconPath,
    required String text,
    required Color color,
    required double iconSize,
    int maxLines = 3,
  }) {
    return Builder(
      builder: (context) {
        final style = TextStyle(
          fontSize: AppDimen.textSize_16,
          fontFamily: AppFont.font,
          fontWeight: AppFont.medium,
          color: color,
          height: 1.4,
        );

        return CustomPaint(
          painter: _TextUnderlinePainter(
            text: text,
            style: style,
            maxLines: maxLines,
            textDirection: Directionality.of(context),
            underlineColor: color,
            iconWidth: iconSize + 5, // size + padding
            iconHeight: iconSize,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: iconPath.toSVG(colour: color, size: iconSize).toPad(end: 5),
                ),
                TextSpan(text: text, style: style),
              ],
            ),
            maxLines: maxLines,
          ),
        );
      },
    );
  }

  void initThemeData() {
    listingTileColor = appColors.theme3ReviewListColor;
    borderRadius = overALLAppLayoutModel?.borderRadius;
    switch (overALLAppLayoutModel?.themeType) {
      case 1:
        ownerNameColor = appColors.colorCommonLinkColor;
        replyIcon = Assets.theme1WishlistEdit;
        itineraryIcon = Assets.theme1Itinerary;
        break;
      case 2:
        replyIcon = Assets.theme2WishlistEdit;
        itineraryIcon = Assets.theme2Itinerary;
        replyIconSize = 12;
        break;
      case 3:
        isNotRespondedReplyBoxColored = true;
        replyIcon = Assets.theme3WishlistEdit;
        itineraryIcon = Assets.theme3Itinerary;
        break;
      default:
        listingTileColor = appColors.white;
        replyIcon = Assets.theme4WishlistEdit;
        itineraryIcon = Assets.theme4Itinerary;
        isDottedView = true;
        replyIconSize = 15;
        break;
    }
  }
}

class _TextUnderlinePainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final int maxLines;
  final TextDirection textDirection;
  final Color underlineColor;
  final double iconWidth;
  final double iconHeight;

  _TextUnderlinePainter({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.textDirection,
    required this.underlineColor,
    required this.iconWidth,
    required this.iconHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(width: iconWidth, height: iconHeight),
          ),
          TextSpan(text: text, style: style),
        ],
      ),
      maxLines: maxLines,
      textDirection: textDirection,
    );
    
    textPainter.setPlaceholderDimensions([
      PlaceholderDimensions(
        size: Size(iconWidth, iconHeight),
        alignment: PlaceholderAlignment.middle,
      )
    ]);

    textPainter.layout(maxWidth: size.width);

    final metrics = textPainter.computeLineMetrics();
    final paint = Paint()
      ..color = underlineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final line in metrics) {
      final double y = line.baseline + 4.0;
      canvas.drawLine(
        Offset(line.left, y),
        Offset(line.left + line.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TextUnderlinePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.underlineColor != underlineColor ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.iconWidth != iconWidth ||
        oldDelegate.iconHeight != iconHeight;
  }
}