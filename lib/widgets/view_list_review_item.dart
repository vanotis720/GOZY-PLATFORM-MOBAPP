import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_user_profile_info_text.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/flutter_rating_bar.dart';
import 'explore_listing_item_widgets.dart';

class ViewListReviewItem extends StatelessWidget {
  dynamic itemReviewsInfo;
  double width;
  bool? isExpand;
  String profileIconType;
  GestureTapCallback? onTap;
  Widget titleWidget;
  Widget? topWidget;
  Widget subtitleWidget;
  Widget? bottomWidget;
  double? borderRadius;
  bool? isDottedBorder;
  Color? fillColor;
  ValueChanged<dynamic>? onSelectedHost;

  ViewListReviewItem(
      {super.key,
      required this.itemReviewsInfo,
      required this.profileIconType,
      required this.width,
      this.isExpand,
      this.onTap,
      this.borderRadius,
      required this.titleWidget,
      this.topWidget,
      required this.subtitleWidget,
      this.bottomWidget,
      this.isDottedBorder,
      this.fillColor,
      this.onSelectedHost});

  @override
  Widget build(BuildContext context) {
    debugPrint("toReviewListItemContainer width: 12 $width");


      return [
        15.toHeight(),
        if(topWidget !=null) topWidget!
        else
          getProfileInfoWidget(),
        8.toHeight(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:60
            ),
            child: ExpandableCollapseText(
              itemReviewsInfo.reviewContent,
              onTap: isExpand==null? onTap : null,
              lastTextValueColor: appColors.secondaryColor,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        (bottomWidget !=null && topWidget != null) ?
        8.toHeight() : 0.toHeight(),
        if(bottomWidget !=null) bottomWidget!,
        if(topWidget !=null) getProfileInfoWidget(),
        8.toHeight(),
      ].toColumn(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start)
        .toReviewListItemContainer(
            borderRadius: borderRadius,
            width: width,
            isDottedBorder: isDottedBorder ?? false,
            fillColor: fillColor);
  }



  Widget getProfileInfoWidget() {
    return  toOnTap(
      onTap: () {
        onSelectedHost != null ? onSelectedHost!(itemReviewsInfo) : null;
      },
      child: [
        CustomUserProfileInfoText(
          profileIconType: profileIconType,
            userImage: itemReviewsInfo.authorData?.picture ?? '',
            placeholderWidget: itemReviewsInfo.isAdmin ?
            getAdminImage(adminimage: Assets.drawableReviewAdmin, size: 45)
                : null,
            imageSize: 50
        ).toResizeWidget(width: 60),
        8.toWidth(),
        [
          titleWidget,
          4.toHeight(),
          subtitleWidget,
        ].toColumn(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start
        ).toStretch()
      ].toRow(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center
      ),
    );
  }
}


Widget getRatingBar({required dynamic rating, String? ratingIcon,Color? iconColor}){
  return   RatingBarIndicator(
    rating: double.parse(rating.toStringAsFixed(0)),
    direction: Axis.horizontal,
    itemCount: 5,
    itemBuilder: (context, index) => (ratingIcon ??Assets.drawableListingRating).toSVG(colour: iconColor),
    itemSize: 15,
    itemPadding: pad(w: 2),
    unratedColor: Colors.transparent,
  );
}

Widget getUserNameWidget({ String? userName,String? createdAt,int? maxLines}) {
  return  ConstrainedBox(
    constraints: BoxConstraints(
        maxWidth:200
    ),
    child: getRatingTextView(
      rating: userName ?? label_admin.tr,
      isShowIcon: false,
      maxLines: maxLines,
      size: AppDimen.textSize_16,
      dotSize: createdAt!=null ? 10 : 0,
      reviews: createdAt!=null ? getDateFormat(milliSec: createdAt ,dateFormat: userProfileCreateFormat).$1 : null,
      textColor: appColors.customTextColor,
      reviewFontWeight: FontWeight.normal,
    ),
  );
}

Widget createdAtWidget({required String createdAt}){
  return CustomText(text: getDateFormat(milliSec: createdAt ,
      dateFormat: userProfileCreateFormat).$1,size: AppDimen.textSize_14,color: appColors.customTextColor,fontWeight: AppFont.regular,);
}