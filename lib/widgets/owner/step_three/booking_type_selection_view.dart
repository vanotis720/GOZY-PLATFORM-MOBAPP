import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/checkbox_group.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_font.dart';
import '../../../resources/app_lang.dart';

class BookingTypeSelectionView extends GetView{
  @override
  StepThreeController controller;
  final Duration _duration = const Duration(milliseconds: 150);
  final ScrollController  _scrollController = ScrollController();

  BookingTypeSelectionView({super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      AppDimen.startMargin.toHeight(),
      CustomText(text: label_increase_your_earnings_with_instant_book.tr, fontWeight: AppFont.medium, size: AppDimen.textSize_18,),
      10.toHeight(),
      CustomText(text: label_preferred_booking_type_content.tr, fontWeight: AppFont.regular, size: AppDimen.textSize_14),
      15.toHeight(),
      CustomText(text: '${label_who_can_book_instantly.tr}${label_question_symbol.tr}', fontWeight: AppFont.semiBold,size: AppDimen.textSize_16,),
      10.toHeight(),
      CustomText(text: '${label_book_instantly_desc.tr}${label_question_symbol.tr}', fontWeight: AppFont.regular,size: AppDimen.textSize_14,),
      15.toHeight(),
      filterDivider,
      15.toHeight(),
      Obx(() => [
        toOnTap(
            onTap: (){
              controller.selectedBookingType.value = 'instant';
              _animatetoBottom();
            },
            child: [
              [
                CustomCheckBox(
                    ischeckCondition:
                    controller.selectedBookingType.value != 'instant',
                    unselectCheckBoxColor: appColors.white,
                    isNeedEndPadding:false,
                    isNeedTopMargin: false
                ),
                12.toWidth(),
                CustomText(
                  text: label_renters_who_meet_requirements.tr,
                  fontWeight: AppFont.regular,
                  size: AppDimen.textSize_14,
                ).toStretch(),
              ].toRow(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center),
              8.toHeight(),
              AnimatedContainer(
                duration: _duration,
                height: controller.selectedBookingType.value == 'instant'
                    ? 40
                    : 0,
                child: AnimatedOpacity(
                  opacity:
                  controller.selectedBookingType.value == 'instant'
                      ? 1.0
                      : 0.0,
                  duration: _duration,
                  child: CustomText(
                    text: label_anyone_else_must_send_a_reservation_request.tr,
                    fontWeight: AppFont.regular,
                    size: AppDimen.textSize_14,
                    color: appColors.placeholderColor,
                  ),
                ),
              ).toPad(start: 34),
            ].toColumn()
        ),
        filterDivider,
        15.toHeight(),
        toOnTap(
          onTap: (){
            controller.selectedBookingType.value = 'request';
            _animatetoBottom();
          },
          child: [
            CustomCheckBox(
                ischeckCondition:
                controller.selectedBookingType.value == 'instant',
                unselectCheckBoxColor: appColors.white,
                isNeedEndPadding:false,
                isNeedTopMargin: false

            ),
            12.toWidth(),
            CustomText(
              text: label_all_renters_must_send.tr,
              fontWeight: AppFont.regular,
              size: AppDimen.textSize_14,
            ).toStretch(isExpanded: false),
          ].toRow(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center),
        ),
        25.toHeight()
      ].toColumn(mainAxisSize: MainAxisSize.max)
      ),
    ].toScroll(
      scrollController: _scrollController,
    );
  }

  void _animatetoBottom() {
    Future.delayed(_duration).then((value) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    });
  }
}