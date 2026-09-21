import 'package:get/get.dart';
import 'package:gozy/screens/views/profile/reviews/app_reviews.dart';
import 'package:gozy/screens/views/profile/reviews/write_review/write_review.dart';
import 'package:gozy/screens/views/static_page/not_found.dart';

import '../../../binding/booking_binding.dart';
import '../../../binding/profile_binding.dart';
import '../../booking/reservation_detail/reservation_detail.dart';

enum AppReviewsScreen { reservationDetail, writeReview, reviews, notFound }

class AppReviewsNavigator {
  void navigateScreen(AppReviewsScreen screen, [Map<String, dynamic>? param]) {
    switch (screen) {
      case AppReviewsScreen.reservationDetail:
        Get.to(() => ReservationDetail(), arguments: param, binding: BookingBinding());
      case AppReviewsScreen.writeReview:
        Get.off(() => WriteReview(), arguments: param, binding: BookingBinding());
      case AppReviewsScreen.notFound:
        Get.off(() => NotFound(), arguments: param, binding: ProfileBinding());
      case AppReviewsScreen.reviews:
        Get.off(() => AppReviews(), binding: ProfileBinding(), arguments: param);
    }
  }
}