import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/owner/generate_with_ai_owner/generate_with_ai_listings_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/shader_ai_text_view.dart';

import '../../../../widgets/ai_disclaimer_view.dart';

class GenerateBasePriceWithAi extends StatefulWidget {
  const GenerateBasePriceWithAi({super.key});

  @override
  State<GenerateBasePriceWithAi> createState() => _GenerateBasePriceWithAiState();
}

class _GenerateBasePriceWithAiState extends State<GenerateBasePriceWithAi> {
  GenerateWithAIListingsController controller = Get.find<GenerateWithAIListingsController>();
  String location = "";
  String carType = "";
  List<String> carFeatures = [];
  String make = "";
  String model = "";
  String year = "";
  String currency = "";

  @override
  void initState() {
    controller.isLoading.value = true;
    initFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        loader: LottieLoaders.three_dots_loader,
        resizeToAvoidBottomInset: true,
        backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
          backIcon: Assets.drawableSignupClose,
          onTap: () {
            Get.back();
          },
        ),
        body: !controller.isLoading.value ? _showBodyContent() : const SizedBox.shrink(),
        bottomNavigationBar: _showBottomView(),
      );
    });
  }

  Widget _showBodyContent() {
    return [
      _showTitleView(),
      ..._showAIGeneratedContent(),
    ].toColumn().toPad(horizontal: AppDimen.startMargin);
  }

  Widget _showTitleView() {
    return [
      Flexible(
        child: CustomTitleText(
          text: "label_check_market_price_with".tr,
          size: AppDimen.textSize_20,
          overflow: TextOverflow.ellipsis, // optional
          maxLines: 2, // or 2 if needed
        ),
      ),
      5.toWidth(),
      AiPillCard(),
    ]
        .toRow(
      mainAxisSize: MainAxisSize.max, // IMPORTANT CHANGE
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
    )
        .toPad(bottom: AppDimen.startMargin);
  }

  List<Widget> _showAIGeneratedContent() {
    print("minimum Price::::${controller.minPrice} ${controller.maxPrice} ${currency}");

    String min = double.parse(controller.minPrice.toString()).currencyConverted(convertedCurrency: currency);
    String currencySymbol = controller.getCurrencySymbol(currency: currency);
    print("Current Currency ${min}");
    return [
      CustomText(
          text: "label_market_suggested_price".tr.trParams({
            "field1": currencySymbol + controller.minPrice.toString(),
            "field2": currencySymbol + controller.maxPrice.toString()
          }),
          fontWeight: FontWeight.w300),
      10.toHeight(),
      CustomText(text: "label_check_price_content".tr, fontWeight: FontWeight.w300),
    ];
  }

  Widget _showBottomView() {
    return [
      const AIDisclaimerView(),
      CustomBottomItemShadowContainer(
        height: 100,
        color: appColors.white,
        padding: pad(w: 20, top: 25, bottom: 20),
        borderRadiusGeometry: BorderRadiusDirectional.vertical(
            top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            bottom: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
        body: [
          const Spacer(),
          PrimaryButton(
            buttonText: label_done.tr,
            isWrapContent: true,
            padding: pad(w: 24),
            onTap: () {
              Get.back();
            },
          ).toResizeWidget(height: 50)
        ].toRow(),
      ),
    ].toColumn(mainAxisSize: MainAxisSize.min);
  }

  void initFunction() {
    location = Get.arguments["location"] ?? "";
    carType = Get.arguments["carType"] ?? "";
    carFeatures = Get.arguments["carFeatures"] ?? [];
    make = Get.arguments["make"] ?? "";
    model = Get.arguments["model"] ?? "";
    year = Get.arguments["year"] ?? "";
    currency = Get.arguments["currency"] ?? "";
    controller.getBasePrice(
            location: location,
            carType: carType,
            carFeatures: carFeatures,
            make: make,
            model: model,
            currency:currency,
            year: year)
        .then((value) {
      controller.isLoading.value = false;
    });
  }
}