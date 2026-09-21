import 'package:get/get.dart';

import '../../../../../config/client.dart';
import '../../../../../graphql/Reviews/__generated__/Reviews.data.gql.dart';
import '../../../../../graphql/Reviews/__generated__/Reviews.req.gql.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../utils/text_editing_controller.dart';
import '../app_reviews_controller.dart';

class WriteReviewController extends AppReviewsController {
  GgetPendingUserReviewData? itemInfo;
  String page = '';
  double ratingCount = 0.0;
  CustomTextEditingController ratingDescriptionController = CustomTextEditingController();

  void writeUserReview(Function callBack) {
    final params = GwriteUserReviewReq((b) => b
      ..vars.reservationId = itemInfo?.getPendingUserReview?.result?.id ?? 0
      ..vars.listId = itemInfo?.getPendingUserReview?.result?.listId ?? 0
      ..vars.reviewContent = ratingDescriptionController.Ttext
      ..vars.rating = ratingCount
      ..vars.receiverId =
          appPreference.userID.toString().contains(itemInfo?.getPendingUserReview?.result?.guestId ?? '')
              ? itemInfo?.getPendingUserReview?.result?.hostId
              : itemInfo?.getPendingUserReview?.result?.guestId
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, writeUserReview,
            isViewLoader: false, isViewErrorMessage: false)
        ?.then((res) {
      GwriteUserReviewData allReservationData = res.data as GwriteUserReviewData;
      callBack(allReservationData);
    });
  }

  bool validateInput() {
    if (ratingCount == 0.0) {
      showSnackBar(error_msg_empty.trParams({'field': label_over_all_rating.tr.toLowerCase()}), isltralign: true);
      return false;
    } else if (ratingDescriptionController.Ttext.isEmpty) {
      showSnackBar(error_msg_empty.trParams({'field': title_description.tr.toLowerCase()}), isltralign: true);
      return false;
    } else {
      return true;
    }
  }
}