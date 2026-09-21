import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/views/base_controller.dart';

import '../../../../config/client.dart';
import '../../../../graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import '../../../../graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import '../../../../graphql/Reviews/__generated__/Reviews.data.gql.dart';
import '../../../../graphql/Reviews/__generated__/Reviews.req.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.data.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.data.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.req.gql.dart';
import '../../../../graphql/__generated__/reviews_fragment.data.gql.dart';
import '../../../../graphql/__generated__/reviews_fragment.req.gql.dart';
import '../../../../graphql/booking/getReseravtion/__generated__/get_reservation.req.gql.dart';
import '../../../../resources/app_lang.dart';
import '../../home_item_detail/home_item_detail.dart';
import 'app_review_navigator.dart';

class AppReviewsController extends BaseController {
  late TabController tabController;
  Map<ReviewAPIEnum, AppReviewModel> reviewDataMap = <ReviewAPIEnum, AppReviewModel>{};
  ReviewViewData reviewViewData = ReviewViewData();
  ReviewByYouEnum selectedReviewByYouEnum = ReviewByYouEnum.upcoming;
  ReviewAboutYouEnum selectedReviewAboutEnum = ReviewAboutYouEnum.upcoming;
  Rx<ReviewAPIEnum> selectedReviewAPIEnum = ReviewAPIEnum.reviewAboutYouUpcoming.obs;
  int? listId;
  RxBool isPaginationLoader = true.obs;
  int previousIndex = -1;
  final List<String> tabs = [AppReviewEnum.aboutYou.title.tr, AppReviewEnum.byYou.title.tr];
  PageStorageKey? aboutYouKey, byYouKey;
  AppReviewsNavigator? appReviewsNavigator;

  @override
  onReady() {
    for (var enums in ReviewAPIEnum.values) {
      reviewDataMap[enums] = AppReviewModel(
          reviewDataList: [],
          reviewDataCurrentPage: 1.obs,
          reviewDataCount: 0,
          scrollController: ScrollController(),
          pageStorageKey: PageStorageKey('$enums'));
    }
    appReviewsNavigator = AppReviewsNavigator();
    super.onReady();
  }

  AppReviewModel getReviewMapData(ReviewAPIEnum reviewAPIEnum) {
    return reviewDataMap[reviewAPIEnum] ??
        AppReviewModel(
          pageStorageKey: PageStorageKey('$reviewAPIEnum'),
          reviewDataList: [],
          reviewDataCurrentPage: 1.obs,
          reviewDataCount: 0,
          scrollController: ScrollController(),
        );
  }

  void setReviewMapData({required ReviewAPIEnum reviewAPIEnum, required AppReviewModel appReviewModel}) {
    setReviewData(reviewAPIEnum, appReviewModel);
  }

  void setReviewData(ReviewAPIEnum reviewAPIEnum, AppReviewModel appReviewModel) {
    reviewDataMap[reviewAPIEnum]?.scrollController = appReviewModel.scrollController;
    reviewDataMap[reviewAPIEnum]?.reviewDataCount = appReviewModel.reviewDataCount;
    reviewDataMap[reviewAPIEnum]?.reviewDataCurrentPage = appReviewModel.reviewDataCurrentPage;
    if (reviewDataMap[reviewAPIEnum]?.reviewDataCurrentPage.value == 1) {
      reviewDataMap[reviewAPIEnum]?.reviewDataList = appReviewModel.reviewDataList;
    } else {
      reviewDataMap[reviewAPIEnum]?.reviewDataList?.addAll(appReviewModel.reviewDataList ?? []);
    }
    isLoading.value = false;
    update();
  }

