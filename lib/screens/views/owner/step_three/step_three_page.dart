import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/owner/progressive_chip_view.dart';
import 'package:gozy/widgets/owner/step_three/booking_type_selection_view.dart';
import 'package:gozy/widgets/owner/step_three/discount_entry_view.dart';
import 'package:gozy/widgets/owner/step_three/guest_requirements_view.dart';
import 'package:gozy/widgets/owner/step_three/car_rules_selection_view.dart';
import 'package:gozy/widgets/owner/step_three/local_laws_view.dart';
import 'package:gozy/widgets/owner/step_three/pricing_entry_view.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../../widgets/owner/step_three/booking_window_selection_view.dart';
import '../../base_controller.dart';
import '../../custom_scaffold.dart';

class StepThreePage extends CustomStatefulWidget {
  const StepThreePage({super.key});

  @override
  _StepThreePageState createState() => _StepThreePageState();
}

class _StepThreePageState extends CustomStatefulWidgetState<StepThreePage> with TickerProviderStateMixin {
  StepThreeController controller = Get.find();
  double bottomBorderRadius = 2;
  List<int> StepThreePages = [];
  Widget? _chipLayout;
  bool _isShowChiplayout = false;
  bool isloading = false;
  Widget? _cachedTheme4Body;

  @override
  void initState() {
    ever(appThemeChanged, (_) {
      _cachedTheme4Body = null;
    });
    isShowLoader = true;
    controller.itemInfo = Get.arguments['itemInfo'];
    StepThreePages.add(0);
    _isShowChiplayout =
        (controller.itemInfo != null && controller.itemInfo?.listingSteps?.step3 == 'completed');
    controller.checkNetwork(controller.getCurrenciesList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(overALLThemeType) {
      case 1:
        bottomBorderRadius = 20;
        break;
      case 2:
        bottomBorderRadius = 2;
        break;
      case 3:
        bottomBorderRadius = 30;
        break;
      default:
        bottomBorderRadius = 12;
        break;
    }
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      resizeToAvoidBottomInset: false,
      appBarBGColor: appColors.white,
      customAppBarFunction: () {
        _customBackEvent();
      },
      backIconWidget: getBackIconWidget(
        themeType: overALLThemeType,
        onTap: () {
          _customBackEvent();
        },
      ),
      body: InputDoneView(
        controller,
        parentWidget: showBodyContent(context).toPad(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 40 : 0)
      )
    );
  }

