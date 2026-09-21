import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';

class AppColors {

  static const Color staticwhite = Color(0xFFFFFFFF);

	 static const lightprimaryColor = Color(0xFF0B0E26);
	 static const Color lightsecondaryColor = Color(0xFF5e17eb);
	 static const Color wishListTyreColor = Color(0xFFC0C0C0);
   Color starterPlanCircleColor = Color(0xFFE6E8EC);
   late Color colorCommonLinkColor = const Color(0xFF5e17eb);
   static Color linkColor = const Color(0xFF5e17eb);
   static const  Color staticblack = Color(0xFF000000);
   Color primaryColor = basecontroller.isDarkMode()  ? const Color(0xFF5A69D5) : lightprimaryColor;
   Color secondaryColor = basecontroller.isDarkMode() ? const Color(0xFF5A69D5) : lightsecondaryColor;
   Color buttonTextColor = basecontroller.isDarkMode() ? const Color(0xFFC7D8EB) : const Color(0xFFFFFFFF);
   List<Color> shimmerColors = [
     Color(0x4cffffff),
     Color(0xFFFFFFFF),
     Color(0xFFFFFFFF),
     Color(0x4cffffff),
   ];

   late Color mapWidgetColor = Color(0xFFb4b4b4);
  late Color ratingDimColor = Color(0xFFB4B4B4);

  late  Color stepChipSelectionColor = secondaryColor.withAlpha(20);
  late  Color textFieldInActiveIconColor = Color(0xFFb4b4b4);
  late  Color lightYellowColor = Color(0xFFFFFBF7);
  Color snackBarBorderColor = basecontroller.isDarkMode() ? Color(0xFFE9E9E9) : Colors.transparent;
  late  Color white = basecontroller.isDarkMode() ? Color(0xFF171D37) : staticwhite;
  late  Color black = staticblack;


  Color bottomNavBarSelectedColor = Color(0xFF5e17eb);
  Color bottomNavBarUnSelectedColor = Color(0xFF080A1C);
  late  Color mapblack =const  Color(0xFF131313);
  static const  Color skipBgColor =Colors.black26;
  late  Color explore_search_icon_bg = Color(0xFFf9f9f9);
  late  Color back_close_icon_bg = Color(0xFFF3F3F3);
  late  Color cardTheme1Color = Color(0xFFF3F3F3);
  late  Color profile_bg = Color(0xFFf9f9f9);
  late  Color theme3AppBg = Color(0x090B1E2E);
  late Color theme4AppBarBg = Color(0xFFEEF3FF);
  late  Color guest_blocked_dates = Color(0xFF858585);
  late  Color lottieColor = secondaryColor;

  late  Color listShareBGShadowColor = guest_blocked_dates;
  late Color whiteButtonColor = staticwhite;

  late  Color secondaryTextColor = Color(0xFF171E14);
  late  Color listingItemBGColor = Color(0xFFF7F7F7);
  late  Color BackIconBorderColor = basecontroller.isDarkMode() ? Color(0xFF0E142F) : Color(0xFFE7E7E7);
  late  Color myTripsBGColor = Color(0xFFF5F5F5);
  late  Color famousLocationBGColor = Color(0xFFF5F5F5);
  late  Color myTripsDividerColor = Color(0xFFE0E0E0);
  late  Color replyContainer = Color(0xFFE0E0E0);
  late  Color listingItemActionsBGColor = Color(0xFFF1F1F1);
  late  Color customTextColor = mapblack;
  late  Color greyBorderColor = Color(0xFFF8F7FD);
  late  Color keyboardColor = Color(0xFFd8d8d8);
  late  Color commonDividerColor = Color(0xFFE9E9E9);
  late  Color unreadInboxBGColor = greyBorderColor.withValues(alpha:0.8);
  late  Color discountAmountColor = Color(0xFF1DD265);
  late  Color customBorderColor = Color(0xFFDDDDDD);
  late  Color cancelTripRefundableBGColor = Color(0xFFF3FFF0);
  late  Color cancelTripNonRefundableBGColor = Color(0xFFFFF3F5);
  late  Color pendingStatusColor = Color(0xFF075FB7);
  late  Color approvedStatusColor = Color(0xFF07B71D);
  late  Color confirmedStatusColor = Color(0xFF80A600);
  late  Color completedStatusColor = Color(0xFF008976);
  late  Color expiredStatusColor = Color(0xFFF0AD4E);
  late  Color inquiryStatusColor = Color(0xFF5BC0DE);
  late  Color declinedStatusColor = Color(0xFFFD2D34);
  late  Color cancelledStatusColor = Color(0xFFE02B07);
  late  Color requestToBookStatusColor = Color(0xFF075FB7);
  late  Color viewMessageSenterBGColor = Color(0xFFedf4ff);
  late  Color viewMessageReceiverBGColor = Color(0xFFF5F5F5);
  late  Color ratingBarDefaultColor = Color(0xFFD2D2D2);
  late Color theme3ReviewListColor = Color(0xFFFCFDFF);
  late Color searchPageBgColor = Color(0xFFFCFDFF);
  late Color reviewPayBgColor = Color(0xFFF5FAFB);

