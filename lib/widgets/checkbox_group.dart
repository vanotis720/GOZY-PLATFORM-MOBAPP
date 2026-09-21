import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_animated_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_animated_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_showmore_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';

import 'custom_list_item.dart';
// https://pub.dartlang.org/packages/grouped_buttons

class ListingsFeaturesGroup extends CustomStatefulWidget {
  final List<dynamic>? labels;
  ReactiveVariable?  onSelected;
  bool? isShowNetworkIcon;
  bool? isTopPadNeeded;
  double? topPadding;
  bool? isShowDivider;
  bool isRemoveShowLessAndMore;
  BaseController controller;
  int showLessFilterItemCount;
  double iconSize;
  double? fontSize;
  Color? checkListItemColor;
  bool isSingleCheck;
  bool isFromFilter;
  double borderRadius;
  double bottomSpacing;

  ListingsFeaturesGroup({
    super.key,
    required this.labels,
    required this.controller,
    required this.showLessFilterItemCount,
     this.onSelected,
    this.topPadding,
     this.checkListItemColor,
    this.isShowNetworkIcon = true,
    this.isTopPadNeeded = true,
    this.isFromFilter = false,
    this.isShowDivider = false,
    this.isRemoveShowLessAndMore = false,
    this.iconSize = 20,
    this.fontSize,
    this.isSingleCheck= false,
    this.borderRadius = 8,
    this.bottomSpacing = 0
  });
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}
class _StatefulWrapperState extends CustomStatefulWidgetState<ListingsFeaturesGroup> with TickerProviderStateMixin,AutomaticKeepAliveClientMixin {
  final RxBool _isShowless = true.obs;
  final RxInt _isShownIndex = 0.obs;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late int shownCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _isShownIndex.value = widget.showLessFilterItemCount-1;
    shownCount = (widget.showLessFilterItemCount <= widget.labels!.length) ? widget.showLessFilterItemCount : widget.labels!.length;
    if(widget.isRemoveShowLessAndMore) shownCount =   widget.labels!.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return [
      AnimatedList(
        shrinkWrap: true,
        key: _listKey,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        initialItemCount: shownCount,
        itemBuilder: (context, index, animation) {
          return Obx(() =>
            Opacity(
            opacity: _isShownIndex.value >= index || ( index <shownCount) ? 1:0,
            child: SizeTransition(
              sizeFactor: animation,
              child: _getCheckboxItems(index, shownCount, bottomSpacing: widget.bottomSpacing),
            ),
          ),
          );
        },
      ),

      if(shownCount < widget.labels!.length && !widget.isRemoveShowLessAndMore )
        Obx(() => CustomContainer(
          margin: pad(top: 10),
          alignment: AlignmentDirectional.centerStart,
          onTap: ()async{
            if(_isShowless.value) {
              for (int offset = shownCount-1; offset < widget.labels!.length-1; offset++) {
               await Future.delayed(const Duration(milliseconds: 0));
                _isShownIndex.value = (shownCount-1) + offset;
                debugPrint("_isShownIndex: ${_isShownIndex.value}");
                _listKey.currentState!.insertItem((showLessFilterItemCount-1) + offset, duration: const Duration(milliseconds: 0));
              }
            } else {
              for (int i = widget.labels!.length-1; i > shownCount-1; i--) {
                Widget builder(BuildContext context, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: _getCheckboxItems(i, shownCount, bottomSpacing: widget.bottomSpacing),
                  );
                }
                _listKey.currentState!.removeItem((shownCount), builder , duration: const Duration(milliseconds: 0));
              }
            }
            _isShowless.value = !_isShowless.value;
            _isShownIndex.value = _isShowless.value ? (shownCount - 1) : (widget.labels!.length - 1);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.controller.update();
            });
          },
          body: CustomShowMoreText(
            text:_isShowless.value ? label_show_more.tr : label_show_less.tr,
            fontWeight: AppFont.regular,
            size:  AppDimen.textSize_14,
            color: appColors.secondaryColor,
            showMoreIconTopPadding: 3,
            quarterTurns: _isShowless.value ? 3 :1,
          )
        ),
      ),

    ].toColumn(
        mainAxisSize: MainAxisSize.min
    );
  }

  void onChanged( int i) {
    bool isAlreadyContained = widget.onSelected!.value.contains(getcheckboxMap(index:i)!['id']);
   if(!widget.isSingleCheck) {
      if (!isAlreadyContained) {
        widget.onSelected!.value.add(getcheckboxMap(index:i)!['id']);
        widget.controller.change(rxVariable: widget.onSelected!, value: widget.onSelected!.value);
      }else{
        widget.onSelected!.value.remove(getcheckboxMap(index:i)!['id']);
        widget.controller.change(rxVariable: widget.onSelected!, value: widget.onSelected!.value);
      }
   }else{
      var currentId = getcheckboxMap(index:i)!['id'];
     if(widget.onSelected!.value.isEmpty){
       widget.onSelected!.value.add(currentId);
       widget.controller.change(rxVariable: widget.onSelected!, value: widget.onSelected!.value);
     }else{
       bool isSwitching = !widget.onSelected!.value.contains(currentId);
       widget.onSelected!.value.clear();
       if(isSwitching) {
         widget.onSelected!.value.add(currentId);
       } else {
         widget.onSelected!.value.add(0);
       }
       widget.controller.change(rxVariable: widget.onSelected!, value: widget.onSelected!.value);
     }
   }
    WidgetsFlutterBinding.ensureInitialized().performReassemble();
    debugPrint("onChanged --onSelected: ${widget.onSelected!.value}");
  }

  Widget _getCheckboxItems(int i, int length, {double? bottomSpacing}) {

    bool isSelected = widget.onSelected!.value.contains(getcheckboxMap(index:i)!['id']);
    Widget cbFilteritem = GetBuilder(
      init: widget.controller,
      id: widget.onSelected!.id,
      builder: (context) {
        isSelected = widget.onSelected!.value.contains(getcheckboxMap(index:i)!['id']);
        return !widget.isSingleCheck ? CustomBorderContainer(
            width: 22,
            height: 22,
            borderRadius: 4,
            borderWidth: 1,
            borderColor: isSelected
                ? appColors.secondaryColor
                : (widget.isFromFilter ? appColors.customBorderColor : appColors.secondaryColor),
            color: isSelected
                ? appColors.secondaryColor
                : Colors.transparent,
            padding: pad(a: 4),
            onTap: () => onChanged(i),
            body: isSelected
                ? Assets.drawableViewdetailReportTick.toSVG(colour: Colors.white)
                : null,
          ).toPad(end: 10) :
          CustomCheckBoxTransactionHistroy(ischeckCondition: !isSelected,
              borderColor: appColors.customBorderColor,
              shape: BoxShape.circle,
              isNeedTopMargin: false,
              unCheckFillColor: Colors.transparent).toPad(top: 4, start: 4, bottom: 4);
      }
    );

    String? itemPropertyText = getcheckboxMap(index:i)!['itemName'];
    print("widget.isRemoveShowLessAndMore${widget.isRemoveShowLessAndMore}");
    return  CustomContainer(
      padding: pad(top: !(widget.isTopPadNeeded!) ? 0 : 15, bottom: bottomSpacing ?? 0),
      color: Colors.transparent,
      onTap: (){
        onChanged(i);
      },
      body: [
        CustomCheckBoxListItem(
        checkBox: cbFilteritem,
          topPadding: widget.topPadding ?? 1.5,
          iconWidget:
          (widget.isShowNetworkIcon ?? true) ?
            '$imgAmenities${getcheckboxMap(index:i)!['image']}'.toNetworkIconImg(size: widget.iconSize, controller:  widget.controller).toPad(end: 4)
              : null,
        itemPropertyText: itemPropertyText ?? '',
          color: widget.checkListItemColor,
      ),
       // (widget.labels!.length-1) != i && !widget.isRemoveShowLessAndMore ? 15.toHeight() : (widget.labels!.length > widget.showLessFilterItemCount + 1) ? 0.toHeight() : 0.toHeight(),
        if((widget.isShowDivider ?? false) && (widget.labels!.length-1) != i) filterDivider,

     ].toColumn(mainAxisSize: MainAxisSize.min)
    );
  }

  Map<String,dynamic>? getcheckboxMap({required int index}){
    if(widget.labels!.elementAt(index) is Map<String,dynamic>) {
      return widget.labels!.elementAt(index);
    } else {
      return widget.labels!.elementAt(index).toJson();
    }
  }
}

