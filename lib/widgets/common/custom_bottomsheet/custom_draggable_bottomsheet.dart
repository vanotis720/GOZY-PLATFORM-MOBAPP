import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/anim_search_bar.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';
import 'package:gozy/widgets/widget_size.dart';


class getDraggableSheetWidget extends CustomStatefulWidget {
  final BaseController controller;
  final List<dynamic>? listItems;
  final String? title;
  final Function? getListItemsFunction;
    int? themeType;
   List<Widget>? widgetsList;
  final Function? paginationFunction;
  final int? selectedId;
  final RxInt? currentPage;
  final double? borderRadius;
  final String? selectedValue;
  final dynamic selectedModel;
  final bool? toHideDivider;
  final bool? toShowIcon;
  final int? overALLCount;
  final bool? isAppImage;
  final String? fontFamily;
  final bool? isMaterialLocalization;
  final ValueChanged<dynamic>? onItemSelected;
  final CustomTextEditingController? textEditingController;
  final bool? isShowCloseIcon;
  final bool? isShowCircleTick;
    RxInt? searchBarStatus;
  final RxBool? isLinearLoading;
  final CustomTextEditingController? searchEditController;
  final bool isSearchHeaderRefinementEnabled;
  final bool isWidgetListScrollable;
  final bool showNoResultFound;

  getDraggableSheetWidget({
    super.key,
    required this.controller,
    this.listItems,
    this.title,
    this.getListItemsFunction,
    this.themeType,
    this.widgetsList,
    this.paginationFunction,
    this.selectedId,
    this.currentPage,
    this.borderRadius,
    this.selectedValue,
    this.selectedModel,
    this.toHideDivider,
    this.toShowIcon,
    this.isSearchHeaderRefinementEnabled = false,
    this.overALLCount,
    this.isAppImage,
    this.fontFamily,
    this.isMaterialLocalization,
    this.onItemSelected,
    this.textEditingController,
    this.isShowCloseIcon,
    this.isShowCircleTick,
    this.searchBarStatus,
    this.isLinearLoading,
      this.searchEditController,
    this.isWidgetListScrollable = false,
    this.showNoResultFound = false,
  });

  @override
  CustomStatefulWidgetState<getDraggableSheetWidget> createState() => _getDraggableSheetWidgetState();
}

class _getDraggableSheetWidgetState extends CustomStatefulWidgetState<getDraggableSheetWidget> {
  late DraggableScrollableController draggableScrollableController;
  RxDouble draggableMaxSize = 1.0.obs;
  RxDouble currentDraggableSize = 0.0.obs;
  double? _initialSheetSize;

  @override
  void initState() {
    super.initState();
    draggableScrollableController = DraggableScrollableController();
    widget.searchBarStatus ??= 0.obs;
    draggableScrollableController.addListener(_onDraggableChanged);
  }

  void _onDraggableChanged() {
    debugPrint("draggableScrollableController.size: ${widget.searchEditController}");
    if (draggableScrollableController.size == 1.0) {
      currentDraggableSize.value = 1.0;
      // Restore search bar open state if there's active search text
      if (widget.searchEditController != null &&
          widget.searchEditController!.text.isNotEmpty &&
          (widget.searchBarStatus?.value ?? 0) == 0) {
        widget.searchBarStatus?.value = 1;
      }
    } else {
      currentDraggableSize.value = 0.0;
    }
  }

