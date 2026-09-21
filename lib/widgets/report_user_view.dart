import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_button/bottom_shadow_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/custom_text.dart';

class ReportUserView extends GetView{
  Rx<int> selectedReportReason;
  @override
  BaseController controller;
  List<dynamic> ReportReasonList;
  final GestureTapCallback? onTap;

  ReportUserView({super.key,
    required this.controller,
    required this.selectedReportReason,
    required this.ReportReasonList,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
    controller.isLoading.value
        ? dotCenter120HeightLoader!
        : GetBuilder<BottomSheetController>(
      builder: (newController) => ColoredBox(
        color: appColors.white,
        child: [
             [
               CustomTitleText(
                    text:
                    '${label_do_you_want_to_report_this.tr} ${label_user.tr}${label_question_symbol.tr}',
                      size: AppDimen.textSize_18,
                 fontWeight: AppFont.medium,
                  ),
                  15.toHeight(),
                  CustomText(
                    text: label_if_so_please_choose_one_of_the_following_reasons
                        .tr,
                    size: AppDimen.textSize_16,
                    color: appColors.textColor,
                  ),
                  20.toHeight(),

                  for (var i = 0;
                  i < ReportReasonList.length;
                  i++) ...[
                    Obx(() {
                      debugPrint(
                          "selectedReportReason.value: ${selectedReportReason.value}");
                      return [
                        toOnTap(
                          onTap: () {
                            selectedReportReason.value =
                            selectedReportReason.value != i ? i : -1;
                            selectedReportReason.refresh();
                          },
                          child: CustomCheckBoxListItem(
                            itemPropertyText:
                            ReportReasonList[i].reportContent,
                            topPadding: 3,
                            iconWidget: CustomBorderContainer(
                              width: 25,
                              height: 25,
                              alignment: AlignmentDirectional.center,
                              borderColor: appColors.placeholderColor,
                              shape: BoxShape.circle,
                              color: selectedReportReason.value == i
                                  ? appColors.secondaryColor
                                  : Colors.transparent,
                              body: selectedReportReason.value == i
                                  ? Assets
                                  .drawableViewdetailReportTick
                                  .toSVG(size: 10)
                                  : null,
                            ).toPad(end: 10),
                            fontSize: AppDimen.textSize_14,
                            fontWeight: FontWeight.w500,
                            color: appColors.customTextColor,
                          ).toPad(vertical: 15),
                        ),
                        if (i < ReportReasonList.length - 1)
                          filterDivider
                      ].toColumn();
                    }),
                  ],
                ].toColumn().toPad(horizontal: AppDimen.startMargin).toScroll().toStretch(),

          BottomShadowButton(
            buttonPadding: pad(a: 20),
            buttonText : label_report.tr,
            borderRadiusGeometry:  BorderRadiusDirectional.only( topStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
                topEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
            onTap: onTap,
          )
          ].toColumn(),
        ),
      ),
    );
  }






}