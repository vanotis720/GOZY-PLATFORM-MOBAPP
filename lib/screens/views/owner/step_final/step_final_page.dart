import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/owner/owner_property_list/owner_property_list_controller.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_text/custom_underline_text.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../utils/common_api_controller.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';
import '../../base_controller.dart';
import '../../custom_scaffold.dart';
import '../owner_property_list/owner_property_list_navigator.dart';

class StepFinalScreen extends CustomStatefulWidget {
  const StepFinalScreen({super.key});

  @override
  _StepFinalScreenState createState() => _StepFinalScreenState();
}

class _StepFinalScreenState extends CustomStatefulWidgetState<StepFinalScreen> {
  late OwnerPropertyListController controller = Get.find();
  dynamic itemInfo;
  bool _isShowBottomLayout = false,  isBoxShadowNeeded = false;
  String? publishContent, publishbtnText;
  String rightArrow = '';
  String editIcon = '';
  MainAxisAlignment? editButtonPlace;
  int _removedlistId = 0;
  bool isListUpdate = false;
  bool isContainerNeeded = false;
  bool isCurvedContainer = false;
  bool isArrowNeededOnPre = false;
  Color? stepTitleIconBorderColor;
  Color? stepLayoutBorderColor;
  Color? stepLayoutContainerColor;
  Color? dividerColors;