Widget CustomCheckBoxTransactionHistroy({required bool ischeckCondition,bool isNeedEndPadding = true, bool isNeedTopMargin = true, Color? borderColor,Color? unCheckFillColor, Color? staticCheckColor, String? checkIcon, BoxShape? shape}){
  return
    (borderColor !=null ?
    CustomBorderContainer(
      width: 20,
      height: 20,
      margin: pad(top: isNeedTopMargin ? 5 : 0),
      padding: pad(a: 4),
      shape: shape,
      borderWidth: 1,
      borderColor: ischeckCondition ? borderColor : staticCheckColor ??  appColors.secondaryColor,
      color: ischeckCondition ?  (unCheckFillColor ?? appColors.viewdetailReportIconColor) : (staticCheckColor ??  appColors.secondaryColor),
      body: ischeckCondition ? null :(checkIcon ??Assets.drawableViewdetailReportTick).toSVG(colour: AppColors.staticwhite),
    ) :
    CustomWishlistContainer(
      width: 20,
      height: 20,
      margin: pad(top: isNeedTopMargin ? 5 : 0),
      padding: pad(a: 5),
      color: ischeckCondition ?  (borderColor !=null ? appColors.white :appColors.viewdetailReportIconColor) : (staticCheckColor ??  appColors.secondaryColor),
      body: ischeckCondition ? null :(checkIcon ??Assets.drawableViewdetailReportTick).toSVG(colour: AppColors.staticwhite),
    )).toPad(end:isNeedEndPadding ? 10 : 0);
}



