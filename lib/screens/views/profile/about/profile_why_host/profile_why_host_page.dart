import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/profile/about/profile_why_host/profile_why_host_controller.dart';
import 'package:gozy/widgets/common/custom_button/secondary_button.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../../constant.dart';
import '../../../../../generated/assets.dart';

import '../../../base_controller.dart';

class ProfileWhyHostPage extends CustomStatefulWidget {
  const ProfileWhyHostPage({super.key});

  @override
  ProfileWhyHostPageState createState() => ProfileWhyHostPageState();
}

class ProfileWhyHostPageState extends CustomStatefulWidgetState<ProfileWhyHostPage>
    with TickerProviderStateMixin {
  ProfileWhyHostController controller = Get.find();
  static final AppLayoutModel? _profilelayout = appLayoutMap[AppLayout.profile];

  @override
  void initState() {
    _setController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: controller,
      isShowAppBar: false,
      customAppBarFunction: () {
        onBack();
      },
      isShowBGOnLoader: false,
      loader: LottieLoaders.three_dots_loader,
      title: manage_your_account.tr,
      body: FutureBuilder<bool>(
          future: controller.getWhyHost(),
          builder: (context, snapshot) {
            return snapshot.data != null ? showBodyContent(context) : const SizedBox.shrink();
          }),
    );
  }

  Widget showBodyContent(context) {
    return [
      _showListingPhotos(),
      _showBottomContent(),
      getBackIconWidget(
        themeType: _profilelayout!.themeType,
        backIcon: _profilelayout!.backIcon,
        iconBGColor: appColors.white,
        iconColor: appColors.black
      ),
    ].toStack().toResizeWidget(isDeviceFit: true);
  }

  Widget _showBottomContent() {
    return [
      GetBuilder(
        init: controller,
        id: controller.rxCurrentPage.id,
        builder: (context) => IgnorePointer(
          ignoring: true,
          child: CustomText(
            text:
                '${controller.getWhyHostData?.getWhyHostData?.results?[controller.rxCurrentPage.value]?.title}',
            size: AppDimen.textSize_22,
            font: AppFont.font,
            fontWeight: AppFont.regular,
            color: AppColors.staticwhite,
          ),
        ),
      ),
      15.toHeight(),
      scrollingDotWidget(
          count: controller.getWhyHostData?.getWhyHostData?.results?.length),
      GetBuilder(
        init: controller,
        id: controller.rxCurrentPage.id,
        builder: (context) => SecondaryButton(
          textColor: appColors.black,
          isResizeText: true,
          padding: EdgeInsets.symmetric(horizontal: AppDimen.startMargin),
          fillcolor: appColors.whiteButtonColor,
          isButtonLayout: true,
          buttonText: "${controller.getWhyHostData?.getWhyHostData?.results?[controller.rxCurrentPage.value]?.buttonLabel}",
          onTap: () {
            controller.moveToLetsStartPage(whyHostFunction: () {
              Get.close(1);
              Get.close(1);
              Get.close(1);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                  HomeController homeController = Get.find();
                  homeController.change(rxVariable: homeController.rxSelectedTab, value: 0);
                });
              });
            });
          }
        ).toPad(bottom: AppDimen.startMargin, top: 18),
      ),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
        )
        .toPad(horizontal: AppDimen.startMargin);
  }

  Widget scrollingDotWidget({int? count}) {
    return count != null && count > 1
        ? Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: GetBuilder(
              init: controller,
              id: controller.rxCurrentPage.id,
              builder: (_) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(count, (index) {
                  final isActive = index == controller.rxCurrentPage.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? appColors.searchPageBgColor
                          : appColors.ratingBarDefaultColor,
                    ),
                  );
                }),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _showListingPhotos() {
    return toPageView(
      itemCount: controller.getWhyHostData?.getWhyHostData?.results?.length,
      controller: controller.hostPageController,
      physics: const ClampingScrollPhysics(),
      onPageChanged: (index) {
        controller.change(rxVariable: controller.rxCurrentPage, value: index);
      },
      itemBuilder: (context, index) {
        return _getPageImage(index);
      },
    ).toResizeWidget(height: deviceHeight);
  }

  Widget _getPageImage(
    int index,
  ) {
    return [
      CustomContainer(
        body: _getPhoto(index, uploadWhyHostOriginal).isNotEmpty ? CustomClipNetworkImage(
          imageUrl: _getPhoto(index, uploadWhyHostOriginal),
          placeholderWidget: Assets.drawableWhyHostPlaceHolder.toSVG(fit: BoxFit.fitHeight),
          width: deviceWidth,
          height: deviceHeight,
          placeholderURL: _getPhoto(index, uploadWhyHostMedium),
          foregroundDecoration: BoxDecoration(
            color: appColors.popularLocationBottomShadowColor,
            borderRadius: BorderRadius.zero,
          ),
        ) : Assets.drawableWhyHostPlaceHolder.toSVG(fit: BoxFit.fitHeight, height: deviceHeight),
      ),
      CustomContainer(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.staticblack.withAlpha(200), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    ].toStack().toResizeWidget(height: deviceHeight);
  }

  String _getPhoto(int index, String upload) {
    String photo = '';
    if (controller.getWhyHostData?.getWhyHostData?.results?[index]?.imageName != null) {
      photo = upload + (controller.getWhyHostData?.getWhyHostData?.results?[index]?.imageName ?? '');
    }
    return photo;
  }

  void _setController() {
    controller.hostPageController = PageController(initialPage: 0, viewportFraction: 1);
  }
}