  late Color refundGreenBorderColor = Color(0xFF16C621);

  late Color messageStatusColor = Color(0xFFD23BE9);

  late Color reflectionStatusColor = Color(0xFFBD7600);
  late Color claimStatusColor = Color(0xFF9D66FE);

  late Color cancellationColor = Color(0xFFEEF3FF);

  late  Color hintTextColor = Color(0xFFb4b4b4);

  //textfieldborder
  late  Color textfieldHintColor = Color(0xFF838383);
  late  Color errorRed = Color(0xFFEC0F0F);
  late  Color mapGridFillColor = Color(0xFFDED7D6);
  late  Color mapGridLineColor = Color(0xFFCAC3C2);
  late  Color appBGColor = greyBorderColor;
  Color viewMessageOrangeColor = const Color(0xFFFFF7F0);
  Color viewMessageGreenColor = Color(0xFFF1FFF3);

  late  Color popularLocationBottomShadowColor = Color(0x5A000000);
  late  Color popularLocationtopShimmerColor = Color(0xFFF6F6F6);
  late  Color popularLocationShimmerPlaceholderColor = Colors.grey.shade300;
  late  Color calenderBookedColor = popularLocationShimmerPlaceholderColor;
  late  Color textfieldBorderColor = Color(0xFF838383);
  late  Color shimmerplaceholderColor = basecontroller.isDarkMode() ? Color(0xFF504F53) : Color(0xFFEAEAEA);
  late  Color textColor = Color(0xFF282828);
  late  Color theme3LoginArrowBackColor = Color(0xFFF5F5F5);
  late  Color placeholderColor = Color(0xFF686868);
  late  Color tabbarSecondaryColor = Color(0xFF7D7D7D);
  late  Color secondaryText = Color(0xFF7D7D7D);
  late  Color pdfplaceholderColor = Color(0xFF686868);
  late  Color viewdetailReportIconColor = Color(0xFFE8E8E8);
  late  Color filterDividerColor = Color(0xFFDDDDDD);
  late  Color tooltipBGColor = Color(0xFF484848);
  late  Color hostCalendarNotavailableColor = Color(0xFFE02B07);
  late  Color countryBottomSheetBGColor = Color(0xFFFCFDFF);
  late  Color tertiaryColor = Color(0xFF696969);

  late Color shadowColor = Color(0x14FD4D75);

  static const generateWithAIBorderColors = [
    Color(0xFFAC9AFF),
    Color(0xFF00CFB7),
    Color(0xFFC472FB),
    Color(0xFFFF4D8D),
    Color(0xFFFF565F),
    Color(0xFFFF9300),
    Color(0xFFFFAE00),
    Color(0xFFFF9B9B),
  ];

  static const regenerateTextColors = [
    Color(0xFFBD00B1),
    Color(0xFFC472FB),
    Color(0xFFFB1568),
    Color(0xFFF941FC),
    Color(0xFFFF5900),
  ];



   void changetolightMode(){
     tertiaryColor = Color(0xFF696969);
     countryBottomSheetBGColor = Color(0xFFFCFDFF);
     whiteButtonColor = staticwhite;
     hintTextColor = Color(0xFFb4b4b4);
     cancellationColor = Color(0xFFEEF3FF);
     snackBarBorderColor = Colors.transparent;
     lightYellowColor = Color(0xFFFFFBF7);
     searchPageBgColor = Color(0xFFFCFDFF);
     colorCommonLinkColor = Color(0xFF5e17eb);
     BackIconBorderColor = Color(0xFFE7E7E7);
     famousLocationBGColor = Color(0xFFF5F5F5);
     cardTheme1Color = Color(0xFFF3F3F3);
     appBGColor = Color(0xFFF8F7FD);
     viewMessageOrangeColor = Color(0xFFFFF7F0);
     viewMessageGreenColor = Color(0xFFF1FFF3);
     bottomNavBarSelectedColor = Color(0xFF5e17eb);
     bottomNavBarUnSelectedColor = Color(0xFF080A1C);
     white = Color(0xFFFFFFFF);
     black = Color(0xFF000000);
     primaryColor = lightprimaryColor;
     secondaryColor = lightsecondaryColor;
     buttonTextColor = Color(0xFFFFFFFF);
     filterDividerColor = Color(0xFFDDDDDD);
     listingItemBGColor = Color(0xFFF7F7F7);
     myTripsBGColor = Color(0xFFF5F5F5);
     theme3LoginArrowBackColor = Color(0xFFF5F5F5);
     myTripsDividerColor = Color(0xFFE0E0E0);
     replyContainer = Color(0xFFE0E0E0);
     listingItemActionsBGColor = Color(0xFFF1F1F1);
     mapGridFillColor = Color(0xFFDED7D6);
     mapGridLineColor = Color(0xFFCAC3C2);
     customTextColor = Color(0xFF131313);
     mapWidgetColor = Color(0xFF131313);
     unreadInboxBGColor = greyBorderColor.withValues(alpha:0.8);
     customBorderColor = Color(0xFFDDDDDD);
     popularLocationtopShimmerColor = Color(0xFFF6F6F6);
     popularLocationBottomShadowColor = Color(0x5A000000);
     popularLocationShimmerPlaceholderColor = Colors.grey.shade300;
     calenderBookedColor = popularLocationShimmerPlaceholderColor;
     shimmerplaceholderColor = popularLocationShimmerPlaceholderColor;
     stepChipSelectionColor = secondaryColor.withAlpha(20);
     textColor = Color(0xFF282828);
     placeholderColor = Color(0xFF686868);
     tabbarSecondaryColor = Color(0xFF7D7D7D);
     lottieColor = secondaryColor;
     profile_bg = Color(0xFFf9f9f9);
     theme3AppBg = Color(0x090B1E2E);
     listShareBGShadowColor = Color(0xFF858585);
     tooltipBGColor = Color(0xFF484848);
     viewMessageSenterBGColor = Color(0xFFedf4ff);
     viewMessageReceiverBGColor = Color(0xFFF5F5F5);
     theme4AppBarBg = Color(0xFFEEF3FF);
     theme3ReviewListColor = Color(0xFFFCFDFF);
     secondaryText = Color(0xFF7D7D7D);

     shimmerColors = [
       Color(0x4cffffff),
       Color(0xFFFFFFFF),
       Color(0xFFFFFFFF),
       Color(0x4cffffff),
     ];
   }