  @override
  void dispose() {
    draggableScrollableController.removeListener(_onDraggableChanged);
    draggableScrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.searchBarStatus ??= 0.obs;

    debugPrint("widget.listItems: ${widget.listItems}");
    return SafeArea(
      bottom: Platform.isAndroid,
      child: GetBuilder<BottomSheetController>(
          builder: (newController) {
            widget.themeType ??= overALLThemeType;
      
            String? dividerType;
            Color? titleBGColor;
            switch (widget.themeType) {
          case 1:
            break;
          case 2:
            dividerType = 'line';
            break;
          case 3:
            dividerType = 'line';
            titleBGColor = appColors.myTripsBGColor;
            break;
          case 4:
            dividerType = 'dot';
            titleBGColor = appColors.theme4AppBarBg;
        }

        var listitemswithWidgets = _generateListWidget(controller: widget.controller,
                onItemSelected: widget.onItemSelected,
                listItems: widget.listItems,
                getListItemsFunction: widget.getListItemsFunction,
                selectedId: widget.selectedId,
                dividerType: dividerType,
                selectedValue: widget.selectedValue,
                selectedModel: widget.selectedModel,
                toHideDivider: widget.toHideDivider,
                toShowIcon: widget.toShowIcon,
                isAppImage: widget.isAppImage,
                fontFamily: widget.fontFamily,
                isMaterialLocalization: widget.isMaterialLocalization,
                textEditingController: widget.textEditingController,
                isShowCircleTick: widget.isShowCircleTick
            );
            widget.widgetsList = widget.widgetsList ?? listitemswithWidgets.$2;
      
            if ((listitemswithWidgets.$1.length * 35) > (deviceHeight - 60)) {
              if (draggableMaxSize.value != 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) draggableMaxSize.value = 1;
                });
              }
            }
      
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: GestureDetector(
                onTap: () {},
                child:
                Obx(() {
                  double initialSize = draggableMaxSize.value < 0.5
                      ? draggableMaxSize.value
                      : 0.5;
                  double minSize = draggableMaxSize.value == 1
                      ? 0.48
                      : draggableMaxSize.value / 2;
                      
                  if (draggableScrollableController.isAttached) {
                    initialSize = draggableScrollableController.size.clamp(minSize, draggableMaxSize.value);
                  }
                  
                  debugPrint("draggableminsize: ${minSize} --- ${initialSize}");
                  return DraggableScrollableSheet(
                    initialChildSize: _initialSheetSize ?? initialSize,
                    minChildSize: minSize,
                    maxChildSize: draggableMaxSize.value,
                    controller: draggableScrollableController,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Obx(() {
                        if (draggableScrollableController.isAttached) {
                          debugPrint(
                              "drag size: ${draggableScrollableController.size} --- ${scrollController.position
                                  .pixels}");
                          _initialSheetSize = draggableScrollableController.size;
                          // Search reset is handled in _onDraggableChanged
                        }

                        debugPrint("animsearchbar: ${widget.title}");
                        return CustomBorderContainer(
                            padding: pad(top: currentDraggableSize.value >= 1.0 ? topViewPadding + 5 : 10,),
                            color: titleBGColor ?? appColors.white,
                            borderRadiusGeometry: widget.borderRadius !=null &&  widget.borderRadius!>0 ?
                            BorderRadiusDirectional.only(
                              topStart: Radius.circular(widget.borderRadius! ),
                              topEnd: Radius.circular(widget.borderRadius!),
                            ) : null,
      
                            body: [
                              (widget.title != null) ?
                              CustomBorderContainer(
                                  color: titleBGColor ?? appColors.white,
                                  borderRadiusGeometry: widget.borderRadius !=null &&  widget.borderRadius!>0 ?
                                  BorderRadiusDirectional.only(
                                    topStart: Radius.circular(widget.borderRadius!),
                                    topEnd: Radius.circular(widget.borderRadius!),
                                  ) : null,
                                  body: [
                                    Obx(() {
                                      // Observe reactive values for proper rebuilds
                                      bool isAtTop = currentDraggableSize.value == 1.0;
                                      bool hasSearchText = widget.searchEditController?.text.isNotEmpty ?? false;
                                      bool isSearching = isAtTop && ((widget.searchBarStatus?.value ?? 0) != 0 || hasSearchText);
                                      return [
                                        Stack(
                                          alignment: AlignmentDirectional.centerStart,
                                          children: [
                                            // Title (fades out when searching)
                                            AnimatedOpacity(
                                              opacity: isSearching ? 0.0 : 1.0,
                                              duration: const Duration(milliseconds: 200),
                                              child: IgnorePointer(
                                                ignoring: isSearching,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: CustomText(
                                                    text: widget.title!,
                                                    size: AppDimen.textSize_18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Search Bar (only when sheet is at the top)
                                            if (widget.searchEditController != null && isAtTop)
                                              Align(
                                                alignment: AlignmentDirectional.centerEnd,
                                                child: AnimSearchBar(
                                                  width: deviceWidth - (AppDimen.startMargin * 2),
                                                  themeType: widget.themeType ?? 1,
                                                  searchBarStatus: widget.searchBarStatus,
                                                  textController: widget.searchEditController!,
                                                ),
                                              ),
                                          ],
                                        ).toStretch(),
                                        // Close icon (always visible when search is closed)
                                        if (!isSearching)
                                          Assets.drawableSignupClose.toSVG(
                                            colour: appColors.black,
                                            size: 15,
                                            clickableSize: 20,
                                            imageAlignment: AlignmentDirectional.centerEnd,
                                            onTap: () {
                                              if(Get.currentRoute != "/StepOnePage") {
                                                widget.textEditingController?.text = '';
                                              }
                                              Get.back();
                                            },
                                          ).toPad(start: 10),
                                      ].toRow(crossAxisAlignment: CrossAxisAlignment.center);
                                    }).toPad(top: 10, horizontal: AppDimen.startMargin),
                                      if(widget.isLinearLoading != null)
                                        getLinearProgress(isShowLoad: widget.isLinearLoading!),
                                      20.toHeight()
                                  ].toColumn()
                              ) : (widget.isShowCloseIcon ?? true) ?
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: toOnTap(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Assets.drawableSignupClose
                                        .toSVG(colour: appColors.black, size: 14)
                                        .toPad(top: 10, bottom: 15, end: AppDimen.startMargin)
                                ),
                              ) : 0.toHeight(),
                              if(titleBGColor == null)
                                filterDivider,
                              ColoredBox(
                                  color: appColors.white,
                                  child: widget.searchEditController == null ?
                                  ((listitemswithWidgets.$1.length * 35)) > (deviceHeight - 50) ?
                                  widget.widgetsList!.toScroll(scrollController: scrollController)
                                      : SingleChildScrollView(
                                      controller: scrollController,
                                      child: MeasureSize(
                                          onChange: (size) {
                                            double boxHeight = size.height + 24 + 60;
                                            double screenHeight = deviceHeight;
                                            double ratio = boxHeight / screenHeight;
                                            draggableMaxSize.value = ratio > 1 ? 1 : ratio;
                                          },
                                          child: widget.widgetsList!.toColumn())
                                  ) : GetBuilder<BottomSheetController>(
                                      id: newController.isUpdateItemList.id,
                                      builder: (snapshot) {
                                        (List<dynamic>, List<Widget>) updatedlistitemswithWidgets = listitemswithWidgets;
                                        bool isSearching = widget.searchEditController != null && widget.searchEditController!.Ttext.isNotEmpty;
                                        debugPrint(
                                            "isSearching: ${isSearching} --- ${newController.isUpdateItemList.value} --- ${widget.isSearchHeaderRefinementEnabled}");
                                        if (newController.isUpdateItemList.value || (widget.isSearchHeaderRefinementEnabled && isSearching)) {
                                          updatedlistitemswithWidgets = _generateListWidget(
                                              controller: widget.controller,
                                              onItemSelected: widget.onItemSelected,
                                              listItems: widget.listItems,
                                              getListItemsFunction: widget.getListItemsFunction,
                                              selectedId: widget.selectedId,
                                              selectedValue: widget.selectedValue,
                                              dividerType: dividerType,
                                              toHideDivider: widget.toHideDivider,
                                              toShowIcon: widget.toShowIcon,
                                              selectedModel: widget.selectedModel,
                                              isAppImage: widget.isAppImage,
                                              fontFamily: widget.fontFamily,
                                              isMaterialLocalization: widget.isMaterialLocalization,
                                              textEditingController: widget.textEditingController,
                                              isShowCircleTick: widget.isShowCircleTick
                                          );
                                        }
                                        debugPrint(
                                            "updatedlistitemswithWidgets: ${updatedlistitemswithWidgets.$1
                                                .length * 35} --- ${deviceHeight -
                                                50} --- ${listitemswithWidgets.$1.length * 35}");
                                        return updatedlistitemswithWidgets.$1.length <= 0.0 ?
                                        (widget.isLinearLoading != null && !widget.showNoResultFound) ?
                                       const SizedBox.shrink() :
                                        Center(
                                            child: CustomText(text: empty_label_no_results_found.tr,
                                              size: AppDimen.textSize_18,
                                              color: appColors.placeholderColor,)) :
      
                                        ConditionalParentWidget(
                                            condition: widget.currentPage != null && widget.overALLCount != null &&
                                                widget.overALLCount! > updatedlistitemswithWidgets.$1.length,
                                            parentBuilder: (Widget child) {
                                              return toReviewList(
                                                reviewListScrollController: scrollController,
                                                reviewList: updatedlistitemswithWidgets.$1,
                                                reviewsCount: widget.overALLCount,
                                                onApiFunction: widget.paginationFunction,
                                                controller: widget.controller,
                                                currentPage: widget.currentPage,
                                                isDisableLoader: false,
                                                isEnableListener: false,
                                                isEnableSwipeToRefresh: false,
                                                emptyWidget: const SizedBox.shrink(),
                                                listView: child,
                                              );
                                            },
                                            child:
                                            ((updatedlistitemswithWidgets.$1.length * 35) > (deviceHeight - 50) || !newController.isUpdateItemList.value) ?
                                            updatedlistitemswithWidgets.$2.toScroll(scrollController: scrollController)
                                                :
                                            MeasureSize(
                                                onChange: (size) {
                                                  if (widget.searchEditController !=null && widget.searchEditController!.Ttext.isNotEmpty) {
                                                    return;
                                                  }
                                                  double boxHeight = size.height + 24 + 80;
                                                  double screenHeight = deviceHeight;
                                                  double ratio = boxHeight / screenHeight;
                                                  draggableMaxSize.value = ratio > 1 ? 1 : ratio;
                                                },
                                                child: updatedlistitemswithWidgets.$2.toColumn()).toScroll(controller: scrollController)
                                        );
                                      }
                                  )
                              ).toStretch(),
                            ].toColumn()
                        );
                      }
                      );
                    },
                  );
                }
                ),
              ),
            );
          }),
    );
  }

  (List<dynamic>, List<Widget>) _generateListWidget({
    required BaseController controller,
    ValueChanged<dynamic>? onItemSelected,
    List<dynamic>? listItems,
    Function? getListItemsFunction,
    int? selectedId,
    String? selectedValue,
    String? dividerType,
    dynamic selectedModel,
    bool? toHideDivider,
    bool? toShowIcon,
    bool? isAppImage,
    String? fontFamily,
    bool? isMaterialLocalization,
    CustomTextEditingController? textEditingController,
    bool? isShowCircleTick,
  }) {
    if (getListItemsFunction != null) {
      listItems = getListItemsFunction();
    }
    List<dynamic> templist = [];
    List<Widget> WidgetsList = [];
    debugPrint("_generateListWidgetlistItems: ${listItems?.length}");
    // Detect if a search is active — suppress selection reorder during search
    final bool isSearchActive = widget.searchEditController?.Ttext.isNotEmpty ?? false;
    if (listItems != null) {
      templist = List.from(listItems);
      if (!isSearchActive && (selectedId != null || selectedValue != null) && listItems.isNotEmpty) {
        templist = [...listItems];
        int currentIndex = 0;
        if (selectedId != null) {
          currentIndex = listItems.indexWhere((item) => item.id == selectedId);
        } else if (selectedValue != null) {
          for (var item in listItems) {
            debugPrint('item.itemValue: ${item.itemValue} ---$selectedValue');
          }
          currentIndex = listItems.indexWhere((item) => item.itemValue == selectedValue);
        }
        debugPrint("listitemscurrentIndex: $currentIndex");
        if (currentIndex >= 0) {
          dynamic item = templist.removeAt(currentIndex);
          if (selectedModel != null) templist.remove(selectedModel);
          templist.insert(0, item);
        } else if (selectedModel != null) {
          templist.insert(0, selectedModel);
        } else {
          selectedId = null;
          selectedValue = null;
        }
      }
      debugPrint("templist: ${templist.length} --- ${widget.searchEditController} --- ${getListItemsFunction}");
      if(templist.isEmpty && widget.searchEditController!=null && widget.searchEditController!.Ttext.isEmpty && getListItemsFunction != null){
        templist = getListItemsFunction();
      }
      WidgetsList = List.generate(templist.length, (index) {
        return GetBuilder<BottomSheetController>(
            builder: (newController) {
              debugPrint("istoselect color: ${appColors.black} --- ${appColors.white}");
              bool isToSelect = !isSearchActive && (index == 0 &&
                  (selectedId != null || selectedValue != null));
              Widget customText = CustomText(
                text: controller.getLocalizedItemName(templist[index]),
                font: fontFamily,
                color: isToSelect ? appColors.secondaryColor : appColors.textColor,
                textAlign: controller.isRTL() ? TextAlign.end : TextAlign.start,
                textDirection: TextDirection.ltr,
                size: AppDimen.textSize_16,
                fontWeight: isToSelect ? AppFont.medium : AppFont.regular,
              );
              if (isMaterialLocalization != null && isMaterialLocalization) {
                customText = customText.toMaterialLocalization();
              }
              return toOnTap(
                onTap: () {
                  if (textEditingController != null) {
                    textEditingController.text = templist[index]?.itemName ?? '';
                  }
                  if (onItemSelected != null) onItemSelected(templist[index]);
                  if (templist[index].toJson().containsKey('id')) {
                    selectedId = templist[index]!.id;
                  }
                  if (templist[index].toJson().containsKey('itemValue')) {
                    selectedValue = templist[index]!.itemValue;
                  }
                  onBack();
                  controller.isLoading.refresh();
                },
                child: [
                  15.toHeight(),
                  [
                    if(toShowIcon ?? false)
                      '$imgAmenities${templist[index]?.image}'
                          .toNetworkIconImg(
                          controller: controller,
                          size: 18,
                          isUpdateImage: true).toPad(end: 10),
                    if((isAppImage ?? false) && templist[index]?.image != null)
                      (templist[index]?.image.toString().toSVG(
                          size: 20, colour: isToSelect
                          ? appColors.secondaryColor
                          : appColors.black) as Widget).toPad(end: 15),
                    customText.toStretch(),
                    if(isToSelect)
                      (isShowCircleTick ?? false) ? Assets.drawableViewdetailReportTick.toSVG(
                          size: 8,
                          colour: AppColors.staticwhite
                      ).toCircle(
                        color: appColors.secondaryColor,
                        padding: 4,
                        borderColor: appColors.secondaryColor,
                      ) :
                      Assets.drawableViewdetailReportTick.toSVG(
                          size: 10,
                          colour: appColors.secondaryColor
                      ).toPad(start: 8)
                   ].toRow().toPad(start: AppDimen.startMargin,
                       end: (isShowCircleTick ?? false) ? AppDimen.startMargin - 14 : AppDimen.startMargin),
                  if(index != (templist.length - 1))
                  15.toHeight(),
                   if(index < templist.length - 1 && !(toHideDivider ?? false))
                     if(dividerType == 'line')
                       filterDivider
                    else
                      if(dividerType == 'dot')
                        fullWidthDashDivider().toPad(horizontal: AppDimen.startMargin),
                ].toColumn().toResizeWidget(color: appColors.white),
              );
            });
      });
      WidgetsList.add(20.toHeight());
    }
    return (templist, WidgetsList);
  }
}