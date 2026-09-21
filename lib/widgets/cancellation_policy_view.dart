import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../constant.dart';
import 'bottom_sheet/bottom_sheet_refresh_controller.dart';

class CancellationPolicyView extends GetView{

dynamic cancellation;
@override
  BaseController controller;
bool? isShowDot;
bool? isShowIcon;
String? icon;
bool ? isShowContainerForSearchText;
Color? containerColor;
bool ? isRemoveDivider;

CancellationPolicyView({super.key,
    required this.cancellation,
    required this.controller,
    this.isShowContainerForSearchText,
    this.containerColor,
    this.isShowDot,
    this.isShowIcon,
    this.isRemoveDivider,
    this.icon
  });



@override
Widget build(BuildContext context) {
  String title = '${label_cancellation_policy_is.tr} \'${cancellation.policyName}\' ${"label_cancellation_and_you_can".tr} ${cancellation.policyContent.toString().toLowerCase()}';
  String subTitle1 = '${cancellation.subTitle.toString().split('\n')[0]}';
  String subTitle2 = '${cancellation.subTitle.toString().split('\n')[1]}';
  String content1 = '$subTitle1\n\n$subTitle2';
  String searchWordForContent1 = _getSearchText(content1);
  String contentbeforedays = '${cancellation.content1}';
  String searchWordForcontentbeforedays = _getSearchText(contentbeforedays);
  String content2 = '${cancellation.content2}';
  String searchWordForContent2 = _getSearchText(content2);
  String content3 = '${cancellation.content3}';
  String searchWordForContent3 = _getSearchText(content3);
  debugPrint('cancellation.subContent --> ${cancellation.subContent.toString().split('\n').length}');
  return GetBuilder<BottomSheetController>(
      builder: (newController)=>
    ColoredBox(
    color: appColors.white,
    child: [
      showSearchableSpanWidget(primary:title,search: cancellation.policyName, highlightColor: appColors.customTextColor, searchTextFontWeight: AppFont.bold),
      10.toHeight(),
      overALLThemeType == 4
          ? filterDivider.toFitToDeviceWidth().toResizeWidget(height: 1)
          : filterDivider,
      10.toHeight(),
      showTitleDescWidget(title: cancellation.policyName, widget:showSearchableSpanWidget(primary:content1,search: searchWordForContent1, highlightColor: appColors.black, containerColor: containerColor), isShowDivider: isRemoveDivider),
      10.toHeight(),
      showTitleDescWidget(title: '${label_before.tr} ${cancellation.priorDays} ${label_day.trPlural(dayPlural.tr,int.parse(cancellation.priorDays.toString()))} :', widget:showSearchableSpanWidget(primary:contentbeforedays,search: searchWordForcontentbeforedays, isShowContainerForSearchText: isShowContainerForSearchText, containerColor: containerColor), isShowDivider: isRemoveDivider),
      10.toHeight(),
      showTitleDescWidget(title: '${label_check_in.tr} :', widget:showSearchableSpanWidget(primary:content2,search: searchWordForContent2, isShowContainerForSearchText: isShowContainerForSearchText, containerColor: containerColor), isShowDivider: isRemoveDivider),
      10.toHeight(),
      showTitleDescWidget(title: '${label_check_out.tr} :', widget:showSearchableSpanWidget(primary:content3,search: searchWordForContent3, isShowContainerForSearchText: isShowContainerForSearchText, containerColor: containerColor)),
      10.toHeight(),
      showTitleDescWidget(title: '${label_note.tr} :', widget: showSubContentData(), isShowDivider: false),
    ].toScroll(
      padding: pad(w: AppDimen.startMargin)
    ),
  ));
}

Widget showSubContentData() {
  return toListView(
    shrinkWrap: true,
      key:  const PageStorageKey<String>('cancelaationpolicy'),
    itemCount: cancellation.subContent.toString().split('\n').length,
    itemBuilder: (context, index) {
      return [
        if(isShowDot ?? false)
          CustomContainer(
            margin: EdgeInsetsDirectional.only(end: 6, top: 8),
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.customTextColor,
            ),
          ),
        if((isShowIcon ?? false) && icon != null)
          icon!.toSVG(quarterTurns: intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ? 2 : 4, colour: appColors.black).toPad(top: 2, end: 6),
        CustomText(
          text: cancellation.subContent.toString().split('\n')[index],
          size: AppDimen.textSize_14,
          fontWeight : FontWeight.normal
        ).toStretch()
      ].toRow(crossAxisAlignment: CrossAxisAlignment.start).toPad(bottom: 12);
    }
  );
}
Widget showTitleDescWidget({
  String? title, required Widget widget, bool? isShowDivider
}){
  return [
    if(title !=null)
      CustomTitleText(text: title, size: AppDimen.textSize_18,).toPad(bottom: 5),
    widget.toPad(bottom: 10),
    if(isShowDivider ?? true)
      overALLThemeType == 4
          ? filterDivider.toFitToDeviceWidth().toResizeWidget(height: 1)
          : filterDivider,
  ].toColumn(mainAxisSize:  MainAxisSize.min
  );

}

  String _getSearchText(content) {
  List<String> searchtexts = content.toString().split('\n\n');

  if(searchtexts.length>1) {
    return content.toString().split('\n\n')[1];
  } else {
    return '';
  }
  }
}