  void setReviewViewData(var propertyList, ReviewAPIEnum reviewAPIEnum) {
    bool isUpcoming = reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming;
    bool isPast = reviewAPIEnum == ReviewAPIEnum.reviewByYouPast;
    try {
      reviewViewData =
          reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming || reviewAPIEnum == ReviewAPIEnum.reviewByYouPast
              ? ReviewViewData(
                  id: isUpcoming ? propertyList?.id ?? 0 : 0,
                  firstName: getFirstName(propertyList, reviewAPIEnum),
                  title: isUpcoming ? (propertyList?.listData?.title ?? propertyList?.listTitle) : propertyList?.listData?.title,
                  profilePicture: getProfilePicture(propertyList, reviewAPIEnum),
                  listId: propertyList?.listId ?? 0,
                  reviewTitle: isUpcoming
                      ? "${label_write_review_for.tr} "
                      : "${isPast ? label_reviews_you.tr : ""} ${label_reviewed.tr} ",
                  createdAt: isUpcoming ? '0' : propertyList?.createdAt ?? '0',
                  reviewContent: isUpcoming ? '' : propertyList?.reviewContent ?? '',
                  rating: isUpcoming ? 0.0 : propertyList?.rating ?? 0.0,
                  isAdmin: isUpcoming ? false : propertyList?.isAdmin ?? false,
                  readMore: true.obs,
                  response: isUpcoming ? null : propertyList.response,
                  respondentPicture: isUpcoming ? '' : (propertyList?.response?.authorData?.picture ?? propertyList?.userData?.picture ?? ''),
                  respondentFirstName: isUpcoming ? '' : (propertyList?.userData?.firstName ?? ''),
                  respondentData: isUpcoming ? null : (propertyList?.response?.authorData ?? propertyList?.userData),
                )
              : ReviewViewData(
                  id: propertyList.reservationId ?? 0,
                  firstName: getFirstName(propertyList, reviewAPIEnum),
                  title: propertyList?.listData?.title,
                  profilePicture: getProfilePicture(propertyList, reviewAPIEnum),
                  listId: propertyList?.listId ?? 0,
                  reviewTitle: " ${label_reviewed.tr} ",
                  createdAt: isUpcoming ? '0' : propertyList?.createdAt ?? '0',
                  reviewContent: isUpcoming ? '' : propertyList?.reviewContent ?? '',
                  rating: isUpcoming ? 0.0 : propertyList?.rating ?? 0.0,
                  isAdmin: isUpcoming ? false : propertyList?.isAdmin ?? false,
                  readMore: true.obs,
                  response: propertyList.response,
                  respondentPicture: reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming ? (appPreference.profileImage ?? '') : (propertyList?.response?.authorData?.picture ?? propertyList?.authorData?.picture ?? ''),
                  respondentFirstName: reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming ? (appPreference.firstName ?? '') : (propertyList?.userData?.firstName ?? ''),
                  respondentData: reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming ? propertyList?.authorData : (propertyList?.response?.authorData ?? propertyList?.authorData));
    } catch (e) {
      debugPrint("Exception----->$e");
    }
  }

  String getProfilePicture(propertyList, ReviewAPIEnum reviewAPIEnum) {
    if (reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming) {
      return (propertyList?.hostId == appPreference.userID
              ? propertyList?.guestData?.picture
              : propertyList?.hostData?.picture) ??
          '';
    }
    return reviewAPIEnum == ReviewAPIEnum.reviewByYouPast
        ? propertyList?.authorData?.picture ?? ''
        : reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
            ? propertyList?.userData?.picture ?? ''
            : reviewAPIEnum == ReviewAPIEnum.reviewAboutYouPast
                ? propertyList?.authorData?.picture ?? ''
                : propertyList?.authorData?.picture ?? '';
  }

  dynamic getPropertyListType(propertyList, ReviewAPIEnum reviewAPIEnum) {
    if (reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming) {
      return propertyList?.hostId == appPreference.userID
          ? propertyList?.guestData
          : propertyList?.hostData;
    }
    return reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
        ? propertyList?.userData
        : reviewAPIEnum == ReviewAPIEnum.reviewAboutYouPast
            ? propertyList?.authorData
            : reviewAPIEnum == ReviewAPIEnum.reviewByYouPast
                ? propertyList?.authorData
                : (propertyList?.response?.userData ?? propertyList?.authorData);
  }

  String getFirstName(propertyList, ReviewAPIEnum reviewAPIEnum) {
    if (reviewAPIEnum == ReviewAPIEnum.reviewByYouUpcoming) {
      return '';
    }
    return reviewAPIEnum == ReviewAPIEnum.reviewAboutYouUpcoming
        ? propertyList?.userData?.firstName ?? ''
        : reviewAPIEnum == ReviewAPIEnum.reviewAboutYouPast
            ? propertyList?.authorData?.firstName ?? ''
            : reviewAPIEnum == ReviewAPIEnum.reviewByYouPast
                ? ''
                : '';
  }

  void getUserReviews({ReviewAPIEnum? reviewAPIEnum}) {
    final ReviewAPIEnum apiEnum = reviewAPIEnum ?? selectedReviewAPIEnum.value;
    isLoading.value = true;
    final params = GgetUserReviewsReq((b) => b
      ..vars.ownerType = (apiEnum == ReviewAPIEnum.reviewByYouPast || apiEnum == ReviewAPIEnum.reviewByYouUpcoming)
          ? "me"
          : "other"
      ..vars.currentPage = getReviewMapData(apiEnum).reviewDataCurrentPage.value
      ..vars.reviewType = apiEnum.ownerType
      ..vars.searchKey = ""
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, () => getUserReviews(reviewAPIEnum: apiEnum),
            isViewLoader: false, isViewErrorMessage: false)
        ?.then((res) {
      GgetUserReviewsData allReservationData = res.data as GgetUserReviewsData;
      log("Issue fixed ---> ${allReservationData}");
      setReviewMapData(
          reviewAPIEnum: apiEnum,
          appReviewModel: AppReviewModel(
            reviewDataList: allReservationData.getUserReviews?.results?.toList(),
            reviewDataCurrentPage: getReviewMapData(apiEnum).reviewDataCurrentPage,
            reviewDataCount: allReservationData.getUserReviews?.count ?? 0,
            scrollController: getReviewMapData(apiEnum).scrollController,
            pageStorageKey: getReviewMapData(apiEnum).pageStorageKey,
          ));
    });
  }