  @override
  void initState() {
    controller.isToRefreshlisting = true;
    controller.stepFinalarguments.value = Get.arguments;
    itemInfo = controller.stepFinalarguments.value['iteminfo'];
    if (itemInfo == null) onRefresh();

    ever(controller.stepFinalarguments, (value) {
      itemInfo = value['iteminfo'];
      if (itemInfo == null && value['refreshlist'] != null && value['refreshlist']) {
        onRefresh();
      }
    });
    isListUpdate = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countriesData == null) {
        controller.getCountries().then((value) {
          controller.isLoading.value = false;
        });
      }
    });
    super.initState();
  }

  void initThemeData() {
    rightArrow = '';
    editIcon = '';
    stepTitleIconBorderColor = appColors.black;
    stepLayoutBorderColor = appColors.filterDividerColor;
    dividerColors = appColors.filterDividerColor;
    editButtonPlace = MainAxisAlignment.end;
    stepLayoutContainerColor = appColors.white;
    switch (overALLThemeType) {
      case 1:
        rightArrow = Assets.drawableRightArrow;
        isArrowNeededOnPre = true;
        break;
      case 2:
        editIcon = Assets.theme2WishlistEdit;
        stepTitleIconBorderColor = appColors.colorCommonLinkColor;
        stepLayoutBorderColor = appColors.colorCommonLinkColor;
        dividerColors = appColors.colorCommonLinkColor;
        isBoxShadowNeeded = true;
        break;
      case 3:
        editIcon = Assets.theme3WishlistEdit;
        stepTitleIconBorderColor = appColors.colorCommonLinkColor;
        editButtonPlace = MainAxisAlignment.center;
        isContainerNeeded = true;
        break;
      default:
        editIcon = Assets.theme4WishlistEdit;
        stepTitleIconBorderColor = appColors.white;
        editButtonPlace = MainAxisAlignment.center;
        stepLayoutBorderColor = appColors.colorCommonLinkColor;
        stepLayoutContainerColor = appColors.theme4AppBarBg;
        isContainerNeeded = true;
        isCurvedContainer = true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      customAppBarFunction: _updatelistings,
      backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
          backIcon: overALLAppLayoutModel?.backIcon,
          margin: pad(
            start: 20,
            h: 15,
          ),
          onTap: _updatelistings),
      body: GetBuilder<OwnerPropertyListController>(builder: (newController) => showBodyContent(context)),
    );
  }

  Widget showBodyContent(context) {
    GviewListingDetailsFragmentReq fragmentReq = GviewListingDetailsFragmentReq((b) => b
      ..idFields = {
        'id': (itemInfo != null && itemInfo?.id != null)
            ? itemInfo!.id
            : controller.stepFinalarguments.value['listid']
      });
    itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);

    checkBottomLayout();
    if (itemInfo != null) {
      getPublishContent();
    }
    return [
      _showTitleTextWidget().toPad(horizontal: AppDimen.startMargin),
      [
        _showStepOneStatusWidget(),
        _showStepTwoStatusWidget(),
        _showStepThreeStatusWidget(),
      ]
          .toScroll(
              padding: pad(w: AppDimen.startMargin, bottom: 20), physics: AlwaysScrollableScrollPhysics())
          .toStretch(),
      if (_isShowBottomLayout) _showBottomSectionWidget(),
    ].toColumn();
  }

  Widget _showTitleTextWidget() {
    return CustomTitleText(text: become_a_host.tr, size: AppDimen.textSize_22);
  }

  Widget _showStepOneStatusWidget() {
    return stepLayout(
        step: 1,
        title: label_step_one_describe_your_car.tr,
        description: "label_car_features_more".tr,
        icon: Assets.drawableStepFinalOne,
        stepStatus: itemInfo?.listingSteps != null ? itemInfo?.listingSteps?.step1 : 'active',
        callback: () {
          if (itemInfo == null) return;
          StepOneController stepOneController = Get.find();

          stepOneController.choosedIndex.value = 0;
          stepOneController.selectedChipIndex.value = 0;

          GviewListingDetailsFragmentReq fragmentReq =
              GviewListingDetailsFragmentReq((b) => b..idFields = {'id': itemInfo.id});
          itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
          controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepOne, param: {
            'itemInfo': itemInfo,
            'removedeletedlisting': () {
              Get.back(result: {
                'removedeletedlisting': true,
              });
            },
            'refresh': (id) {
              GviewListingDetailsFragmentReq fragmentReq =
                  GviewListingDetailsFragmentReq((b) => b..idFields = {'id': itemInfo.id});
              itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
              Get.forceAppUpdate();
            }
          });
        });
  }

  Widget _showStepTwoStatusWidget() {
    return stepLayout(
        step: 2,
        title: label_step_two_set_the_scene.tr,
        description: label_step_two_photos_short_description_title.tr,
        icon: Assets.drawableStepFinalTwo,
        stepStatus: itemInfo?.listingSteps != null ? itemInfo?.listingSteps?.step2 : '',
        callback: () {
          if (itemInfo == null) return;
          GviewListingDetailsFragmentReq fragmentReq =
              GviewListingDetailsFragmentReq((b) => b..idFields = {'id': itemInfo.id});
          itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
          if (itemInfo != null &&
              itemInfo.listingSteps != null &&
              (itemInfo.listingSteps.step2 != 'inactive')) {
            controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepTwo, param: {
              'itemInfo': itemInfo,
              'removedeletedlisting': () {
                Get.back(result: {
                  'removedeletedlisting': true,
                });
              }
            });
          }
        });
  }

  Widget _showStepThreeStatusWidget() {
    return stepLayout(
        step: 3,
        title: label_step_three_get_ready_for_renters.tr,
        description: "label_booking_calender_price".tr,
        icon: Assets.drawableStepFinalThree,
        stepStatus: itemInfo?.listingSteps != null ? itemInfo?.listingSteps?.step3 : '',
        callback: () {
          if (itemInfo == null) return;
          Get.delete<StepThreeController>();
          Get.lazyPut<StepThreeController>(() => StepThreeController(), fenix: true);
          StepThreeController stepThreeController = Get.find();
          stepThreeController.choosedIndex.value = 0;
          stepThreeController.selectedChipIndex.value = 0;
          GviewListingDetailsFragmentReq fragmentReq =
              GviewListingDetailsFragmentReq((b) => b..idFields = {'id': itemInfo.id});
          itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
          if (itemInfo != null &&
              itemInfo.listingSteps != null &&
              (itemInfo.listingSteps.step3 != 'inactive')) {
            controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepThree, param: {
              'itemInfo': itemInfo,
              'removedeletedlisting': () {
                Get.back(result: {
                  'removedeletedlisting': true,
                });
              },
              'refresh': () {
                if (controller.tabBarItems.isNotEmpty) {
                  controller.selectedlistid = itemInfo.id;
                  controller.removeListing();
                  controller.refreshingTabIndex = 2;
                }
              }
            });
          }
        });
  }

  void _updatelistings() {
    if(Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    HomeController homeController = Get.find();
    homeController.isLoading.value = false;
    if (itemInfo?.listingSteps?.step3 == 'completed') {
      if (!controller.isToRefreshlisting) {
        debugPrint('tabBarItems: ${controller.tabBarItems}');
        if (controller.tabBarItems.isNotEmpty) {
          controller.removeListing();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.update();
          });
        }
      } else if (itemInfo?.listingSteps?.step2 == 'completed' &&
          !(itemInfo?.listPhotoName != null && itemInfo!.listPhotoName.toString().isNotEmpty) &&
          controller.tabController != null &&
          controller.tabController.index != 1 &&
          _removedlistId != controller.selectedlistid) {
        debugPrint(
            "stepLayout: removed  ---${itemInfo?.listingSteps?.step2}---${itemInfo?.listPhotoName} --- ${controller.tabBarItems.length}");
        if (controller.tabBarItems.isNotEmpty) {
          _removedlistId = controller.removeListing();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.update();
          });
          controller.refreshingTabIndex = 1;
        }
      } else if ((itemInfo?.listPhotoName != null &&
              itemInfo!.listPhotoName.toString().isNotEmpty &&
              itemInfo?.listingSteps?.step2 != 'completed') &&
          controller.latetabController.isInitialized &&
          controller.tabController.index == 1 &&
          _removedlistId != controller.selectedlistid) {
        _removedlistId = controller.removeListing();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.update();
        });

        if (itemInfo.isPublished != null && itemInfo.isPublished) {
          controller.refreshingTabIndex = 1;
        } else {
          controller.refreshingTabIndex = 2;
        }
      }
    }

    debugPrint('step final Get.arguments: ${Get.arguments} --- ${itemInfo?.listingSteps}');
    if (Get.arguments != null && Get.arguments['isTabSwitch'] != null && Get.arguments['isTabSwitch']) {
      Future.delayed(const Duration(milliseconds: 350)).then((value) {
        if (itemInfo?.listingSteps?.step3 != 'completed') {
          controller.tabController.index = controller.inprogressTabIndex;
        } else if (itemInfo?.listingSteps?.step3 == 'completed' &&
            (itemInfo?.listPhotoName == null || itemInfo!.listPhotoName.toString().isEmpty)) {
          controller.tabController.index = controller.inprogressTabIndex;
        }
        controller.tabBarItems[controller.tabController.index] = controller
            .tabBarItems[controller.tabController.index]
            .copyWith(tabBarListData: [], isTabLoading: true);
        if (itemInfo?.listingSteps?.step3 != 'completed' ||
            (itemInfo?.listingSteps?.step3 == 'completed' &&
                (itemInfo?.listPhotoName == null || itemInfo!.listPhotoName.toString().isEmpty))) {
          controller.updateInprogressListings(itemInfo.id);
        } else {
          controller.getManageListings();
        }
      });
    } else {
      controller.update();
    }


    debugPrint('controller.tabBarItems: ${controller.tabBarItems.length} ---${controller.tabController}');
    if (controller.tabBarItems.isNotEmpty) {
      controller.tabBarItems[controller.tabController.index] = controller
          .tabBarItems[controller.tabController.index]
          .copyWith(tabBarListData: [], isTabLoading: true);
    }
    Get.back(result: true);
  }

  Widget stepLayout(
      {required int step,
      String? title,
      String? description,
      required String icon,
      String? stepStatus,
      GestureTapCallback? callback}) {
    print("isContainerNeeded ${overALLAppLayoutModel?.borderRadius} -- ${isContainerNeeded} -- ${isCurvedContainer}");
    return [
      CustomText(
        text: '${label_step_final_step.tr} #$step',
      ),
      10.toHeight(),
      [
        if (isContainerNeeded && isCurvedContainer && _isStepButtonVisible(step, stepStatus))
          PositionedDirectional(
            bottom: overALLThemeType != 4 ? 20 : 0,
            end: 0,
            start: 0,
            child: CustomBorderContainer(
              alignment: AlignmentDirectional.center,
              padding: pad(bottom: 0,top: 20),
              height: 70,
              color: appColors.white,
              borderColor: appColors.filterDividerColor,
              borderRadiusGeometry: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0),
                bottomEnd: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0),
              ),
              body: toOnTap(
                onTap: callback,
                child: [
                  if (editIcon != '') ...{
                    editIcon.toSVG(size: 13, colour: appColors.secondaryColor),
                    5.toWidth(),
                  },
                  CustomText(
                    onTap: callback,
                    text: _showEditButton(step, stepStatus) ? label_edit.tr : label_continue.tr,
                    color: appColors.secondaryColor,
                    size: AppDimen.textSize_14,
                  ),
                  if (rightArrow != '') ...{
                    5.toWidth(),
                    rightArrow.toSVG(size: 10, colour: appColors.secondaryColor),
                  }
                ].toRow(mainAxisAlignment: editButtonPlace).toPad(horizontal: 15),
              ),
            ),
          ),
        [
          CustomBorderContainer(
            borderRadius: !isContainerNeeded ? overALLAppLayoutModel?.borderRadius : null,
            borderRadiusGeometry: (overALLThemeType != 1 && overALLThemeType != 2) ? BorderRadiusDirectional.only(
                bottomStart: Radius.circular(isContainerNeeded && !isCurvedContainer
                    ? (_isStepButtonVisible(step, stepStatus) ? 0.0 : overALLAppLayoutModel!.borderRadius)
                    : isContainerNeeded && isCurvedContainer
                        ? overALLAppLayoutModel!.borderRadius
                        : 0),
                bottomEnd: Radius.circular(isContainerNeeded && !isCurvedContainer
                    ? (_isStepButtonVisible(step, stepStatus) ? 0.0 : overALLAppLayoutModel!.borderRadius)
                    : isContainerNeeded && isCurvedContainer
                        ? overALLAppLayoutModel!.borderRadius
                        : 0),
                topStart: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0),
                topEnd: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0)):null,
            color: stepLayoutContainerColor,
            padding: (overALLThemeType == 3 || overALLThemeType == 4) ?pad(top: 15) : pad(h: 15),
            borderColor: stepLayoutBorderColor,
            borderWidth: 1,
            boxShadow: _getBoxShadow(),
            body: [
              [
                [
                  CustomCounterContainer(
                    color: appColors.white,
                    borderWidth: 1,
                    margin: pad(bottom: 0, end: 5),
                    borderColor: stepTitleIconBorderColor,
                    body: icon.toSVG(size: 14, colour: appColors.black).toPad(all: 11)
                  ),
                  if (_showEditButton(step, stepStatus))
                    CustomCounterContainer(
                            color: appColors.secondaryColor,
                            borderWidth: 0,
                            body: Assets.drawableViewdetailReportTick.toSVG(size: 15, fit: BoxFit.scaleDown))
                        .toPositionedAlign(
                      alignment: AlignmentDirectional.bottomEnd,
                    ),
                ].toStack(),
                10.toWidth(),
                (overALLThemeType != 3 && overALLThemeType != 4) ? CustomTitleText(
                  text: '$title',
                  size: AppDimen.textSize_16,
                ).toStretch(isExpanded: false) : const SizedBox.shrink()
              ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: 15),
              12.toHeight(),
              (overALLThemeType == 3 || overALLThemeType == 4) ? CustomTitleText(
                text: '$title',
                size: AppDimen.textSize_16,
              ).toPad(horizontal: 15, bottom: 6) : const SizedBox.shrink(),
              CustomText(
                text: description ?? "",
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ).toPad(horizontal: 15),
              13.toHeight(),
              if (!isContainerNeeded && _isStepButtonVisible(step, stepStatus))
                Divider(height: 1, thickness: 0.5, color: dividerColors)
                    .toPad(bottom: _isStepButtonVisible(step, stepStatus) ? 13 : 0),
              if (_isStepButtonVisible(step, stepStatus) && !isContainerNeeded)
                toOnTap(
                  onTap: callback,
                  child: [
                    if (editIcon != '') ...{
                      editIcon.toSVG(size: 13, colour: appColors.secondaryColor),
                      5.toWidth(),
                    },
                    CustomText(
                      onTap: callback,
                      text: _showEditButton(step, stepStatus) ? label_edit.tr : label_continue.tr,
                      color: appColors.secondaryColor,
                      size: AppDimen.textSize_14,
                    ),
                    if (rightArrow != '') ...{
                      5.toWidth(),
                      rightArrow.toSVG(size: 10, colour: appColors.secondaryColor),
                    }
                  ].toRow(mainAxisAlignment: editButtonPlace).toPad(horizontal: 15),
                ),
            ].toColumn(mainAxisSize: MainAxisSize.min),
          ),
        ].toColumn(mainAxisSize: MainAxisSize.min).toResizeWidget(
            height: isContainerNeeded && isCurvedContainer && _isStepButtonVisible(step, stepStatus)
                ? Get.height * 0.212
                : null),
      ].toStack(),
      if (isContainerNeeded && !isCurvedContainer && _isStepButtonVisible(step, stepStatus))
        CustomBorderContainer(
          borderRadiusGeometry: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0),
            bottomEnd: Radius.circular(isContainerNeeded ? overALLAppLayoutModel!.borderRadius : 0),
          ),
          padding: pad(h: 13),
          color: appColors.myTripsBGColor,
          body: toOnTap(
            onTap: callback,
            child: [
              if (editIcon != '') ...{
                editIcon.toSVG(size: 13, colour: appColors.secondaryColor),
                5.toWidth(),
              },
              CustomText(
                onTap: callback,
                text: _showEditButton(step, stepStatus) ? label_edit.tr : label_continue.tr,
                color: appColors.secondaryColor,
                size: AppDimen.textSize_14,
              ),
              if (rightArrow != '') ...{
                5.toWidth(),
                rightArrow.toSVG(size: 10, colour: appColors.secondaryColor),
              }
            ].toRow(mainAxisAlignment: editButtonPlace).toPad(horizontal: 15),
          ),
        )
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).toPad(top: AppDimen.startMargin - 3);
  }

  Widget _showBottomSectionWidget() {
    return CustomBottomItemShadowContainer(
        padding: pad(w: AppDimen.startMargin, top: 15, bottom: 15),
        body: [
          CustomText(text: publishContent ?? '',),
          10.toHeight(),
          [
            toOnTap(
              onTap: () {
                controller.ownerPropertyListNavigator
                    .navigateScreen(OwnerPropertyListScreen.propertyDetail, param: [itemInfo, "stepfinal"]);
              },
              child: [
                CustomText(
                  text: menuitem_label_preview.tr,
                  size: AppDimen.textSize_14,
                  maxLines: 3,
                  color: appColors.secondaryColor,
                ).toStretch(isExpanded: false),
                isArrowNeededOnPre ? 3.toWidth() : const SizedBox.shrink(),
                isArrowNeededOnPre
                    ? Assets.drawableRightArrow.toSVG(size: 10, colour: appColors.secondaryColor)
                    : const SizedBox.shrink()
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
            ).toResizeWidget(width: (deviceWidth / 2) - 17),
            Spacer(),
            if (publishbtnText != null && publishbtnText!.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: PrimaryButton(
                  onTap: () {
                    if (controller.isLoading.value) return;
                    if (publishbtnText == label_submit_for_verification.tr ||
                        publishbtnText == btn_label_resubmit.tr) {
                      isShowLoader = true;
                      controller.isLoading.value = true;
                      return;
                    }
                    controller.updateStatus = itemInfo.isPublished ? 'unPublish' : 'publish';
                    controller.selectedlistid = itemInfo?.id ?? 1;
                    isShowLoader = true;
                    controller.isLoading.value = true;
                    isListUpdate = !isListUpdate;
                    controller.checkNetwork(controller.managePublishStatus);
                  },
                  buttonText: '$publishbtnText',
                  buttonTextFontSize: AppDimen.textSize_14,
                  customTextAlign: TextAlign.center,
                  padding: pad(w: 20, h: 12),
                ).toResizeWidget(width: (deviceWidth / 2) - 37),
              )
          ]
              .toRow(
                mainAxisSize: MainAxisSize.max,
              )
              .toResizeWidget(width: deviceWidth),
        ].toColumn());
  }

  void checkBottomLayout() {
    _isShowBottomLayout = itemInfo?.listingSteps != null &&
        itemInfo?.listingSteps?.step1 == 'completed' &&
        itemInfo?.listingSteps?.step2 == 'completed' &&
        itemInfo?.listingSteps?.step3 == 'completed' &&
        itemInfo?.listPhotoName != null &&
        itemInfo?.listPhotoName.isNotEmpty;
  }

  Future<Null> onRefresh() async {
    if (itemInfo.isPublished) {
      controller.selectedlistid = (itemInfo != null && itemInfo?.id != null)
          ? itemInfo!.id
          : controller.stepFinalarguments.value['listid'];
      isShowLoader = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.isLoading.value = true;
      });
      controller.checkNetwork(controller.getUpdatedPropertyInfo);
    }
  }

  void getPublishContent() {
    if (itemInfo.isPublished) {
      publishContent = label_your_car_is_published.tr;
      publishbtnText = btn_label_unpublish.tr;
    } else if (!itemInfo.isPublished) {
      publishContent = label_your_car_is_ready.tr;
      publishbtnText = btn_label_publish.tr;
    }
  }


  List<BoxShadow>? _getBoxShadow() {
    return isBoxShadowNeeded
        ? [
            BoxShadow(
              color: appColors.colorCommonLinkColor.withOpacity(0.25),
              offset: Offset(-5, 5),
              blurRadius: 0,
              spreadRadius: -1,
            ),
          ]
        : null;
  }

  bool _showEditButton(int step, String? stepStatus) {
    if (stepStatus != 'completed') return false;
    if (step == 1 || step == 3) return true;
    if (step == 2) {
      return itemInfo?.listPhotoName != null && itemInfo!.listPhotoName.toString().isNotEmpty;
    }
    return false;
  }

  bool _isStepButtonVisible(int step, String? stepStatus) {
    if (stepStatus == null || stepStatus.isEmpty) return false;
    if (stepStatus == 'inactive') return false;
    return true;
  }
}