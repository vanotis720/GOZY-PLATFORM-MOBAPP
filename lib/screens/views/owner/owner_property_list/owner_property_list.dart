import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/owner/owner_property_list/owner_property_list_navigator.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_underline_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_empty_view.dart';
import 'package:gozy/widgets/custom_popup_menu.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/rect_getter.dart';
import 'package:gozy/widgets/shimmer.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';

import '../../../../config/client.dart';
import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../model/tab_bar_item_model.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';
import 'owner_property_list_controller.dart';

class OwnerPropertyListPage extends CustomStatefulWidget {
  const OwnerPropertyListPage({super.key});

  @override
  OwnerPropertyListPageState createState() => OwnerPropertyListPageState();
}

class OwnerPropertyListPageState extends CustomStatefulWidgetState<OwnerPropertyListPage>
    with TickerProviderStateMixin {
  late OwnerPropertyListController controller = Get.find();
  final double _paddingSize = (AppDimen.startMargin / 2);
  final List<String> _tabs = ListType.values.map((e) => ListType.getMultiLanguageString(e)).toList();
  int _previousIndex = 0;
  double popupBorderRadius = 0;
  bool isLoadManageListings = false;
  Color? propertyActionWidgetColor;
  double? imageBorderRadius;
  Color? titleAndProgressViewColor;
  Color publishButtonColor = appColors.white;
  String? moreIcon;
  double? moreIconSize;
  bool showAsFloating = false;
  Color? addButtonBG;
  Color? addButtonIcon;
  bool isMoreNeeded = true;
  bool isDashedContainer = false;

  @override
  void initState() {
    isShowLoader = false;
    controller.initialCount = -1;
    controller.isLoading.value = false;
    if (controller.tabController != null) {
      if (!controller.latetabController.val.animation!.value.isInt) {
        controller.tabController.index =
            int.parse(controller.latetabController.val.animation?.value.toStringAsFixed(0) ?? '0');
      }
      controller.isLoading.refresh();
    }

    if (controller.tabBarItems.isEmpty) {
      controller.tabController =
          controller.latetabController.val = TabController(length: _tabs.length, vsync: this);
      controller.tabBarItems = List<TabBarItemModel>.generate(_tabs.length, (index) {
        PageStorageKey pageKey = PageStorageKey('${_tabs[index]}: ${Random().nextInt(10000)}');
        debugPrint('listcurrentpage set: 3 : ${controller.tabController.index}');
        TabBarItemModel tabBarModal = (
          pageStorageKey: pageKey,
          totalCount: 1,
          tabBarListData: [],
          tabliistScrollController: ScrollController(),
          listCurrentpage: 1.obs,
          isTabLoading: true,
          type: _tabs[index],
          nonFilterTabBarListData: []
        );
        return tabBarModal;
      });

      controller.tabController.addListener(() {
        if (controller.tabController.index != _previousIndex) {
          TabBarItemModel previoustabitems = controller.tabBarItems[_previousIndex];
          List<dynamic> list = controller.initialCount > previoustabitems.tabBarListData.length
              ? []
              : previoustabitems.tabBarListData;
          int currentPage = controller.initialCount > previoustabitems.tabBarListData.length
              ? 1
              : previoustabitems.listCurrentpage.value;
          if (controller.tabBarItems[controller.tabController.index].listCurrentpage.value != 0) {
            controller.initialCount = -1;
          }
          controller.tabBarItems[_previousIndex] = previoustabitems.copyWith(
              isTabLoading: true, tabBarListData: list, listCurrentpage: currentPage);
          var currentTabItem = controller.tabBarItems[controller.tabController.index];
          debugPrint(
              'currentTabItem.ScrollControllerinprogress: ${currentTabItem.tabliistScrollController.positions} --- ${controller.initialCount}');
          if (controller.refreshingTabIndex == controller.tabController.index &&
              currentTabItem.tabliistScrollController.hasClients) {
            controller.clearListData();
            controller.tabBarItems[controller.tabController.index].tabliistScrollController.jumpTo(0);
          }
          isShowLoader = false;
          controller.isLoading.value = false;
          _previousIndex = controller.tabController.index;
          controller.isRefreshInprogressListTab.value = true;
          controller.tabBarItems[controller.tabController.index] =
              currentTabItem.copyWith(isTabLoading: true, listCurrentpage: 1);
          controller.isLoading.value = true;
          controller.checkNetwork(controller.getManageListings);
        }
      });
    }
    _previousIndex = controller.tabController.index;
    if (controller.tabBarItems[controller.tabController.index].tabBarListData.isEmpty) {
      controller.tabBarItems[controller.tabController.index] =
          controller.tabBarItems[controller.tabController.index].copyWith(
        isTabLoading: true,
      );
      controller.isLoading.value = true;
      controller.checkNetwork(controller.getDefaultSettingsData);
    }

    debugPrint('controller.completedLists: ${controller.completedLists}');

    ever(controller.tabBarItemsCount, (value) {
      if (isLoadManageListings) {
        debugPrint('listcurrentpage set: 6 : ${controller.tabController.index}');
        controller.isEnableNewScrollController = false;
        getFirstPagelistData();
      }
    });
    ever(controller.isRefreshInprogressListTab, (value) {
      debugPrint('isRefreshInprogressListTab: $value');
      if (value) {
        controller.initialCount = -1;
        controller.isRefreshInprogressListTab.value = false;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      backIcon: '',
      loader: LottieLoaders.three_dots_loader,
      isShowBGOnLoader: false,
      action: !showAsFloating ? (overALLThemeType == 1) ? CustomContainer(
        height: 30,
        width: 30,
        onTap: () {
          controller.moveToLetsStartPage();
        },
        decoration: BoxDecoration(
          color: addButtonBG,
          borderRadius: BorderRadius.circular(6)
        ),
        body: Assets.drawableCountIncrement.toSVG(
          size: 20,
          colour: addButtonIcon,
        ).toPad(all: 6),
      ).toPad(end: AppDimen.startMargin) : Assets.drawableCountIncrement.toSVG(
        size: 20,
        colour: appColors.secondaryColor,
        onTap: (){
          controller.moveToLetsStartPage();
        },
      ).toPad(end:AppDimen.startMargin) : const SizedBox.shrink(),
      title: tabbar_listings.tr,
      appBarTextFontWeight: AppFont.semiBold,
      appBartextFontSize: AppDimen.textSize_26,
      body: showBodyContentWidget(),
      floatingActionButton: showAsFloating ? CustomContainer(
        height: 54,
        width: 54,
        onTap: () {
          controller.moveToLetsStartPage();
        },
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(appLayoutMap[AppLayout.themeType]?.borderRadius ?? AppDimen.appBorderRadius),
          color: addButtonBG
        ),
        body: Assets.drawableCountIncrement.toSVG(
          colour: addButtonIcon,
        ).toPad(all: 15),
      ).toPad(bottom: 5) : const SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget showBodyContentWidget() {
    return GetBuilder<OwnerPropertyListController>(builder: (newController) {
      debugPrint('ownerproperty list called');
      return toTabBarView(
        tabs: _tabs,
        themeType: overALLThemeType,
        tabBarWidgets: List<Widget>.generate(controller.tabBarItems.length, (index) {
          return _showPropertyListWidget(index).toPad(top: 10);
        }),
        tabController: controller.tabController,
      );
    });
  }

  CustomEmptyView _showEmptyWidget() {
    return CustomEmptyView(
      emptyImageWidget: [
        Assets.drawableNoListing.toSVG(),
      ].toStack(),
      emptyTitle: empty_title_you_dont_have.trParams({"field": label_tabbar_cars.tr.toLowerCase()}),
      emptyDescription: label_list_your_unused_space_to_make_money.tr,
      buttonImage: Assets.drawableCountIncrement,
      buttonText: btn_label_add_a_new_listing.tr,
      isPrimaryButton: true,
      isFlexibleText: true,
      onTap: () {
        controller.moveToLetsStartPage();
      },
    );
  }

  Widget _showPropertyListWidget(int index) {
    return Obx(() {
      TabBarItemModel tabItem = controller.tabBarItems[index];

      debugPrint(
          "ScrollControllerinprogress: 3  ---$index --- ${controller.isEnableNewScrollController} -- ${tabItem.listCurrentpage}");
      return toReviewList(
        reviewListScrollController: tabItem.tabliistScrollController,
        reviewList: tabItem.tabBarListData,
        reviewsCount: tabItem.totalCount,
        onApiFunction: getManageListings,
        isShowPaginationAtFirst: !controller.isEnableNewScrollController,
        swipeToRefreshIntialFunction: (){
          controller.initialCount = -1;
          TabBarItemModel tabItem = controller.tabBarItems[controller.tabController.index];
          controller.tabBarItems[controller.tabController.index] = tabItem.copyWith(isTabLoading: true);
          isShowLoader = false;
        },
        controller: controller,
        currentPage: tabItem.listCurrentpage,
        isDisableLoader: true,
        isPaginationLoader: controller.isPaginationLoader,
        isEnableListener: false,
        emptyWidget: _showEmptyWidget(),
        isShowEmpty: () {
          return (tabItem.tabBarListData.isEmpty && index == controller.tabController.index);
        },
        listView: _showListView(
            tabItem: tabItem,
            isshimmerloading: (tabItem.tabBarListData.isEmpty ? true : tabItem.isTabLoading)),
      ).toShimmer(controller: controller);
    });
  }

  Widget _showListView({
    required TabBarItemModel tabItem,
    required bool isshimmerloading,
  }) {
    List<dynamic>? propertyList = tabItem.tabBarListData;
    PageStorageKey storekey = tabItem.pageStorageKey;
    ScrollController scrollController = tabItem.tabliistScrollController;
    int itemCount = isshimmerloading
        ? 5
        : propertyList.isNotEmpty
            ? propertyList.length
            : 0;

    if ((controller.initialCount == -1 || controller.initialCount < itemCount) &&
        !isshimmerloading &&
        propertyList.isNotEmpty) {
      controller.initialCount = itemCount;
    }
    if (!isshimmerloading && propertyList.isNotEmpty) {
      isLoadManageListings =
          controller.initialCount != controller.tabBarItems[controller.tabController.index].totalCount &&
              itemCount <= 5;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.tabBarItemsCount.value = itemCount;
      });
    }

    return ShimmerLoading(
      isLoading: isshimmerloading,
      widgetType: 'OwnerpropertyList',
      isDarkMode: controller.isDarkMode(),
      darkModeblend: BlendMode.dstIn,
      child: toListView(
          itemCount: itemCount,
          controller: scrollController,
          key: storekey,
          physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: pad(
              bottom: 30 + bottomViewPadding + bottomPadForExtendBody, top: 10, w: AppDimen.startMargin - 1),
          itemBuilder: (context, index) {
            dynamic item;
            if (!isshimmerloading) {
              item = propertyList[index];
              GviewListingDetailsFragmentReq fragmentReq =
                  GviewListingDetailsFragmentReq((b) => b..idFields = {'id': item?.id});
              item = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
            }
            String photo = '';
            int id = item?.id ?? 0;
            String title = "";
            if (item != null) {
              title = item?.title ?? 47.toGenerateEmptyString();
            }
            if (item != null && title.trim().isEmpty) {
              title = '${item.carType} in ${item.city}';
            }
            int updatedon = int.parse(item?.lastUpdatedAt ?? "0");

            if (item?.listPhotoName != null && item!.listPhotoName.toString().isNotEmpty) {
              photo = imgListingMedium + (item!.listPhotoName!);
            }

            final steps = item?.listingSteps;
            final bool isPhotoEmpty = photo.isEmpty;

            int progress = (item?.isReady ?? false)
                ? 100
                : switch ((steps?.step1, steps?.step2, steps?.step3, isPhotoEmpty)) {
                    // Case 1: Step 1 is active OR the entire steps object is null
                    ('active', _, _, _) || (null, null, null, _) => 20,

                    // Case 2 & 3: Step 2 logic
                    (_, 'active', _, true) => 30,
                    (_, 'active', _, false) => 40,

                    // Case 4 & 5: Step 3 logic
                    (_, _, 'active', true) => 50,
                    (_, _, 'active', _) => 60,

                    // Case 6: Fallback for empty photos
                    (_, _, _, true) => 90,

                    // Case 7: Default (100% / Completed)
                    _ => 100,
                  };

            bool isPublished = item?.isPublished ?? false;

            List<Widget> ListItemWidgets = [];
            ListItemWidgets.add(_buildListingDetailInfo(photo, id, isshimmerloading, [
              CustomText(
                text: isshimmerloading ? 20.toGenerateEmptyString() : title,
                maxLines: 3,
                fontWeight: AppFont.bold,
                size: AppDimen.textSize_14,
                overflow: TextOverflow.ellipsis,
                color: appColors.customTextColor,
                isShimmerView: isshimmerloading,
              ),
              5.toHeight(),
              CustomText(
                  text: isshimmerloading
                      ? 35.toGenerateEmptyString()
                      : '${label_last_edited_on.tr} ${getDateFormat(dateFormat: propertyListDateformat, milliSec: updatedon).$1}',
                  maxLines: 2,
                  size: AppDimen.textSize_14,
                  fontWeight: AppFont.regular,
                  isShimmerView: isshimmerloading)
            ]));

            if (!isshimmerloading && !isDashedContainer) {
              ListItemWidgets.add(
                  _buildPropertyActionWidget(progress: progress, isPublished: isPublished, itemInfo: item));
            }

            List<Widget> ListItemWidgetsWithDivider = ListItemsWithDivider(
              WidgetList: ListItemWidgets,
              space: 0,
            );
            ListItemWidgetsWithDivider.insert(
                1, _buildPropertyCreationPercentage(progress: progress, isshimmerloading: isshimmerloading));
            if (!isshimmerloading && isDashedContainer) {
              ListItemWidgetsWithDivider.insert(
                  2,
                  CustomDashDivider(
                    color: appColors.filterDividerColor,
                    width: Get.width,
                    dashWidth: 6,
                    dashHeight: 1,
                    isCircle: false,
                    isPaddingNotNeeded: true,
                    height: 1,
                  ));
              ListItemWidgetsWithDivider.insert(3,
                  _buildPropertyActionWidget(progress: progress, isPublished: isPublished, itemInfo: item));
            }
            return !isDashedContainer
                ? CustomBorderContainer(
                    color: titleAndProgressViewColor,
                    borderRadius: overALLAppLayoutModel?.borderRadius,
                    borderColor: appColors.filterDividerColor,
                    padding: pad(top: 10),
                    borderWidth: 0.5,
                    margin: pad(bottom: 20),
                    body: [for (Widget item in ListItemWidgetsWithDivider) item].toColumn(),
                  )
                : DottedBorderView(
                        dottedlineColor: appColors.filterDividerColor,
                        dashPattern: [6, 6],
                        borderRadius: overALLAppLayoutModel?.borderRadius,
                        topPadding: 10,
                        child: [for (Widget item in ListItemWidgetsWithDivider) item].toColumn())
                    .toPad(bottom: 10);
          }),
    );
  }

  Widget _buildListingDetailInfo(String photo, int id, bool isshimmerloading, List<Widget> listwidget) {
    return toListImageRow(
      photo: photo,
      borderRadius: imageBorderRadius,
      id: id,
      ListItemWidgets: listwidget,
      removePaddingAfterImage: true,
      isshimmerloading: isshimmerloading
    ).toPad(bottom: _paddingSize, horizontal: _paddingSize);
  }

  Widget _buildPropertyCreationPercentage({required int progress, bool isshimmerloading = false}) {
    return [
      CustomText(
        text: '${label_you_done_with_your_car.trParams({'field': '$progress%'})}',
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
        isShimmerView: isshimmerloading,
      ),
      15.toHeight(),
      if (!isshimmerloading) getLinearIndicator(progress: progress.toString()),
      if (!isshimmerloading) 10.toHeight(),
    ].toColumn().toPad(vertical: (overALLThemeType == 3) ? 5 : _paddingSize, horizontal: _paddingSize);
  }

  Widget _buildPropertyActionWidget({required int progress, bool isPublished = false, dynamic itemInfo}) {
    double btnsize = (deviceWidth / 3) - 15;
    bool isToShowpublishButton = controller.tabController.index != 0;
    if (listingApproval == 1) {
      isToShowpublishButton = isToShowpublishButton &&
          (itemInfo?.listApprovalStatus != null && itemInfo?.listApprovalStatus != 'pending');
    }
    if (progress != 100) {
      btnsize = (deviceWidth / 10) + (('${label_edit.tr} ${label_listing_single.tr}'.length) * 6);
    }

    var overlayIconKey = RectGetter.createGlobalKey();
    return CustomContainer(
      decoration: BoxDecoration(
        color: propertyActionWidgetColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(overALLAppLayoutModel!.borderRadius),
          bottomRight: Radius.circular(overALLAppLayoutModel!.borderRadius),
        ),
      ),
      padding: pad(w: _paddingSize, h: _paddingSize),
      body: [
        [
          PrimaryColorButton(
            text: '${label_edit.tr} ${label_listing_single.tr}',
            borderRadius: overALLAppLayoutModel?.borderRadius,
            isArrowNeeded: false,
            onTap: () {
              controller.selectedlistid = itemInfo.id;
              controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepFinal, param: {
                'iteminfo': itemInfo,
                'updateManagelist': (id) {},
                'refreshlistings': () {
                  getFirstPagelistData();
                },
                'removedeletedlisting': () {
                  controller.tabController.index = 1;
                  debugPrint('controller1.tabController.index: ${controller.tabController.index}');
                  isShowLoader = false;
                  controller.checkNetwork(controller.getManageListings);
                },
              });
            },
            horizontalPadding: 10,
            textSize: AppDimen.textSize_14,
          ).toResizeWidget(width: btnsize),
          if (isToShowpublishButton)
            CancelButton(
                buttonText: isPublished ? btn_label_unpublish.tr : btn_label_publish.tr,
                textSize: AppDimen.textSize_14,
                isArrowNeeded: false,
                verticalPadding: 10,
                horizontalPadding: 10,
                borderRadius: overALLAppLayoutModel?.borderRadius,
                color: appColors.primaryColor,
                fillcolor: publishButtonColor,
                onTap: () {
                  controller.selectedlistid = itemInfo?.id ?? 1;
                  print("options:::: ${itemInfo}");
                  debugPrint('controller.isLoading: ${controller.isLoading.value}');
                  if (!controller.isLoading.value && !isLoadManageListings) {
                    isShowLoader = true;
                    controller.isLoading.value = true;
                    controller.updateStatus = isPublished ? 'unPublish' : 'publish';
                    controller.checkNetwork(controller.managePublishStatus);
                  }
                }).toResizeWidget(width: btnsize - 5).toPad(start: 10),
          const Spacer(),
          toOnTap(
            onTapUp: (details) {
              Rect? overlayrect = RectGetter.getRectFromKey(overlayIconKey);
              debugPrint("details.globalPosition: ${details.globalPosition}--: $overlayrect");
              toShowMenu(
                  Offset(overlayrect?.right ?? details.globalPosition.dx,
                      (overlayrect?.top ?? details.globalPosition.dy) + (overALLThemeType == 3 ? 10 : 6)),
                  itemInfo: itemInfo,
                  progress: progress);
            },
            child: RectGetter(
              key: overlayIconKey,
              child: [
                if (isMoreNeeded) ...[
                  (moreIcon ?? Assets.drawableViewdetailShareMore)
                      .toSVG(size: moreIconSize, colour: appColors.secondaryColor),
                  3.toWidth(),
                ],
                if (isMoreNeeded)
                  CustomText(
                    text: label_share_listing_more.tr,
                    color: appColors.secondaryColor,
                    size: AppDimen.textSize_12,
                    fontWeight: AppFont.regular,
                  ),
                3.toWidth(),
                if (!isMoreNeeded) (moreIcon ?? Assets.drawableViewdetailShareMore).toSVG(size: moreIconSize),
              ].toRow(),
            ),
          ).toPad(start: 10)
        ].toRow(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center),
        if (listingApproval == 1 && itemInfo != null && itemInfo.listApprovalStatus == 'pending')
          CustomText(
            text: '*${label_waiting_for_admin_approval.tr}',
            size: AppDimen.textSize_10,
          ).toPad(top: 5),
        if (itemInfo != null) getDeclinedWidget(itemInfo, 0),
      ].toColumn(mainAxisSize: MainAxisSize.min),
    );
  }

  void toShowMenu(Offset offset, {dynamic itemInfo, int? progress}) async {
    int previewlength = menuitem_label_preview.tr.toString().length;
    int deletelength = label_delete.tr.toString().length;
    int maxlength = previewlength;
    if (((deletelength > previewlength) || progress !=  100) && !controller.isRTL()) {
      maxlength = deletelength;
    }
    List<Map<String, dynamic>> listingsmenulist = [];
    Map<String, dynamic> previewitem = {};
    previewitem['icon'] = Assets.drawablePropertyListMenuitemPreview.toSVG(
      size: 12,
      colour: appColors.black,
    );
    previewitem['maxlength'] = double.parse(((maxlength * 11)).toString());
    previewitem['text'] = menuitem_label_preview.tr;
    previewitem['ontap'] = () {
      controller.ownerPropertyListNavigator
          .navigateScreen(OwnerPropertyListScreen.propertyDetail, param: [itemInfo, "propertydetail"]);
    };
    if (progress == 100) {
      listingsmenulist.add(previewitem);
    }
    Map<String, dynamic> deleteitem = {};
    deleteitem['icon'] = CustomCounterContainer(
      borderColor: appColors.black,
      borderWidth: 1,
      padding: pad(a: 3),
      body: Assets.drawableSignupClose.toSVG(
        size: 5,
        colour: appColors.black,
      ),
    );
    deleteitem['maxlength'] = double.parse(((maxlength * 11)).toString());
    deleteitem['text'] = label_delete.tr;
    deleteitem['ontap'] = () {
      toShowDeletePropertyDialog(listid: itemInfo?.id ?? 1);
    };
    listingsmenulist.add(deleteitem);
    CustomPopupMenu(
      borderRadius: popupBorderRadius,
      controller: controller,
      PopupMenuItems: listingsmenulist,
      offset: offset
    );
  }

  void toShowDeletePropertyDialog({required int listid}) {
    String title = 'label_delete_this_car'.tr;
    String content = 'label_delete_listing_dialog_content'.tr;
    showAlertDialog(
      contentText: content,
      onOkPressed: () {
        controller.selectedlistid = listid;
        controller.checkNetwork(controller.deleteListing);
        Get.back();
      },
      cancelButtonContent: label_cancel.tr,
      okButtonContent: label_delete.tr,
      title: title,
    );
  }

  Widget getDeclinedWidget(itemInfo, textSize) {
    return (listingApproval == 1 && itemInfo.listApprovalStatus == 'declined')
        ? [
            CustomText(
              text: label_your_listing_request_declined_by_admin_and_read_decline_reason_and_submit.tr,
              size: textSize > 0 ? textSize : AppDimen.textSize_10,
            ).toPad(top: 5),
            CustomUnderlineText(
              text: label_link_decline_reason.tr,
              size: textSize > 0 ? textSize : AppDimen.textSize_10,
              color: appColors.secondaryColor,
              decorationColor: appColors.secondaryColor,
              onTap: () {
                String title = label_link_decline_reason.tr;

                showAlertDialog(
                  content: CustomText(
                    text: itemInfo.declinedReason,
                    fontWeight: FontWeight.normal,
                    font: AppFont.font,
                  ),
                  cancelButtonContent: label_done.tr,
                  title: title,
                );
              },
            ).toPad(top: 5)
          ].toColumn()
        : const SizedBox.shrink();
  }

  void getManageListings() {
    debugPrint(
        'controller.initialCountgetManageListings: ${controller.initialCount} -- ${controller.tabBarItemsCount.value} --- ${controller.tabBarItems[controller.tabController.index].tabBarListData.length} ---- ${controller.tabBarItemsCount.value} --- ${controller.tabBarItems[controller.tabController.index].listCurrentpage}');

    if (controller.initialCount != -1 &&
            controller.initialCount !=
                controller.tabBarItems[controller.tabController.index].tabBarListData.length ||
        controller.tabBarItems[controller.tabController.index].listCurrentpage.value == 1) {
      var scrollcontroller = controller.tabBarItems[controller.tabController.index].tabliistScrollController;
      if (scrollcontroller.positions.length == 1 && scrollcontroller.offset > 5.0) {
        controller.isEnableNewScrollController = false;
      }
      getFirstPagelistData();
    } else {
      controller.getManageListings();
    }
  }

  void getFirstPagelistData() {
    controller.initialCount = -1;
    TabBarItemModel tabItem = controller.tabBarItems[controller.tabController.index];
    debugPrint('getFirstPagelistDatacurrenttab page: ${tabItem.listCurrentpage.value}');
    controller.tabBarItems[controller.tabController.index] = tabItem.copyWith(
      listCurrentpage: 1,
    );
    isShowLoader = false;
    controller.isLoading.value = true;
    controller.checkNetwork(controller.getManageListings);
  }

  void initThemeData() {
    switch (overALLThemeType) {
      case 1:
        propertyActionWidgetColor = appColors.listingItemBGColor;
        popupBorderRadius = 6;
        titleAndProgressViewColor = appColors.listingItemBGColor;
        publishButtonColor = appColors.listingItemBGColor;
        moreIcon = Assets.theme1More;
        addButtonBG = appColors.black;
        addButtonIcon = appColors.white;
        moreIconSize = 12;
        imageBorderRadius = 6;
        break;
      case 2:
        propertyActionWidgetColor = appColors.theme4AppBarBg;
        publishButtonColor = appColors.theme4AppBarBg;
        popupBorderRadius = 0;
        titleAndProgressViewColor = appColors.white;
        moreIcon = Assets.theme2More;
        moreIconSize = 10;
        imageBorderRadius = 0;
        break;
      case 3:
        propertyActionWidgetColor = appColors.white;
        titleAndProgressViewColor = appColors.white;
        moreIcon = Assets.theme3Theme3MoreIcon;
        showAsFloating = true;
        addButtonBG = appColors.black;
        addButtonIcon = appColors.white;
        publishButtonColor = appColors.white;
        moreIconSize = 25;
        isMoreNeeded = false;
        imageBorderRadius = 25;
        popupBorderRadius = 12;
        break;
      default:
        propertyActionWidgetColor = appColors.white;
        titleAndProgressViewColor = appColors.white;
        publishButtonColor = appColors.white;
        moreIcon = Assets.theme4More;
        addButtonBG = appColors.secondaryColor;
        addButtonIcon = AppColors.staticwhite;
        showAsFloating = true;
        isDashedContainer = true;
        moreIconSize = 12;
        imageBorderRadius = 6;
        popupBorderRadius = 6;
        break;
    }
  }
}