  void changetoDarkMode(){
    tertiaryColor = Color(0xFFC7D8EB);
    whiteButtonColor = Color(0xFF5A69D5);
    hintTextColor = const Color(0xFFC7D8EB);
    mapWidgetColor = Color(0xFFb4b4b4);
    cancellationColor = Color(0xFF0E142F);
    snackBarBorderColor = Color(0xFFE9E9E9);
    searchPageBgColor = Color(0xFF0E142F);
    famousLocationBGColor = Color(0xFF0E142F);
    appBGColor = Color(0xFF0E142F);
    viewMessageOrangeColor = Color(0xFF0E142F);
    viewMessageGreenColor = Color(0xFF0E142F);
    countryBottomSheetBGColor = Color(0xFF171D37);
    white =  Color(0xFF171D37);
    theme3LoginArrowBackColor =  Color(0xFF0E142F);
    cardTheme1Color = Color(0xFF171D37);
    lightYellowColor = Color(0xFF171D37);
    black =  Color(0xFFFFFFFF);
     primaryColor = Color(0xFF5A69D5);
     BackIconBorderColor = Color(0xFF0E142F);
     secondaryColor = Color(0xFF5A69D5);
     bottomNavBarSelectedColor = Color(0xFF5A69D5);
     bottomNavBarUnSelectedColor = Color(0xFF5A69D5);
     buttonTextColor = Color(0xFFC7D8EB);
     filterDividerColor = Colors.grey.shade800;
     customTextColor = const Color(0xFFC7D8EB);
     popularLocationtopShimmerColor = Color(0xFF504F53);
     popularLocationShimmerPlaceholderColor =popularLocationtopShimmerColor;
     shimmerplaceholderColor = popularLocationShimmerPlaceholderColor;
     popularLocationBottomShadowColor = Color(0x5AFFFFFF);
     calenderBookedColor =filterDividerColor;
     customBorderColor = filterDividerColor;
     listingItemBGColor = appBGColor;
     myTripsBGColor = appBGColor;
     unreadInboxBGColor = greyBorderColor.withValues(alpha:0.2);
     myTripsDividerColor = Color(0xFF7E7E7E);
     replyContainer = appBGColor;
     mapGridFillColor = Color(0xFF171D37);
     mapGridLineColor = Color(0xFF495275);
     listingItemActionsBGColor = appBGColor;
     stepChipSelectionColor = customTextColor.withAlpha(50);
     textColor = Color(0xFFC7D8EB);
     placeholderColor =textColor;
    tabbarSecondaryColor =textColor;
     colorCommonLinkColor = placeholderColor;
     lottieColor =  Color(0xFFFFFFFF);
     profile_bg = appBGColor;
     theme3AppBg = appBGColor;
     tooltipBGColor = placeholderColor;
     listShareBGShadowColor = white;
     viewMessageSenterBGColor = Color(0xFF333A59);
     viewMessageReceiverBGColor = Color(0xFF282D42);
     theme4AppBarBg = appBGColor;
     theme3ReviewListColor = Color(0xFF282D42);
     secondaryText = placeholderColor;

     shimmerColors = [
       Colors.grey.withAlpha(150),
       Colors.grey,
       Colors.grey,
       Colors.grey.withAlpha(150),
     ];
  }
}