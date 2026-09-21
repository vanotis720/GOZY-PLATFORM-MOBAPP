import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/static_page/static_page_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import '../../../constant.dart';
import '../../../widgets/custom_stateful_widget.dart';
import '../base_controller.dart';

class StaticContentPage extends CustomStatefulWidget {
  const StaticContentPage({super.key});

  @override
  StaticContentPageState createState() => StaticContentPageState();
}

class StaticContentPageState
    extends CustomStatefulWidgetState<StaticContentPage>
    with TickerProviderStateMixin {
  StaticContentPageController controller = Get.find();

  @override
  void initState() {
    controller.staticPageContentData = null;
    if (Get.arguments != null) {
      controller.staticpageId = int.parse(Get.arguments[0].toString());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isLoading.value = true;
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        controller.checkNetwork(controller.getStaticPageContent);
      });
    });
    isShowLoader = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ColoredBox(
      color: appColors.white,
      child: SafeArea(
        top: false,
        child: CustomScaffold(
              controller: controller,
              isShowAppBar: true,
              isShowBGOnLoader: false,
              loader: LottieLoaders.three_dots_loader,
              backIconWidget: getBackIconWidget(themeType: overALLThemeType),
              body: controller.isLoading.value
                  ? const SizedBox.shrink()
                  : showBodyContent(context),
            ),
          ),
    ),
    );
  }

  Widget showBodyContent(context) {
    return [
      CustomTitleText(
        text:
        (!controller.isLoading.value && controller.staticPageContentData?.getStaticPageContent?.result?.metaTitle != null ?
          controller.staticPageContentData?.getStaticPageContent?.result?.metaTitle :
          ''
        ) ?? '',
        fontWeight: AppFont.semiBold,
        size: AppDimen.textSize_22,
      ).toPad(horizontal: AppDimen.startMargin, bottom: 12),
      [
        controller.staticPageContentData !=null ?
        controller.staticPageContentData?.getStaticPageContent?.result?.content?.toHTMLWidget(controller: controller).toPad(horizontal: AppDimen.startMargin) as  Widget : const SizedBox.shrink(),
        20.toHeight(),
      ].toScroll().toStretch()
    ].toColumn().toResizeWidget(isDeviceFit: true);
  }

  @override
  void dispose() {
    controller.staticPageContentData?.toJson().clear();
    super.dispose();
  }

}