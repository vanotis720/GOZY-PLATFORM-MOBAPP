import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';

enum AppLayout {
  themeType,
  buttonType,
  inputType,
  onBoardPage,
  loginPage,
  forgotPassword,
  viewCar,
  profile,
  wishlist,
  greeting,
  recommend,
  mostViewed,
  places,
  banner,
}
enum LayoutCarIcons {
  cartype,
  make,
  model,
  year,
  transmission,
  odometer
}

class AppLayoutModel {
  int themeType;
  String backIcon;
  String deleteAccountIcon;
  String wishlistTitle;
  String shareIcon;
  String ratingIcon;
  String calendarIcon;
  String instantBookIcon;
  String profileIconType;
  String imageUploadIcon;
  int orderType;
  double borderRadius;
 bool isButtonArrowShow;
 Map<LayoutCarIcons, String> carFeatureIcons;
  AppLayoutModel({required this.themeType,required this.orderType,required this.calendarIcon,required this.deleteAccountIcon,required this.imageUploadIcon,required this.wishlistTitle,required this.borderRadius,required this.profileIconType,required this.isButtonArrowShow,required this.backIcon,required this.ratingIcon,required this.carFeatureIcons,required this.shareIcon,required this.instantBookIcon});
}



void updateAppLayout({required AppLayout layout, required dynamic element}){
  double borderRadius = AppDimen.appBorderRadius;
  String backIcon = Assets.viewcarsLeftArrow;
  String ratingIcon = Assets.drawableListingRating;
  String shareIcon = Assets.viewcarsTheme1Share;
  String imageUploadIcon = Assets.profileiconsTheme1Camera;
  String instantBookIcon = Assets.drawableInstantBook;
  String calendarIcon = Assets.theme1Calendar;
  bool isshowButtonArrow = false;
  String wishlistTitle = tabbar_theme1_wishlists;
  String deleteAccountIcon = Assets.deleteAccountDeleteAccount;
  String profileIconType = 'newcirclesecondary';
  Map<LayoutCarIcons, String> carFeatureIcons = {};
  carFeatureIcons[LayoutCarIcons.make] =Assets.viewcarsViewcarMake;
  if(layout.name == element?.name && (element?.isEnable ?? false)){
    print("Element Name--> ${element?.name} <-> ${element?.themeType}");
    switch (element?.themeType) {
      case 1:
        wishlistTitle = tabbar_theme1_wishlists;
        borderRadius = 8;
        isshowButtonArrow = true;
        carFeatureIcons[LayoutCarIcons.cartype] = Assets.viewcarsViewcarCartype;
        carFeatureIcons[LayoutCarIcons.model] = Assets.viewcarsViewcarModel;
        carFeatureIcons[LayoutCarIcons.year] = Assets.viewcarsViewcarYear;
        carFeatureIcons[LayoutCarIcons.transmission] = Assets.viewcarsViewcarTransmission;
        carFeatureIcons[LayoutCarIcons.odometer] = Assets.viewcarsViewcarOdometer;
        break;
      case 2:
        wishlistTitle = tabbar_theme1_wishlists;
        borderRadius = 0;
        deleteAccountIcon = Assets.theme2DeleteAccountDeleteAccount;
        isshowButtonArrow = false;
        ratingIcon = Assets.theme2Theme2Ratings;
        calendarIcon = Assets.theme4Calendar;
        instantBookIcon = Assets.theme2Theme2Instantbook;
        imageUploadIcon = Assets.profileiconsTheme2Camera;
        carFeatureIcons[LayoutCarIcons.cartype] = Assets.theme4ExploreCartype;
        carFeatureIcons[LayoutCarIcons.model] = Assets.theme2ViewcarModel;
        carFeatureIcons[LayoutCarIcons.year] = Assets.theme2ViewcarYear;
        carFeatureIcons[LayoutCarIcons.transmission] = Assets.viewcarsViewcarTransmission;
        carFeatureIcons[LayoutCarIcons.odometer] = Assets.theme2ViewcarOdometer;
        shareIcon = Assets.theme2ViewTheme2Share;
        profileIconType = 'newcircleprimary';
        break;
      case 3:
        borderRadius = 35;
        wishlistTitle = tabbar_theme1_wishlists;
        isshowButtonArrow = false;
        calendarIcon = Assets.theme3Calender;
        carFeatureIcons[LayoutCarIcons.cartype] = Assets.theme3CarType;
        carFeatureIcons[LayoutCarIcons.model] = Assets.viewCarModel;
        carFeatureIcons[LayoutCarIcons.year] = Assets.viewCarYear;
        carFeatureIcons[LayoutCarIcons.transmission] = Assets.theme3Transmission;
        carFeatureIcons[LayoutCarIcons.odometer] = Assets.viewCarOdometer;
        backIcon = Assets.drawableFilterCalendarArrow;
        ratingIcon = Assets.theme3Star;
        deleteAccountIcon = Assets.theme3DeleteAccountDeleteAccount;
        shareIcon = Assets.viewCarShare;
        instantBookIcon = Assets.theme3InstantBook;
        profileIconType = 'circle';
        imageUploadIcon = Assets.drawableTheme3And4Camera;
        break;
      case 4:
        calendarIcon = Assets.theme4TabbarHostCalendar;
        carFeatureIcons[LayoutCarIcons.cartype] = Assets.theme4ExploreCartype;
        wishlistTitle = tabbar_theme1_wishlists;
        borderRadius = 12;
        isshowButtonArrow = false;
        carFeatureIcons[LayoutCarIcons.transmission] = Assets.viewcarsViewcarTransmission;
        deleteAccountIcon = Assets.theme4DeleteAccountDeleteAccount;
        backIcon = Assets.theme4BackArrow;
        shareIcon = Assets.theme4ViewdetailShare;
        instantBookIcon = Assets.theme4ExploreInstantBook;
        profileIconType = 'rect';
        imageUploadIcon = Assets.drawableTheme3And4Camera;
        break;
    }
    if(element?.name == AppLayout.themeType.name){
      AppDimen.appBorderRadius = borderRadius;
      overALLThemeType = element?.themeType;

    } else if(element?.name == AppLayout.inputType.name){
      isShowTextFieldIcon = element?.themeType ==4;
    }
    appLayoutMap[layout] =
        AppLayoutModel(themeType: element?.themeType ??0, orderType: element?.orderType ??0, borderRadius: borderRadius,
            ratingIcon: ratingIcon,
            calendarIcon: calendarIcon,
            wishlistTitle: wishlistTitle,
            shareIcon: shareIcon,
            imageUploadIcon: imageUploadIcon,
            deleteAccountIcon: deleteAccountIcon,
            profileIconType:profileIconType,
            instantBookIcon:instantBookIcon,
             isButtonArrowShow: isshowButtonArrow,backIcon:backIcon,carFeatureIcons: carFeatureIcons);

    if(element?.name == AppLayout.themeType.name) {
      overALLAppLayoutModel =  appLayoutMap[layout];
    }

  }
}

Color getBackIconColor({int? themeType}){
  themeType ??= overALLThemeType;
  debugPrint("getBackIconColor : $themeType");
  return themeType == 3 ?  AppColors.staticblack :appColors.black;
}



String getTripTitle({int? themType,bool isConversion = false}){
  if(appPreference.isOwner!) {
    return label_tabbar_reservations.tr;
  }
  switch(themType ?? overALLThemeType) {
    case 1:
      return tabbar_theme1_trips.tr;
    case 2:
      return isConversion ? tabbar_theme1_trips.tr : label_theme2_trips.tr;
    case 3:
      return label_theme3_rides.tr;
    default:
      return  label_theme4_trips.tr;
  }
}

String getMessageTitle({int? themType}){
  switch(themType ?? overALLThemeType) {
    case 1:
      return tabbar_theme1_inbox.tr;
    case 2:
      return label_message.tr;
    case 3:
      return label_theme4_inbox.tr;
    default:
      return  label_theme4_inbox.tr;
  }
}