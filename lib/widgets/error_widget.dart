import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/static_page/static_page_controller.dart';
import 'package:gozy/widgets/common/custom_button/secondary_button.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:restart_app/restart_app.dart';

class ErrorWidgetPage extends CustomStatefulWidget {
  final String errorTitle;
  final String exception;
  const ErrorWidgetPage({super.key,required this.errorTitle,required this.exception});

  @override
  ErrorWidgetPageState createState() =>ErrorWidgetPageState();
}

class ErrorWidgetPageState
    extends CustomStatefulWidgetState<ErrorWidgetPage> {

  var controller = Get.find<StaticContentPageController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      backIcon: Assets.drawableFilterCalendarArrow,
      body:  showBodyContent(context),
    );
  }

  Widget showBodyContent(context) {
    return
      [
        [
          20.toHeight(),
          CustomText(text: 'Error:',),
          5.toHeight(),
          CustomText(text: widget.errorTitle,fontWeight: AppFont.regular, size:AppDimen.textSize_14,),
          20.toHeight(),
          if(widget.exception.isNotEmpty)
            CustomText(text:'Error details:',),
          5.toHeight(),
          CustomText(text:widget.exception,size: AppDimen.textSize_12,fontWeight: AppFont.regular,),
          20.toHeight(),
        ].toScroll().toPad(horizontal: AppDimen.startMargin).toStretch(),
        Align(
          alignment:  Alignment.bottomCenter,
          child: IntrinsicHeight(
            child: SecondaryButton(
              buttonText: 'Refresh',
              onTap: (){
                Restart.restartApp(
                  notificationTitle: 'Restarting $APP_NAME',
                  notificationBody: 'Please tap here to open the app again.',
                );
              },
            ).toFitToDeviceWidth(),
          ),
        ),
      ].toColumn();
  }




}