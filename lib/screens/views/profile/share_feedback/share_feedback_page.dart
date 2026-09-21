import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/share_feedback/share_feedbackpage_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_textfield_area.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';

import '../../../../resources/app_layout.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';

class ShareFeedbackPage extends CustomStatefulWidget {
  const ShareFeedbackPage({super.key});

  @override
  ShareFeedbackPageState createState() => ShareFeedbackPageState();
}

class ShareFeedbackPageState extends CustomStatefulWidgetState<ShareFeedbackPage>
    with TickerProviderStateMixin {
  ShareFeedBackPageController controller = Get.find();

  static int profileThemeType = appLayoutMap[AppLayout.profile]?.themeType ?? 0;
  static double profileBorderRadius = appLayoutMap[AppLayout.profile]?.borderRadius ?? 0;

  double? imageBgBorderRadius;
  double? textFieldBorderRadius;
  Color? imageBgColor;
  Color? iconColor;
  Color? fillColor;
  bool? showDottedBorder;
  Map<String, String> _feedbackicons = {};
  static AppLayoutModel? profilelayout = appLayoutMap[AppLayout.profile];

  @override
  Widget build(BuildContext context) {
    _feedbackicons = getIcon();

    return CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        customAppBarFunction: () {
          onBack();
        },
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        backIconWidget:
            getBackIconWidget(themeType: profilelayout!.themeType, backIcon: profilelayout!.backIcon),
        body: showBodyContent(context));
  }

  Widget showBodyContent(context) {
    return [
      CustomTitleText(
          text: feedback_label.tr.toUpperLowerCase(),
          size: AppDimen.textSize_22,
          fontWeight: AppFont.semiBold),
      18.toHeight(),
      CustomText(
        textAlign: TextAlign.start,
        text: "${label_how_are_doing.tr}${label_question_symbol.tr}",
        size: AppDimen.textSize_16,
        fontWeight: AppFont.semiBold,
      ),
      6.toHeight(),
      CustomText(
        text: label_feedback_content.trParams({'field': APP_NAME}),
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      18.toHeight(),
      CustomText(
        text: "${label_whouldlike.tr}${label_question_symbol.tr}",
        size: AppDimen.textSize_16,
        fontWeight: AppFont.semiBold,
        alignment: AlignmentDirectional.topStart,
      ),
      12.toHeight(),
      _getFeedBackWidget(type: 'feedback'),
      12.toHeight(),
      _getFeedBackWidget(type: 'bug'),
    ].toColumn(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: AppDimen.startMargin);
  }

  Map<String, String> getIcon() {
    switch (profileThemeType) {
      case 1:
        imageBgBorderRadius = 12;
        textFieldBorderRadius = 6;
        imageBgColor = appColors.myTripsBGColor;
        return {
          "feedback": Assets.drawableGiveFeedback,
          "bug": Assets.drawableSharebug,
        };
      case 2:
        imageBgBorderRadius = 100;
        textFieldBorderRadius = 0;
        imageBgColor = appColors.theme4AppBarBg;
        iconColor = appColors.black;
        return {
          "feedback": Assets.theme2FeedbackTheme2,
          "bug": Assets.theme2BugTheme2,
        };
      case 3:
        imageBgBorderRadius = 100;
        textFieldBorderRadius = 18;
        imageBgColor = appColors.theme4AppBarBg;
        return {
          "feedback": Assets.theme3FeedbackTheme3,
          "bug": Assets.theme3BugTheme3,
        };
      default:
        imageBgBorderRadius = 100;
        showDottedBorder = true;
        imageBgColor = appColors.white;
        fillColor = appColors.theme4AppBarBg;
        iconColor = appColors.black;
        return {
          "feedback": Assets.theme4FeedbackTheme4,
          "bug": Assets.theme4BugTheme4,
        };
    }
  }

  void showFeedbackDialog(String type) {
    controller.shareFeedBackController.clear();
    showAlertDialog(
        appLayout: AppLayout.profile,
        content: [
          Scrollbar(
              child: CustomTextfieldArea(
            focusNode: controller.feedbackFocusNode,
            hintText: type == "feedback"
                ? "${enter_your.tr} ${label_feedback_here.tr}"
                : label_bug.tr.toUpperLowerCase(),
            controller: controller.shareFeedBackController,
            borderTextfieldPadding: pad(top: 10, w: 18),
            minLines: 4,
            maxLines: 4,
          )).toResizeWidget(
            height: 110,
          ),
          Obx(() => controller.isLoading.value
              ? dotCenter120HeightLoader!.toPad(vertical: 10)
              : const SizedBox.shrink())
        ].toStack(),
        onOkPressed: () {
          bool isvalidate = controller.validateCredentials(type: type);
          if (isvalidate && !controller.isLoading.value) {
            controller.isLoading.value = true;
            controller.checkNetwork(controller.sendFeedback(type));
          }
        },
        cancelButtonContent: label_cancel.tr,
        okButtonContent: label_dialog_btn_send.tr,
        title: type == "feedback" ? feedback_label.tr.toUpperLowerCase() : bug_label.tr.toUpperLowerCase());
  }

  Widget _getFeedBackCommonFunction(
      {required String hintContent, required String imageType, required GestureTapCallback onTap}) {
    return CustomBorderContainer(
      onTap: onTap,
      height: 68,
      borderRadius: profileBorderRadius,
      color: fillColor,
      padding: pad(start: 12),
      body: [
        CustomBorderContainer(
          height: 44,
          width: 44,
          color: imageBgColor,
          borderRadius: imageBgBorderRadius,
          margin: pad(end: 12),
          padding: EdgeInsets.all(3),
          borderColor: controller.darken(imageBgColor!),
          body: imageType.toSVG(fit: BoxFit.scaleDown, colour: iconColor ?? appColors.black),
        ),
        CustomText(
          text: hintContent,
          size: AppDimen.textSize_16,
          fontWeight: AppFont.regular,
        ).toStretch(),
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  Widget _getFeedBackWidget({required String type}) {
    return ConditionalParentWidget(
      condition: (showDottedBorder ?? false),
      parentBuilder: (child) => DottedBorderView(
          borderRadius: profileBorderRadius, dottedlineColor: appColors.colorCommonLinkColor, child: child),
      child: _getFeedBackCommonFunction(
          onTap: () {
            showFeedbackDialog(type);
          },
          hintContent: type == 'feedback' ? label_givefeedback.tr : label_report_bug.tr,
          imageType: _feedbackicons[type]!),
    );
  }
}