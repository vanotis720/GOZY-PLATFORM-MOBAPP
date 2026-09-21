import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

class ClaimDetails extends StatefulWidget {
  const ClaimDetails({super.key});

  @override
  State<ClaimDetails> createState() => _ClaimDetailsState();
}

class _ClaimDetailsState extends State<ClaimDetails> {
  double? imageBorderRadius = overALLAppLayoutModel?.borderRadius;
  dynamic arguments;

  @override
  void initState() {
    arguments = Get.arguments;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print("Arguments--> ${arguments["reservationItem"].currency.toString()}");
    return CustomScaffold(
      controller: basecontroller,
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(backIcon: Assets.drawableSignupClose),
      body: [
        CustomTitleText(text: label_claim_details.tr, size: AppDimen.textSize_26, fontWeight: AppFont.semiBold,),
        0.toHeight(),
        CustomText(text: label_deposit_amount.tr, size: AppDimen.textSize_18, fontWeight: AppFont.medium,),
        CustomText(text: '${basecontroller.getCurrencySymbol()} ${double.parse(arguments["reservationItem"].securityDeposit.toString()).currencyConverted(convertedCurrency: arguments['reservationItem'].currency ?? defaultCurrency)}', size: AppDimen.textSize_16, fontWeight: AppFont.regular,),
        filterDivider,
        CustomText(text: label_amount_requested_by_owner.tr, size: AppDimen.textSize_18, fontWeight: AppFont.medium,),
        CustomText(text: '${basecontroller.getCurrencySymbol()} ${double.parse(arguments["reservationItem"].claimRefund.toString()).currencyConverted(convertedCurrency: arguments['reservationItem'].currency ?? defaultCurrency)}', size: AppDimen.textSize_16, fontWeight: AppFont.regular,),
        filterDivider,
        CustomText(text: label_reason_for_claim.tr, size: AppDimen.textSize_18, fontWeight: AppFont.medium,),
        CustomText(text: arguments["reservationItem"].claimReason ?? "", size: AppDimen.textSize_16, fontWeight: AppFont.regular,),
        filterDivider,
        CustomText(text: label_uploaded_images.tr, size: AppDimen.textSize_18, fontWeight: AppFont.medium,),
        showImageView(imageBorderRadius: imageBorderRadius ?? 0, images: arguments["reservationItem"].claimImages?.whereType<String>().toList() ?? [])
      ].toColumn(spacing: 12).toPad(horizontal: AppDimen.startMargin).toScroll()
    );
  }
}

Widget showImageView({required double imageBorderRadius, required List<String> images}) {
  return toGridView(
    baseController: basecontroller,
    crossAxisSpacing: AppDimen.startMargin - 5,
    mainAxisSpacing: AppDimen.startMargin,
    gridItemCount: 2,
    itemSize: 120,
    padding: pad(bottom: 25),
    physics: NeverScrollableScrollPhysics(),
    itemCount: images.length,
    itemBuilder: (BuildContext context, int index) {
      return images[index].isNotEmpty ?
      CustomClipNetworkImage(
          imageUrl:  "$claimURL${images[index]}",
        borderRadius: BorderRadius.all(Radius.circular(imageBorderRadius))
      ) : 0.toHeight();
    }
  );
}