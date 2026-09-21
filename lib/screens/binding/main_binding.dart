import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/pref/app_preference.dart';
import 'package:gozy/screens/views/guest/inbox/inbox_controller.dart';
import 'package:gozy/screens/views/guest/searched/searched_listings_controller.dart';
import 'package:gozy/screens/views/guest/view_message/view_message_controller.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail_controller.dart';
import 'package:gozy/screens/views/owner/owner_property_list/owner_property_list_controller.dart';
import 'package:gozy/screens/views/owner/property_calendar/property_calendar_controller.dart';
import 'package:gozy/screens/views/profile/edit_profile/edit_profile_controller.dart';
import 'package:gozy/screens/views/profile/reviews/write_review/write_review_controller.dart';
import 'package:gozy/screens/views/splash/splash_controller.dart';
import 'package:gozy/screens/views/static_page/static_page_controller.dart';
import 'package:gozy/widgets/bottom_sheet/add_phone_number/add_phone_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet_controller.dart';
import 'package:gozy/widgets/wishlist_modification_sheet.dart';

import '../../widgets/upload_profile/upload_profile_controller.dart';
import '../views/guest/filter/guest_filter_controller.dart';
import '../views/guest/my_trips/my_trip_list_controller.dart';
import '../views/guest/view_message/bottomsheet_controller.dart';
import '../views/profile/profile_controller.dart';
import '../views/profile/reviews/app_reviews_controller.dart';

class MainBinding extends Bindings{
  MainBinding._privateConstructor();
  static final MainBinding _instance = MainBinding._privateConstructor();
  factory MainBinding({bool? isDisableClearController}) {
    if(isDisableClearController!=null && isDisableClearController) {
      Get.delete<HomeController>();
      Get.delete<GuestFilterController>();
      Get.delete<HomeItemDetailController>();
      Get.delete<SearchedListingsController>();
      Get.delete<ProfileController>();
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      Get.lazyPut<GuestFilterController>(() => GuestFilterController(), fenix: true);
      Get.lazyPut<SearchedListingsController>(() => SearchedListingsController(), fenix: true);
      Get.lazyPut<HomeItemDetailController>(() => HomeItemDetailController(), fenix: true);
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);

    }
    return _instance;
  }
  @override
  void dependencies() {
    debugPrint('appPreference.isOwner: ${appPreference.isOwner}');
    Get.lazyPut<AppPreference>(()=> AppPreference(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<GuestFilterController>(() => GuestFilterController(), fenix: true);
    Get.lazyPut<HomeItemDetailController>(() => HomeItemDetailController(), fenix: true);
    Get.lazyPut<SearchedListingsController>(() => SearchedListingsController(), fenix: true);
    Get.lazyPut<StaticContentPageController>(() => StaticContentPageController(), fenix: true);
    Get.lazyPut<BottomSheetController>(()=> BottomSheetController(), fenix: true);
    Get.lazyPut<UploadProfileController>(()=> UploadProfileController(), fenix: true);
    Get.lazyPut<WishlistModifyController>(() => WishlistModifyController(), fenix: true);
    Get.lazyPut<WishlistModificationSheet>(()=> WishlistModificationSheet(), fenix: true);
    Get.lazyPut<HostReviewsBottomSheetController>(()=> HostReviewsBottomSheetController(), fenix: true);
    Get.lazyPut<AddPhoneController>(()=> AddPhoneController(), fenix: true);
    Get.lazyPut<AppReviewsController>(()=> AppReviewsController(), fenix: true);
    Get.lazyPut<WriteReviewController>(()=> WriteReviewController(), fenix: true);
    Get.lazyPut<EditProfileController>(()=> EditProfileController(), fenix: true);
    Get.lazyPut<ReportBottomSheetController>(()=> ReportBottomSheetController(),fenix: true);
    updateDependencies();
  }

   void updateDependencies(){
     Get.delete<MyTripListController>();
     Get.lazyPut<MyTripListController>(()=> MyTripListController(), fenix: true);
     Get.delete<InboxController>();
     Get.lazyPut<InboxController>(()=> InboxController(), fenix: true);
     Get.delete<ViewMessageController>();
     Get.lazyPut<ViewMessageController>(()=> ViewMessageController(), fenix: true);

     Get.delete<OwnerPropertyListController>();
     Get.lazyPut<OwnerPropertyListController>(()=> OwnerPropertyListController(), fenix: true);

     OwnerPropertyListController propertyListController = Get.find();
     debugPrint('controller.tabController: binding ${propertyListController.hashCode}');
     Get.delete<PropertyCalendarController>();
     Get.lazyPut<PropertyCalendarController>(()=> PropertyCalendarController(), fenix: true);

  }

}