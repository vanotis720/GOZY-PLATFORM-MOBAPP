import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';

import '../../../../constant.dart';
import '../../../../resources/app_font.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';
import '../../../../widgets/custom_text.dart';
import '../../base_controller.dart';
import 'app_manage_your_accout_controller.dart';

class AppManageYourAccount extends CustomStatefulWidget {
  const AppManageYourAccount({super.key});

  @override
  AppManageYourAccountState createState() => AppManageYourAccountState();
}

class AppManageYourAccountState extends CustomStatefulWidgetState<AppManageYourAccount>
    with TickerProviderStateMixin {
  AppManageYourAccountController controller = Get.find();
  static final AppLayoutModel? _profilelayout = appLayoutMap[AppLayout.profile];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        customAppBarFunction: () {
          onBack();
        },
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        backIconWidget:
            getBackIconWidget(themeType: _profilelayout!.themeType, backIcon: _profilelayout!.backIcon),
        body: showBodyContent(context));
  }

  Widget showBodyContent(context) {
    debugPrint("overALLAppLayoutModel!.deleteAccountIcon: ${_profilelayout!.deleteAccountIcon}");
    return [
      CustomTitleText(
        text: manage_your_account.tr,
        fontWeight: AppFont.semiBold,
        size: AppDimen.textSize_22,
      ),
      15.toHeight(),
      CustomContainer(
        body: [
          _profilelayout!.deleteAccountIcon.toSVG(
            colour: appColors.black,
            size: 16,
          ),
          7.toWidth(),
          CustomText(
            text: label_delete_account.tr,
            size: AppDimen.textSize_18,
            fontWeight: AppFont.medium,
          ),
        ].toRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
      8.toHeight(),
      RichText(
        textAlign: TextAlign.start,
        softWrap: true,
        text: TextSpan(
          text: label_caution.tr,
          style: getTextStyle(AppFont.medium, appColors.customTextColor),
          children: <TextSpan>[
            const TextSpan(text: ': '),
            TextSpan(
                text: label_delete_content.trParams({'field': APP_NAME}),
                style: getTextStyle(AppFont.regular, appColors.customTextColor)),
          ],
        ),
      ),
      15.toHeight(),
      toOnTap(
          onTap: () {
            toShowDeletePropertyDialog();
          },
          child: [
            CustomText(
                size: AppDimen.textSize_16,
                text: "label_delete_your_account".tr,
                color: appColors.secondaryColor),
            Assets.viewcarsLeftArrow
                .toSVG(colour: appColors.secondaryColor, height: 14, width: 14, isReverseRotation: true)
                .toPad(start: 5, end: 5, top: 5.0, bottom: 2.0)
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start)),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start)
        .toPad(horizontal: AppDimen.startMargin)
        .toResizeWidget(isDeviceFit: true);
  }

  TextStyle getTextStyle(FontWeight fontWeight, Color color) {
    return TextStyle(
        fontFamily: AppFont.font, fontWeight: fontWeight, color: color, fontSize: AppDimen.textSize_16);
  }

  void toShowDeletePropertyDialog() {
    String title = label_delete_account.tr;
    String content =
        '${are_you_sure_you_want.tr} ${label_delete_your_account_permanently.tr.toLowerCase()}${label_question_symbol.tr}';
    showAlertDialog(
      contentText: content,
      onOkPressed: () {
        controller.checkNetwork(controller.getDeleteUseData);
        Get.back();
      },
      cancelButtonContent: label_cancel.tr,
      okButtonContent: label_delete.tr,
      appLayout: AppLayout.profile,
      title: title,
    );
  }
}