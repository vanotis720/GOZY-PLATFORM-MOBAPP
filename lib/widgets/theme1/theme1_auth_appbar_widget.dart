import 'package:flutter/material.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/theme1/theme1_auth_top_image_widget.dart';

class Theme1AuthAppbarWidget extends StatelessWidget {
  final String title;
  final List<Widget> titleWidgets;
  final GestureTapCallback? onTap;

  const Theme1AuthAppbarWidget(
      {super.key, required this.title, required this.titleWidgets, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appColors.profile_bg,
      child: [
        Theme1AuthTopImageWidget(isShowBackArrow: true, flex: 2, onTap: onTap),
        [
          10.toHeight(),
          CustomTitleText(
            text: title,
            textAlign: TextAlign.center,
            size: AppDimen.textSize_18
          ).toPad(horizontal: AppDimen.startMargin),
          15.toHeight(),
          if (titleWidgets.isNotEmpty) ...titleWidgets,
          titleWidgets.isNotEmpty ? 25.toHeight() : 10.toHeight(),
          filterDivider,
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).toScroll()
      ].toColumn(
        mainAxisSize: MainAxisSize.min,
      ),
    ).toStretch(flex: titleWidgets.isNotEmpty ? 5 : 4);
  }
}