  void getPendingUserReviews({ReviewAPIEnum? reviewAPIEnum}) {
    final ReviewAPIEnum apiEnum = reviewAPIEnum ?? selectedReviewAPIEnum.value;
    final params = GgetPendingUserReviewsReq((b) => b
      ..vars.currentPage = getReviewMapData(apiEnum).reviewDataCurrentPage.value
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, () => getPendingUserReviews(reviewAPIEnum: apiEnum),
            isViewLoader: false, isViewErrorMessage: false)
        ?.then((res) {
      GgetPendingUserReviewsData allReservationData = res.data as GgetPendingUserReviewsData;
      setReviewMapData(
          reviewAPIEnum: apiEnum,
          appReviewModel: AppReviewModel(
              reviewDataList: allReservationData.getPendingUserReviews?.results?.toList(),
              reviewDataCurrentPage: getReviewMapData(apiEnum).reviewDataCurrentPage,
              reviewDataCount: allReservationData.getPendingUserReviews?.count ?? 0,
              scrollController: getReviewMapData(apiEnum).scrollController,
              pageStorageKey: getReviewMapData(apiEnum).pageStorageKey));
    });
  }

  GreviewsFragmentData? fragmentData;

  void checkListingAndReply(int listId, int reservationId, Function callBack) {
    this.listId = listId;
    final params = GviewListingDetailsReq((b) => b
      ..vars.listId = listId
      ..vars.preview = false
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, () => checkListingAndReply(listId, reservationId, callBack),
            isViewLoader: true, isViewErrorMessage: false)
        ?.then((res) {
      GviewListingDetailsData viewListingInfo = res.data as GviewListingDetailsData;
      getPendingUserReview(reservationId, callBack, viewListingInfo: viewListingInfo);
    });
  }

  void getPendingUserReview(int reservationId, Function callBack, {GviewListingDetailsData? viewListingInfo}) {
    final params = GgetPendingUserReviewReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, () => getPendingUserReview(reservationId, callBack, viewListingInfo: viewListingInfo),
            isViewLoader: true, isViewErrorMessage: false, isToGet400Message: true)
        ?.then((res) {
      GgetPendingUserReviewData allReservationData = res.data as GgetPendingUserReviewData;
      if (allReservationData.getPendingUserReview?.result?.listData == null &&
          viewListingInfo?.viewListing?.results != null) {
        var listing = viewListingInfo!.viewListing!.results!;
        allReservationData = allReservationData.rebuild((b) => b
          ..getPendingUserReview.update((b) => b
            ..result.update((b) => b
              ..listId = listing.id
              ..listData.update((b) => b
                ..id = listing.id
                ..title = listing.title
                ..transmission = listing.transmission
                ..carType = listing.carType
                ..reviewsCount = listing.reviewsCount
                ..reviewsStarRating = listing.reviewsStarRating
                ..coverPhoto = listing.coverPhoto
                ..listPhotoName = listing.listPhotoName
                ..dynamicCarType.update((b) => b
                  ..en = listing.dynamicCarType?.en
                  ..es = listing.dynamicCarType?.es
                  ..fr = listing.dynamicCarType?.fr
                  ..ar = listing.dynamicCarType?.ar
                  ..it = listing.dynamicCarType?.it
                  ..pt = listing.dynamicCarType?.pt)
                ..listPhotos?.addAll(listing.listPhotos
                        ?.map((e) => GgetPendingUserReviewData_getPendingUserReview_result_listData_listPhotos(
                            (b) => b
                              ..id = e?.id
                              ..name = e?.name))
                        .toList() ??
                    [])))));
      }
      callBack(allReservationData);
    });
  }

  (GreviewsFragmentData?, GreviewsFragmentReq) getUserReviewsInfo({required dynamic userId}) {
    GreviewsFragmentReq fragmentReq = GreviewsFragmentReq((b) => b..idFields = {'id': userId});
    GreviewsFragmentData? fragmentData = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
    return (fragmentData, fragmentReq);
  }

  Future<void> getHomeItemDetail() async {
    GviewListingDetailsFragmentData? fragData = getViewListingFragmentData(listId!);
    if (fragData == null) {
      isLoading.value = true;
      final params = GviewListingDetailsReq((b) => b
        ..vars.listId = listId
        ..vars.preview = false
        ..vars.build());
      FerryLoggerClient.makeRequest(
        params,
        this,
        getHomeItemDetail,
       isViewLoader: false,
       isToGet400Message: true
      )?.then((res) {
       isLoading.value = false;
       if(res.data.viewListing?.status!=400){
         GviewListingDetailsFragmentData? fragData = getViewListingFragmentData(listId!);
         Get.to(() => HomeItemDetailView(), arguments: [fragData, "reviewlist"]);
       }
      });
    } else {
      Get.to(() => HomeItemDetailView(), arguments: [fragData, "reviewlist"]);
    }
  }

  GviewListingDetailsFragmentData? getViewListingFragmentData(int listId) {
    GviewListingDetailsFragmentReq listingfrag =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': listId});
    GviewListingDetailsFragmentData? fragdata = FerryLoggerClient.client?.cache.readFragment(listingfrag);
    return fragdata;
  }

  void getReservation(int reservationId, Function callBack) {
    final params = GgetReservationReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.convertCurrency = appPreference.preferredCurrency
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getReservation, isViewLoader: true)?.then((res) {
      GreservationFragmentData? fragmentData = getReservationInfo(reservationId: reservationId).$1;
      isLoading.value = false;
      callBack(fragmentData);
    });
  }

  @override
  (GreservationFragmentData?, GreservationFragmentReq) getReservationInfo({required int reservationId}) {
    GreservationFragmentReq fragmentReq = GreservationFragmentReq((b) => b..idFields = {'id': reservationId});

    return (FerryLoggerClient.client?.cache.readFragment(fragmentReq), fragmentReq);
  }
}

