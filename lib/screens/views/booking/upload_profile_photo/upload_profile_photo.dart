import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/widgets/common/custom_button/bottom_shadow_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';

import '../../../../../constant.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../widgets/common_extension_functions.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../generated/assets.dart';
import '../../../../widgets/upload_profile/upload_profile.dart';
import '../../base_controller.dart';
import '../../custom_scaffold.dart';
import '../../home_item_detail/home_item_detail.dart';

class UploadProfilePhoto extends HomeItemDetailView {
  UploadProfilePhoto({super.key});

  @override
  UploadProfilePhotoState createState() => UploadProfilePhotoState();
}

class UploadProfilePhotoState extends HomeItemDetailState {
  Map<String, dynamic> arguments = {};
  bool isFillProfileTitle = false;
  bool isTitleAndContentShowOnTop = true;

  @override
  void initState() {
    initTheme();
    arguments = Get.arguments ?? {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      isShowBGOnLoader: false,
      loader: LottieLoaders.three_dots_loader,
      backIconWidget: getBackIconWidget(themeType: overALLThemeType, backIcon: Assets.drawableSignupClose),
      resizeToAvoidBottomInset: true,
      body: showBodyContents(),
    );
  }

  Widget showBodyContents() {
    return [
      _showProfileDetails(),
      _showNextButton(),
    ].toColumn().toPad(horizontal: AppDimen.startMargin);
  }

  Widget _showProfileDetails() {
    return [
      if (isTitleAndContentShowOnTop) ..._showTitleAndContent(),
      _showUploadProfileView(),
      if (!isTitleAndContentShowOnTop) ..._showTitleAndContent(),
    ].toColumn().toStretch(isExpanded: true);
  }

  List<Widget> _showTitleAndContent() {
    return [
      if (!isTitleAndContentShowOnTop) 20.toHeight(),
      CustomTitleText(
          text: label_add_profile_photo.tr, fontWeight: AppFont.semiBold, size: AppDimen.textSize_22),
      20.toHeight(),
      CustomText(
        text: label_upload_profile_description.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      30.toHeight(),
    ];
  }

  Widget _showUploadProfileView() {
    return ConditionalParentWidget(
        condition: isFillProfileTitle,
        parentBuilder: (child) {
          return CustomBorderContainer(
            color: appColors.myTripsBGColor,
            padding: pad(h: AppDimen.startMargin),
            borderRadius: overALLAppLayoutModel?.borderRadius,
            alignment: AlignmentDirectional.center,
            body: child,
          );
        },
        child: UploadProfile(
          uploadIcon: overALLAppLayoutModel?.imageUploadIcon ?? '',
          themeType: overALLThemeType,
        ));
  }

  Widget _showNextButton() {
    return IntrinsicHeight(
      child: BottomShadowButton(
          buttonPadding: pad(a: 20),
          borderRadiusGeometry:
              BorderRadiusDirectional.only(topStart: Radius.circular(20), topEnd: Radius.circular(20)),
          buttonText: btn_label_next.tr,
          onTap: () {
            if ((controller.appPreference.profileImage ?? '').isNotEmpty) {
              arguments["onTap"]((value) {
                controller.isLoading.value = isShowLoader = value;
                if (arguments["page"] == "contacthost" && !controller.isLoading.value) {
                  Get.back();
                }
              });
            } else {
              controller.isLoading.value = isShowLoader = false;
              controller.showSnackBar('label_add_profile_photo_error'.tr);
            }
          }).toFitToDeviceWidth(),
    );
  }

  void initTheme() {
    switch (overALLThemeType) {
      case 3:
        isFillProfileTitle = true;
        isTitleAndContentShowOnTop = false;
        break;
      case 4:
        isTitleAndContentShowOnTop = false;
      default:
        break;
    }
  }
}