Widget CustomCheckBox(
    {required bool ischeckCondition,
      bool isNeedEndPadding = true,
      bool isNeedTopMargin = true,
      Color? borderColor,
      Color? staticCheckColor,
      Color? unselectCheckBoxColor,
      String? checkIcon, BoxShape? boxshape}) {
  if (overALLThemeType == 4 || overALLThemeType == 3 || overALLThemeType == 2) {
    return CustomBorderContainer(
      width: 22,
      height: 22,
      shape: boxshape ?? BoxShape.rectangle,
      margin: pad(top: isNeedTopMargin ? 5 : 0),
      padding: pad(a: ischeckCondition ? 0 : 4.5),
      borderColor: ischeckCondition
          ? (borderColor ?? appColors.myTripsDividerColor)
          : (borderColor ?? appColors.secondaryColor),
      borderRadius: (boxshape == BoxShape.rectangle) ? 5 : 11,
      borderWidth: ischeckCondition ? 1 : 0.5,
      color: ischeckCondition
          ? (borderColor != null ? unselectCheckBoxColor ?? appColors.white : Colors.transparent)
          : (staticCheckColor ?? appColors.secondaryColor),
      body: ischeckCondition
          ? null
          : (checkIcon ?? Assets.drawableViewdetailReportTick)
          .toSVG(colour: AppColors.staticwhite),
    ).toPad(end: isNeedEndPadding ? 18 : 0);
  } else {
    return (borderColor != null
        ? CustomBorderContainer(
      width: 22,
      height: 22,
      margin: pad(top: isNeedTopMargin ? 5 : 0),
      padding: pad(a: 4),
      borderColor: borderColor,
      borderWidth: ischeckCondition ? null ?? 1:0.5,
      borderRadius: (boxshape == BoxShape.rectangle) ? 5 : 11,
      shape: boxshape ?? BoxShape.rectangle,
      color: ischeckCondition
          ? (borderColor != null
          ? unselectCheckBoxColor ?? appColors.white
          : appColors.viewdetailReportIconColor)
          : (staticCheckColor ?? appColors.secondaryColor),
      body: ischeckCondition
          ? null
          : (checkIcon ?? Assets.drawableViewdetailReportTick)
          .toSVG(colour: AppColors.staticwhite),
    )
        : CustomWishlistContainer(
      width: 20,
      height: 20,
      margin: pad(top: isNeedTopMargin ? 5 : 0),
      padding: pad(a: 5),
      color: ischeckCondition
          ? (borderColor != null
          ? unselectCheckBoxColor ?? appColors.white
          : appColors.viewdetailReportIconColor)
          : (staticCheckColor ?? appColors.secondaryColor),
      body: ischeckCondition
          ? null
          : (checkIcon ?? Assets.drawableViewdetailReportTick)
          .toSVG(colour: AppColors.staticwhite),
    ))
        .toPad(end: isNeedEndPadding ? 18 : 0);
  }
}


Widget getAnimatedRadioBox({
  required isSelected,
  duration = const Duration(milliseconds: 0),
  size = 24.0,
  selectedColor,
  unselectedColor = Colors.grey,
}){
  selectedColor ??= appColors.secondaryColor;
  return CustomBorderAnimatedContainer(
   width: size,
    height: size,
    duration:duration,
    padding: pad(a:3),
    borderRadius: size*2,
    borderWidth: 1,
    borderColor: isSelected ?selectedColor :unselectedColor,
    color: Colors.transparent,
    alignment: Alignment.center,
    body: CustomWishlistAnimatedContainer(
      duration:duration,
      width:isSelected ?size * 0.5 : 0,
      height:isSelected ?size * 0.5 : 0,
      color:selectedColor,
    ),
  );
}