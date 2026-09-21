import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/graphql/__generated__/all_thread_fragment.data.gql.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/inbox/inbox_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_empty_view.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/shimmer.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';

import '../../../../app.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet.dart';

class InboxPage extends CustomStatefulWidget {
  const InboxPage({super.key});

  @override
  InboxPageState createState() => InboxPageState();
}

class InboxPageState extends CustomStatefulWidgetState<InboxPage> with TickerProviderStateMixin {
  late InboxController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.inboxList?.clear();
    isShowLoader = false;
    controller.isLoading.value = true;
    controller.inboxCurrentpage.value = 1;
    App().viewMessageSocketListener(appPreference.userID ?? '');
    isSocketConnected.stream.listen((value) {
      debugPrint("isSocketConnected.value : inbox ${isSocketConnected.value} --- ${Get.currentRoute}");
      if (value == 5 && Get.currentRoute == '/guestHomePage') {
        controller.isLoading.value = false;
        controller.checkNetwork(controller.getAllThreads);
      }
    });
    controller.checkNetwork(controller.getAllThreads);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        isShowBGOnLoader: false,
        action: Assets.drawableTripsRefresh
            .toSVG(
              size: 25,
              colour: appColors.secondaryColor,
              onTap: () {
                controller.inboxCurrentpage.value = 1;
                controller.inboxList!.clear();
                isShowLoader = false;
                controller.isLoading.value = true;
                controller.checkNetwork(controller.getAllThreads);
              },
            )
            .toPad(end: 20),
        title: getMessageTitle(),
        appBarTextFontWeight: AppFont.semiBold,
        body:
        GetBuilder<BottomSheetController>(
            builder: (newController) =>
        showBodyContentWidget()));
  }

  Obx showBodyContentWidget() {
    return Obx(() {
      debugPrint('_showinboxListWidget: ${controller.inboxList?.length} ---${controller.isLoading.value}');
      return toReviewList(
        reviewListScrollController: controller.inboxScrollController,
        reviewList: controller.inboxList,
        reviewsCount: controller.inboxListCount,
        onApiFunction: controller.getAllThreads,
        controller: controller,
        bottomPosition: bottomPadForExtendBody,
        currentPage: controller.inboxCurrentpage,
        isDisableLoader: true,
        isEnableListener: true,
        emptyWidget: _showEmptyWidget(),
        isShowEmpty: () {
          return (controller.inboxList!.isEmpty && !controller.isLoading.value);
        },
        listView: _showListView(),
      ).toShimmer(controller: controller);
    });
  }

  CustomEmptyView _showEmptyWidget() {
    return CustomEmptyView(
      emptyImageWidget: Assets.drawableEmptyInboxImage.toSVG(),
      emptyTitle: label_no_messages.tr,
      emptyDescription: empty_inbox_you_will_see_message_here.trParams(
          {'field': appPreference.isOwner! ? label_renters.tr.toLowerCase() : label_owners.tr.toLowerCase()}),
    );
  }

  Widget _showListView() {
    int itemCount = controller.inboxList != null && controller.inboxList!.isNotEmpty
        ? controller.inboxList!.length
        : controller.isLoading.value
            ? 15
            : 0;
    bool isload =
        (controller.isLoading.value && (controller.inboxList == null || controller.inboxList!.isEmpty));
    bool isshimmerloading = isload;

    return ShimmerLoading(
        isLoading: isshimmerloading,
        widgetType: 'inboxList',
        isDarkMode: controller.isDarkMode(),
        darkModeblend: BlendMode.dstIn,
        child: toListView(
            itemCount: itemCount,
            controller: controller.inboxScrollController,
            key: const PageStorageKey<String>('inboxlist'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: pad(bottom: 40 + bottomViewPadding ),
            itemBuilder: (context, index) {
              GallThreadsFragmentData? item;
              if (controller.inboxList != null && controller.inboxList!.isNotEmpty) {
                var info = controller.getallThreadsInfo(threadId: controller.inboxList![index]?.id ?? 0);
                item = info.$1;
              }

              String photo = '';
              String? name;
              String? createdAt;
              dynamic userInfo;
              if (appPreference.isOwner!) {
                if (item?.guestProfile != null && (item?.guestProfile?.picture ?? '').toString().isNotEmpty) {
                  photo = item!.guestProfile!.picture!;
                }
                userInfo = item?.guestProfile;
                name = item?.guestProfile?.firstName;
              } else {
                if (item?.hostProfile != null && (item?.hostProfile?.picture ?? '').toString().isNotEmpty) {
                  photo = item!.hostProfile!.picture!;
                }
                userInfo = item?.hostProfile;
                name = item?.hostProfile?.firstName;
              }
              (Color, String)? bookingStatusColor;
              if (item?.threadItem != null && item?.threadItem?.type != null) {
                bookingStatusColor = controller.getReservationStatusColor(
                    reservationstatus: item!.threadItem!.type!.toUpperLowerCase());
              }
              if (item?.threadItem != null && item?.threadItem?.createdAt != null) {
                createdAt =
                    getDateFormat(dateFormat: commonDateFormat, milliSec: item!.threadItem!.createdAt!).$1;
              }

              return toOnTap(
                onTap: () {
                  if (!isshimmerloading) {
                    controller.homeNavigator
                        ?.navigateScreen(HomeScreen.viewMessage, param: {'threadItem': item}, fun: () {
                      HomeController ctrl = Get.find<HomeController>();
                      if (appPreference.isOwner ?? false) {
                        ctrl.change(rxVariable: rxhostUnreadCount, value: rxhostUnreadCount.value);
                      } else {
                        ctrl.change(rxVariable: rxguestUnreadCount, value: rxguestUnreadCount.value);
                      }
                    });
                  }
                },
                child: (switch (overALLThemeType) {
                  1 => showTheme1BodyContent,
                  2 => showTheme2BodyContent,
                  3 => showTheme3BodyContent,
                  _ => showTheme4BodyContent,
                })(
                  photo: photo,
                  name: name,
                  createdAt: createdAt,
                  userInfo: userInfo,
                  isshimmerloading: isshimmerloading,
                  item: item,
                  bookingStatusColor: bookingStatusColor,
                )
              );
            }));
  }

  Widget showTheme1BodyContent(
      {required String photo,
      String? name,
      String? createdAt,
      dynamic userInfo,
      required bool isshimmerloading,
      GallThreadsFragmentData? item,
      (Color, String)? bookingStatusColor}) {
    return [
      CustomContainer(
          width: deviceWidth,
          margin: pad(start: 40),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(controller.isRTL()
                ? Assets.drawableViewMessageSenterBg
                : Assets.drawableViewMessageReceiverBg),
            alignment: AlignmentDirectional.topStart,
            fit: BoxFit.fitWidth,
            colorFilter: ColorFilter.mode(appColors.viewMessageReceiverBGColor, BlendMode.srcIn),
          )),
          body: CustomBorderContainer(
              padding: pad(start: 10, end: 10),
              margin: pad(
                start: 22,
              ),
              borderRadius: AppDimen.appBorderRadius / 2,
              color: appColors.viewMessageReceiverBGColor,
              width: deviceWidth,
              body: [
                10.toHeight(),
                [
                  CustomText(
                      text: isshimmerloading ? 20.toGenerateEmptyString() : name ?? '',
                      fontWeight: FontWeight.w500,
                      size: AppDimen.textSize_16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      isShimmerView: isshimmerloading).toResizeWidget(width: deviceWidth-200),
                  CustomText(
                    text: isshimmerloading ? 20.toGenerateEmptyString() : createdAt ?? '',
                    fontWeight: FontWeight.normal,
                    size: AppDimen.textSize_12,
                    isShimmerView: isshimmerloading,
                  )
                ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
                if (isshimmerloading || (item?.threadItem?.content?.isNotEmpty ?? false)) ...[
                  6.toHeight(),
                  CustomText(
                    text: isshimmerloading ? 40.toGenerateEmptyString() :
                    ( item?.threadItem?.content ?? '').trim().isNotEmpty ?
                    (item?.threadItem?.content ?? '').trim() :
                    bookingStatusColor?.$2 ?? '',
                    fontWeight: FontWeight.normal,
                    size: AppDimen.textSize_14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    color: appColors.colorCommonLinkColor,
                    isShimmerView: isshimmerloading,
                  ).toResizeWidget(width: deviceWidth - 110),
                ],
                12.toHeight(),
                _getReservationStatusWidget(
                    isshimmerloading: isshimmerloading,
                    bookingStatusColor: bookingStatusColor,
                    statusFontSize: AppDimen.textSize_14,
                    fillColor: appColors.myTripsBGColor,
                    borderRadius: 30),
                10.toHeight(),
              ].toColumn(),
          ),
      ),
      CustomProfileNetworkImage(
        profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
          imageUrl: photo,
          all: 55,
          isShimmerView: isshimmerloading,
          shimmerColor: appColors.viewMessageReceiverBGColor,
          onTap: () {
            HostReviewBottomSheet()
                .showHostInfo(hostItem: userInfo, profileId: userInfo.profileId, isHost: false, title: label_title_user_profile.tr,);
          }),
    ].toStack().toPad(vertical: 10, horizontal: AppDimen.startMargin);
  }

  Widget showTheme2BodyContent(
      {required String photo,
      String? name,
      String? createdAt,
      dynamic userInfo,
      required bool isshimmerloading,
      GallThreadsFragmentData? item,
      (Color, String)? bookingStatusColor}) {
    return CustomBorderContainer(
            padding: pad(a: 12),
            borderRadius: AppDimen.appBorderRadius / 2,
            color: appColors.viewMessageReceiverBGColor,
            width: deviceWidth,
            body: [
              [
                CustomProfileNetworkImage(
                  profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
                  imageUrl: photo,
                  all: 55,
                  isShimmerView: isshimmerloading,
                  onTap: () {
                    HostReviewBottomSheet()
                        .showHostInfo(hostItem: userInfo, profileId: userInfo.profileId, isHost: false ,title: label_title_user_profile.tr,);
                  },
                ),
                12.toWidth(),
                [
                  CustomText(
                      text: isshimmerloading ? 20.toGenerateEmptyString() : name ?? '',
                      fontWeight: FontWeight.w500,
                      size: AppDimen.textSize_16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                          isShimmerView: isshimmerloading)
                      .toResizeWidget(width: deviceWidth / 2),
                  6.toHeight(),
                  CustomText(
                    text: isshimmerloading ? 20.toGenerateEmptyString() : createdAt ?? '',
                    fontWeight: FontWeight.normal,
                    size: AppDimen.textSize_12,
                    isShimmerView: isshimmerloading,
                  )
                ].toColumn()
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
              if (isshimmerloading || (item?.threadItem?.content?.isNotEmpty ?? false)) ...[
                6.toHeight(),
                CustomText(
                  text: isshimmerloading ? 40.toGenerateEmptyString() :
                  ( item?.threadItem?.content ?? '').trim().isNotEmpty ?  (item?.threadItem?.content ?? '').trim() :
                  bookingStatusColor?.$2 ?? '',
                  fontWeight: FontWeight.normal,
                  size: AppDimen.textSize_14,
                  color: appColors.colorCommonLinkColor,
                  isShimmerView: isshimmerloading,
                ).toResizeWidget(width: deviceWidth - 100),
              ],
              12.toHeight(),
              _getReservationStatusWidget(
                  isshimmerloading: isshimmerloading,
                  bookingStatusColor: bookingStatusColor,
                  statusFontSize: AppDimen.textSize_14,
                  fillColor: appColors.myTripsBGColor,
                  borderRadius: 0),
            ].toColumn())
        .toPad(bottom: 12, horizontal: AppDimen.startMargin);
  }

  Widget showTheme3BodyContent(
      {required String photo,
      String? name,
      String? createdAt,
      dynamic userInfo,
      required bool isshimmerloading,
      GallThreadsFragmentData? item,
      (Color, String)? bookingStatusColor}) {
    return CustomBorderContainer(
      borderRadius: 30,
      margin: pad(w: AppDimen.startMargin, bottom: 18),
      body: [
        CustomBorderContainer(
          height: 60,
          color: appColors.myTripsBGColor,
          borderRadius: 30,
          body: [
            toOnTap(
              onTap: () {
                HostReviewBottomSheet()
                    .showHostInfo(hostItem: userInfo, profileId: userInfo.profileId, isHost: false,title: label_title_user_profile.tr,);
              },
              child: CustomProfileNetworkImage(imageUrl: photo, all: 55, isShimmerView: isshimmerloading,
                profileImageType: overALLAppLayoutModel?.profileIconType ?? '',),
            ),
            12.toWidth(),
            CustomText(
                text: isshimmerloading ? 20.toGenerateEmptyString() : name ?? "",
                size: AppDimen.textSize_16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                isShimmerView: isshimmerloading).toResizeWidget(width: deviceWidth / 2),
            const Spacer(),
            if(!isshimmerloading)
            Assets.drawableForwardArrow.toSVG(colour: appColors.black,size: 16,quarterTurns: controller.isRTL() ? 2 :0 ).toPad(end: 10)
          ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: 6),
        ).toPad(horizontal: 6, top: 6),
        12.toHeight(),
        CustomText(
          text:  isshimmerloading ? 40.toGenerateEmptyString() :
          ( item?.threadItem?.content ?? '').trim().isNotEmpty ?  (item?.threadItem?.content ?? '').trim() :
          bookingStatusColor?.$2 ?? '',
          size: AppDimen.textSize_14,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.normal,
          isShimmerView: isshimmerloading,
        ).toPad(horizontal: 12).toResizeWidget(width: deviceWidth - 50),
        filterDivider.toPad(vertical: 12),
        [
          _getReservationStatusWidget(
              isshimmerloading: isshimmerloading,
              bookingStatusColor: bookingStatusColor,
              isShowAsDot: true,
              statusFontSize: AppDimen.textSize_14,
              fillColor: appColors.myTripsBGColor,
              borderRadius: 30),
          const Spacer(),
          CustomText(
            text: createdAt ?? '',
            size: AppDimen.textSize_12,
          ),
        ].toRow().toPad(bottom: 12, horizontal: 12)
      ].toColumn(),
    );
  }

  Widget showTheme4BodyContent(
      {required String photo,
      String? name,
      String? createdAt,
      dynamic userInfo,
      required bool isshimmerloading,
      GallThreadsFragmentData? item,
      (Color, String)? bookingStatusColor}) {
    debugPrint("showTheme4BodyContentcontent: ${item?.threadItem?.content !=null && (item?.threadItem?.content ?? '').trim().isNotEmpty} --- ${bookingStatusColor?.$2}");
    return [
      CustomContainer(
        width: deviceWidth,
        body: [
          CustomProfileNetworkImage(
            profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
            imageUrl: photo,
            all: 55,
            isShimmerView: isshimmerloading,
            onTap: () {
              HostReviewBottomSheet()
                  .showHostInfo(hostItem: userInfo, profileId: userInfo.profileId, isHost: false,title: label_title_user_profile.tr,);
            },
          ),
          12.toWidth(),
          [
            [
              CustomText(
                  text: isshimmerloading ? 20.toGenerateEmptyString() : name ?? '',
                  fontWeight: FontWeight.w500,
                  size: AppDimen.textSize_16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  isShimmerView: isshimmerloading).toResizeWidget(width: deviceWidth-185),
              CustomText(
                text: isshimmerloading ? 20.toGenerateEmptyString() : createdAt ?? '',
                fontWeight: FontWeight.normal,
                size: AppDimen.textSize_12,
                isShimmerView: isshimmerloading,
              ),
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
              6.toHeight(),
              CustomText(
                text:  isshimmerloading ? 20.toGenerateEmptyString() :
                item?.threadItem?.content !=null && (item?.threadItem?.content ?? '').trim().isNotEmpty ?
                (item?.threadItem?.content ?? '').trim() :
                bookingStatusColor?.$2 ?? '',
                fontWeight: FontWeight.normal,
                size: AppDimen.textSize_14,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                isShimmerView: isshimmerloading,
              ).toResizeWidget(width: deviceWidth - 100),
            if(isshimmerloading)
              12.toHeight(),
            if(bookingStatusColor !=null && bookingStatusColor.$2.isNotEmpty)
            12.toHeight(),
            _getReservationStatusWidget(
                isshimmerloading: isshimmerloading,
                bookingStatusColor: bookingStatusColor,
                statusFontSize: AppDimen.textSize_14,
                borderRadius: 18,
                isShowAsDot: true,
                isShowBorder: true,
                textColor: bookingStatusColor?.$1),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).toStretch()
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start)
            .toResizeWidget(width: deviceWidth),
      ),
      CustomDashDivider(
        width: deviceWidth,
        isCircle: false,
        height: 10,
        dashWidth: 7,
        dashHeight: 1,
        color: appColors.filterDividerColor,
      ).toPad(
        vertical: 12,
      )
    ].toColumn().toPad(horizontal: AppDimen.startMargin);
  }

  Widget _getReservationStatusWidget(
      {required bool isshimmerloading,
      (Color, String)? bookingStatusColor,
      bool? isShowAsDot,
      Color? fillColor,
      bool? isShowBorder,
      double? borderRadius,
      double? statusFontSize,
      Color? textColor}) {
    if (isshimmerloading) {
      return CustomText(
          text: 30.toGenerateEmptyString(), size: AppDimen.textSize_16, isShimmerView: isshimmerloading);
    }

    if ((isShowAsDot ?? false) && bookingStatusColor != null && bookingStatusColor.$2.isNotEmpty) {
      return CustomBorderContainer(
        color: fillColor ?? Colors.transparent,
        padding: pad(a: 5),
        borderColor: (isShowBorder ?? false) ? bookingStatusColor.$1 : null,
        borderWidth: 1.5,
        borderRadius: borderRadius ?? AppDimen.appBorderRadius,
        body: [
          CustomWishlistContainer(
            width: 12,
            height: 12,
            color: bookingStatusColor.$1,
          ),
          5.toWidth(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceWidth-180,
            ),
            child: CustomText(
              text: bookingStatusColor.$2,
              color: textColor,
              overflow: TextOverflow.ellipsis,
              size: statusFontSize,
            ),
          ).toStretch(isExpanded: false)
        ].toRow(mainAxisSize: MainAxisSize.min),
      );
    } else {
      return (bookingStatusColor != null && bookingStatusColor.$2.isNotEmpty) ?
        CustomBorderContainer(
            color: bookingStatusColor.$1,
        padding: pad(h: 5,w:12),
        borderRadius: borderRadius ?? AppDimen.appBorderRadius,
        body:  CustomText(
          text: bookingStatusColor.$2,
          color:  appColors.buttonTextColor,
          overflow: TextOverflow.ellipsis,
          size: AppDimen.textSize_14,

        )
      ) : 0.toHeight();
    }
  }

  (double, double, bool) getAdjustWidth(
      {required String status,
      required String name,
      required double statusMaxWidth,
      required double nameMaxWidth,
      required double statusMinWidth,
      required double nameMinWidth,
      bool isstatusExpand = false}) {
    if (nameMaxWidth < nameMinWidth || statusMaxWidth < statusMinWidth) {
      return (nameMaxWidth, statusMaxWidth, isstatusExpand);
    }
    bool isstatusoverflow = App().hasTextOverflow(
        "${status}21",
        TextStyle(
          fontSize: 15.5,
        ),
        maxWidth: statusMaxWidth,
        minWidth: statusMinWidth,
        maxLines: 1);
    bool isnameoverflow = App().hasTextOverflow(
        name,
        TextStyle(
          fontSize: AppDimen.textSize_16,
        ),
        maxWidth: nameMaxWidth,
        minWidth: nameMinWidth,
        maxLines: 1);

    return switch ((isstatusoverflow, isnameoverflow)) {
      (true, false) => getAdjustWidth(
          status: status,
          name: name,
          statusMaxWidth: statusMaxWidth + 1,
          nameMaxWidth: nameMaxWidth - 1,
          nameMinWidth: nameMinWidth,
          statusMinWidth: statusMinWidth,
          isstatusExpand: true,
        ),
      (false, true) => getAdjustWidth(
          status: status,
          name: name,
          statusMaxWidth: statusMaxWidth - 1,
          nameMaxWidth: nameMaxWidth + 1,
          nameMinWidth: nameMinWidth,
          statusMinWidth: statusMinWidth,
        ),
      (true, true) => (nameMaxWidth, statusMaxWidth, true),
      _ => (nameMaxWidth, statusMaxWidth, isstatusExpand),
    };
  }

  @override
  void dispose() {
    controller.lifecycleListener?.dispose();
    super.dispose();
  }
}