  Widget showBodyContent(context) {
    _addItemsToStepLayouts();
    if (_isShowChiplayout) {
      _chipLayout = ProgressiveChipView(
          stepLayoutItems: controller.stepthree_layout_items,
          choosedIndex: controller.choosedIndex,
          StepPages: StepThreePages,
          isloading: isloading,
          selectedChipIndex: controller.selectedChipIndex,
          controller: controller);
    }

    _cachedTheme4Body ??= toPropertyCreationColumn(
        topRadiusColor: appColors.white,
        stepLayoutItems: controller.stepthree_layout_items,
        chipLayout: _chipLayout,
        controller: controller,
        cornerRadius: BorderRadiusDirectional.only(topStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8), topEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8)),
        stepBasedPages: StepThreePages,
        containerColor: appColors.white,
        choosedIndex: controller.choosedIndex,
        tickerprovider: this,
        bottomProgressWidget: true,
        bottomBorderRadius: bottomBorderRadius,
        selectedChipIndex: controller.selectedChipIndex,
        onTaponSaveExit: () {
          if (!isloading) {
            isloading = true;
            controller.isSaveAndExit = true;
            updateStep3();
            Future.delayed(Duration(milliseconds: StepBtnclickInterval)).then((value) {
              isloading = false;
            });
          }
        });

    return _cachedTheme4Body!;
  }

  void _addItemsToStepLayouts() {
    controller.stepthree_layout_items.clear();

    CarRulesSelectionView houseRulesSelectionView = CarRulesSelectionView(
      controller: controller,
    );
    Map<String, dynamic> houseRulesMap = {};
    houseRulesMap['title'] = label_set_car_rules.tr;
    houseRulesMap['widget'] = houseRulesSelectionView;
    houseRulesMap['chipicon'] = Assets.drawableStepThreeChipHouseRules;
    houseRulesMap['chiptitle'] = label_car_rules.tr;
    houseRulesMap['onnext'] = houseRulesSelectionView.setValidation;

    controller.stepthree_layout_items.add(houseRulesMap);

    PricingEntryView pricingEntryView = PricingEntryView(
      controller: controller,
    );
    Map<String, dynamic> pricingEntryMap = {};
    pricingEntryMap['title'] = "${label_set.tr} ${label_pricing.tr.toLowerCase()}";
    pricingEntryMap['widget'] = pricingEntryView;
    pricingEntryMap['chipicon'] = Assets.drawableStepThreeChipPricing;
    pricingEntryMap['chiptitle'] = label_pricing.tr;
    pricingEntryMap['mainvalidation'] = () {
      Map<String, bool> results = {
        '${label_base_price.tr} ${error_msg_is_required.tr}':
            controller.basePriceEditController.Ttext.isEmpty ||
                double.parse(controller.basePriceEditController.Ttext) <= 0,
      };
      return (results.isValidate(controller: controller));
    };
    pricingEntryMap['onnext'] = () {
      return pricingEntryView.setValidation();
    };
    controller.stepthree_layout_items.add(pricingEntryMap);

    DiscountEntryView discountEntryView = DiscountEntryView(
      controller: controller,
    );
    Map<String, dynamic> discountEntryMap = {};
    discountEntryMap['title'] = label_set_discount.tr;
    discountEntryMap['widget'] = discountEntryView;
    discountEntryMap['chipicon'] = Assets.drawableStepThreeChipDiscount;
    discountEntryMap['chiptitle'] = label_set_discount.tr;
    discountEntryMap['onnext'] = () {
      return discountEntryView.setValidation();
    };
    controller.stepthree_layout_items.add(discountEntryMap);

    BookingWindowSelectionView bookingWindowSelectionView = BookingWindowSelectionView(
      controller: controller,
    );
    Map<String, dynamic> bookingwindowMap = {};
    bookingwindowMap['title'] =
        '${label_availability_window.tr} & ${label_trip_length.tr} & ${label_cancellation.tr}';
    bookingwindowMap['widget'] = bookingWindowSelectionView;
    bookingwindowMap['chipicon'] = Assets.drawableStepThreeChipBookingWindow;
    bookingwindowMap['chiptitle'] = label_booking_window.tr;
    bookingwindowMap['mainvalidation'] = () {
      return bookingWindowSelectionView.setValidation();
    };
    bookingwindowMap['onnext'] = () {
      return bookingWindowSelectionView.setValidation();
    };
    controller.stepthree_layout_items.add(bookingwindowMap);

    BookingTypeSelectionView bookingTypeSelectionView = BookingTypeSelectionView(
      controller: controller,
    );
    Map<String, dynamic> bookingtypeMap = {};
    bookingtypeMap['title'] = '${label_what_is_your_preferred_booking_type.tr}${label_question_symbol.tr}';
    bookingtypeMap['widget'] = bookingTypeSelectionView;
    bookingtypeMap['chipicon'] = Assets.drawableStepThreeChipBooking;
    bookingtypeMap['chiptitle'] = label_booking.tr;
    controller.stepthree_layout_items.add(bookingtypeMap);

    GuestRequirementsView guestRequirementsView = GuestRequirementsView(
      controller: controller,
    );
    Map<String, dynamic> guestrequirementsMap = {};
    guestrequirementsMap['title'] = '${label_review.tr} ${label_renter_requirements.tr.toLowerCase()}';
    guestrequirementsMap['widget'] = guestRequirementsView;
    guestrequirementsMap['chipicon'] = Assets.drawableStepThreeChipGuestRequirements;
    guestrequirementsMap['chiptitle'] = label_renter_requirements.tr;
    controller.stepthree_layout_items.add(guestrequirementsMap);

    LocalLawsView locallawsView = LocalLawsView(
      controller: controller,
    );
    Map<String, dynamic> locallawsMap = {};
    locallawsMap['title'] = label_local_laws_title.tr;
    locallawsMap['widget'] = locallawsView;
    locallawsMap['chipicon'] = Assets.drawableStepThreeChipLocalLaws;
    locallawsMap['chiptitle'] = label_local_laws.tr;
    locallawsMap['onnext'] = () {
      updateStep3();
    };
    controller.stepthree_layout_items.add(locallawsMap);
  }

  void _customBackEvent() {
    if (!isloading) {
      isloading = true;
      if (StepThreePages.isNotEmpty) {
        StepThreePages.removeLast();
      }
      FocusManager.instance.primaryFocus?.unfocus();
      if (StepThreePages.isEmpty) {
        if (!Get.isSnackbarOpen) {
          Get.back();
        } else {
          Get.back();
          Future.delayed(Duration(milliseconds: 100), () {
            _customBackEvent();
          });
        }
      } else {
        controller.choosedIndex.value = StepThreePages[StepThreePages.length - 1];
        controller.isLoading.refresh();
      }
      Future.delayed(Duration(milliseconds: StepBtnclickInterval)).then((value) {
        isloading = false;
      });
    }
  }

  void updateStep3() {
    bool isFinish = true;
    controller.stepthree_layout_items.asMap().forEach((index, element) {
      if (element['mainvalidation'] != null && isFinish) {
        isFinish = element['mainvalidation']();
        if (!isFinish) {
          StepThreePages.clear();
          for (int i = 0; i <= index; i++) {
            StepThreePages.add(i);
          }
          if (controller.selectedChipIndex.value != index) {
            controller.selectedChipIndex.value = index;
          } else {
            controller.selectedChipIndex.refresh();
          }

          controller.choosedIndex.value = index;
        }
      }
    });
    if (isFinish) {
      controller.checkNetwork(controller.updateStep3Details);
    }
  }

  @override
  void dispose() {
    controller.choosedIndex.value = 0;
    controller.selectedChipIndex.value = 0;
    _cachedTheme4Body = null;
    super.dispose();
  }
}