enum AppReviewEnum {
  aboutYou(label_about_you),
  byYou(label_by_you);

  final String title;

  const AppReviewEnum(this.title);
}

enum ReviewAboutYouEnum {
  upcoming(label_responded, ReviewAPIEnum.reviewAboutYouUpcoming),
  past(label_not_responded, ReviewAPIEnum.reviewAboutYouPast);

  final String title;
  final ReviewAPIEnum reviewAPIEnum;

  const ReviewAboutYouEnum(this.title, this.reviewAPIEnum);
}

enum ReviewByYouEnum {
  upcoming(label_upcoming, ReviewAPIEnum.reviewByYouUpcoming),
  past(label_past, ReviewAPIEnum.reviewByYouPast);

  final String title;
  final ReviewAPIEnum reviewAPIEnum;

  const ReviewByYouEnum(this.title, this.reviewAPIEnum);
}

enum ReviewAPIEnum {
  reviewAboutYouUpcoming("responded"),
  reviewAboutYouPast("notResponded"),
  reviewByYouUpcoming("me"),
  reviewByYouPast(""),
  reviewNone("");

  final String ownerType;

  const ReviewAPIEnum(this.ownerType);
}

class ReviewViewData {
  String? firstName;
  int? listId;
  int? id;
  String? profilePicture;
  String? reviewTitle;
  String? title;
  String? reviewContent;
  dynamic rating;
  dynamic createdAt;
  bool? isAdmin;
  RxBool? readMore;
  dynamic response;
  String respondentPicture = "";
  String respondentFirstName = "";
  dynamic respondentData;

  ReviewViewData(
      {this.id = 0,
      this.firstName = "",
      this.listId = 0,
      this.title,
      this.profilePicture = "",
      this.reviewTitle = "",
      this.createdAt = '0',
      this.rating = 0.0,
      this.reviewContent = "",
      this.isAdmin = false,
      this.readMore,
      this.response,
      this.respondentPicture = "",
      this.respondentFirstName = "",
      this.respondentData});

  @override
  String toString() {
    return 'ReviewViewData('
        'id: $id, '
        'listId: $listId, '
        'firstName: $firstName, '
        'title: $title, '
        'reviewTitle: $reviewTitle, '
        'reviewContent: $reviewContent, '
        'rating: $rating, '
        'createdAt: $createdAt, '
        'isAdmin: $isAdmin, '
        'profilePicture: $profilePicture, '
        'readMore: ${readMore?.value}, '
        'response: $response'
        ')';
  }
}

class AppReviewModel {
  List<dynamic>? reviewDataList;
  int reviewDataCount;
  RxInt reviewDataCurrentPage;
  ScrollController scrollController;
  PageStorageKey pageStorageKey;
  String? selectedType;

  AppReviewModel(
      {required this.reviewDataList,
      required this.reviewDataCount,
      required this.reviewDataCurrentPage,
      required this.scrollController,
      required this.pageStorageKey,
      this.selectedType});
}