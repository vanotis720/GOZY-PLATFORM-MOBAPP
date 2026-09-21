import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/widgets/common/custom_painter/custom_tooltip_painter.dart';
import 'package:gozy/widgets/custom_tool_tip.dart';
import 'package:gozy/widgets/rect_getter.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_underline_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {
        super.key,
        this.hintText,
        this.controller,
        this.textInputAction,
        this.focusNode,
        this.hintTextColor,
        this.textColor,
        this.textSize,
        this.filteringTextInputFormatter,
        this.enabled,
        this.isDense,
        this.textFieldText,
        this.minLines,
        this.textAlign,
        this.isDigitOnly,
        this.maxLines,
        this.textDirection,
        this.autofocus,
        this.filled,
        this.fillColor,
        this.inputBorder,
        this.obscureText,
        this.characterlength,
        this.keyboardType,
        this.hintFontWeight,
        this.enableSuggestions,
        this.onSubmitted,
        this.onChanged,
        this.isReadOnly,
        this.isCharOnly,
        this.textCapitalization,
        this.isTextAlignChange,
        this.contentPadding,
        this.textOverFlow

      }
      );


  TextEditingController? controller;
  TextCapitalization? textCapitalization;
  String? hintText;
  TextInputAction? textInputAction;
  ValueChanged<String>? onSubmitted;
  ValueChanged<String>? onChanged;
  TextInputType? keyboardType;
  List<TextInputFormatter>? filteringTextInputFormatter;
  Color? hintTextColor;
  Color? textColor;
  Color? fillColor;
  InputBorder? inputBorder;
  TextDirection? textDirection;
  TextAlign? textAlign;
  RxString? textFieldText;
  bool? isTextAlignChange;
  FontWeight? hintFontWeight;
  FocusNode? focusNode = FocusNode();
  bool? isDigitOnly = false;
  bool? isCharOnly = false;
  bool? filled;
  bool? autofocus = false;
  bool? isEditable = true;
  int? characterlength = 5000;
  int? minLines;
  int? maxLines;
  bool? enabled = true;
  bool? obscureText;
  bool? isReadOnly;
  bool? enableSuggestions;
  bool? isDense;
  double? textSize;
  RxBool updateTextfield = false.obs;
  EdgeInsetsGeometry? contentPadding;
  TextOverflow? textOverFlow;

  @override
  Widget build(BuildContext context) {
    debugPrint("customtextfieldobscureText: ${obscureText}");
    if(keyboardType == TextInputType.emailAddress) {
      characterlength = 250;
    }
    List<TextInputFormatter>?  textFormatter = <TextInputFormatter>[
      LengthLimitingTextInputFormatter(characterlength),
    ];
    if(isDigitOnly !=null && isDigitOnly!) {
      textFormatter.add(FilteringTextInputFormatter.digitsOnly);
    }
    if(filteringTextInputFormatter !=null) {
      textFormatter.addAll(filteringTextInputFormatter!);
    }
    if(keyboardType == TextInputType.emailAddress) {
      textFormatter.add(FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9.@-]")));
    }
    if(isCharOnly ?? false) {
      textFormatter.add(
          FilteringTextInputFormatter.allow(
            RegExp(r'[A-Za-z0-9@._\-!#\$%^&*()₹]+'),
          )
      );
    }

   if(isTextAlignChange ?? false) {
     textAlign =  intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ?TextAlign.start : TextAlign.end;
     textDirection =  TextDirection.ltr;
   } else {
     textAlign =  intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ?TextAlign.end : TextAlign.start;
     textDirection =  TextDirection.ltr;
   }


    return Obx(() {
     return Theme(
       data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionColor: appColors.secondaryColor.withValues(alpha: 0.4), cursorColor: appColors.black)),
       child: TextField(
         readOnly: isReadOnly?? false,
        controller: controller,
        autofocus: autofocus ?? false,
         cursorOpacityAnimates: false,
        cursorColor: appColors.black,
        selectionControls: customMaterialTextSelectionControls(appColors.secondaryColor.withValues(alpha: 0.4)),
      inputFormatters: textFormatter,
      textInputAction: textInputAction,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
       textDirection: updateTextfield.value ? (intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ?  TextDirection.rtl : TextDirection.ltr) : textDirection,
       textAlign: (isTextAlignChange ?? false) ? textAlign! : (updateTextfield.value ?  TextAlign.start: (textAlign ?? TextAlign.start)),
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      scrollPadding: EdgeInsets.only(bottom:  bottomViewPadding+60),
      contextMenuBuilder: (context,editableTextState){
        final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
        debugPrint("contextMenuBuilder: $buttonItems");
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
    onChanged: (value){
      if(value.isNotEmpty && value[value.length-1] != ' ') {
        updateTextfield.value = intl.Bidi.detectRtlDirectionality(value[value.length-1]);
      }
      textFieldText?.value = value;
    if(onChanged !=null) {
      onChanged!(value);
    }
    },
        enableSuggestions: enableSuggestions ?? false,
        autocorrect: false,
        magnifierConfiguration : TextMagnifierConfiguration.disabled,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        enabled: enabled,
        decoration: InputDecoration(
          contentPadding:contentPadding ?? EdgeInsetsDirectional.only(end: 6.0, start: appLayoutMap[AppLayout.inputType]?.themeType == 3 ? 4 : 0, bottom: 0, top: 0),
          border: inputBorder ?? InputBorder.none,
          hintText:hintText,
          isDense: isDense,
          filled: filled,
          fillColor: fillColor,
          hintTextDirection: textDirection,
          maintainHintSize: false,
          hintStyle:  TextStyle(
            color: hintTextColor??appColors.textFieldInActiveIconColor,
            fontSize:  AppDimen.textSize_16,
            fontWeight: FontWeight.w300,
            fontFamily: AppFont.font
          ),
        ),
        style: TextStyle(
          overflow: textOverFlow,
        color: textColor ?? appColors.customTextColor,
        decorationThickness: 0,
          letterSpacing:  -0.1,
        fontSize: textSize ?? AppDimen.textSize_16,
            fontFamily: AppFont.font
      ),
      ),
    );
    });
  }
}

class TitleTextField extends StatelessWidget  {
  TitleTextField(
      {
        super.key,
        this.hintText,
        this.controller,
        this.textInputAction,
        this.suffixIconWidget,
        this.suffixIconQuarterTurns,
        this.suffixIcon,
        this.suffixIconSize,
         this.title,
        this.keyboardType,
        this.textCapitalization,
        this.filteringTextInputFormatter,
        this.onTap,
        this.onChanged,
        this.minLines,
        this.maxLines,
        this.borderTextfieldPadding,
        this.characterlength,
        this.textfieldType,
        this.isPasswordVisible,
        this.focusNode,
        this.onSubmitted,
        this.enabled,
        this.applayout,
        this.borderWidth,
        this.isDense,
        this.hintTextColor,
        this.isReadOnly,
        this.contentPadding,
       this.textOverFlow,
       this.tooltipcontent,
      }
      );
  TextEditingController? controller;
  String? hintText;
  String? title;
  double? suffixIconSize;
  Widget? suffixIconWidget;
  String? suffixIcon;
  TextInputType? keyboardType;
  int? suffixIconQuarterTurns;
  TextCapitalization? textCapitalization;
  ValueChanged<String>? onSubmitted;
  ValueChanged<String>? onChanged;
  TextInputAction? textInputAction;
  GestureTapCallback? onTap;
  EdgeInsetsGeometry? borderTextfieldPadding;
  List<TextInputFormatter>? filteringTextInputFormatter;
  FocusNode? focusNode;
  bool? enabled;
  bool? isDense;
  String? textfieldType;
  Color? hintTextColor;
  int? characterlength;
  int? minLines;
  double? borderWidth;
  AppLayout? applayout;
  int? maxLines;
  RxBool? isPasswordVisible;
  bool? isReadOnly;
  EdgeInsetsGeometry? contentPadding;
  TextOverflow? textOverFlow;
  String? tooltipcontent;

  Widget _getToolTips() {
    CustomTooltipPainter customShapePointer = CustomTooltipPainter(
      isItemSelected: true,
      borderRadius: 6,
      fontSize: AppDimen.textSize_14,
      isDisableStroke: true,
      contentBGColor: appColors.black,
      padding: overALLThemeType == 3
          ? EdgeInsets.only(left: 18, right: 18, bottom: 7, top: 5)
          : null,
      textColor: appColors.white,
      content: tooltipcontent ?? ""
    );

    return getToolTipWidget(
      customShapePointer: customShapePointer,
      startMargin: 6,
      controller: basecontroller,
      globalKey: RectGetter.createGlobalKey(),
      pagetype: 'textfield',
      overlayWidget: Assets.drawableInfoToolTip.toSVG(size: 13, fit: BoxFit.scaleDown, colour: AppColors.staticblack),
    );
  }

  @override
  Widget build(BuildContext context) {
    int theme = appLayoutMap[applayout ?? AppLayout.inputType]?.themeType ?? 1;
    double borderRadius = appLayoutMap[applayout ?? AppLayout.inputType]?.borderRadius ?? 1;

    bool? isunderline = theme ==4;
    debugPrint("borderTextfieldPadding: ${borderTextfieldPadding}");
    if(borderTextfieldPadding !=null)
    borderTextfieldPadding!.add(pad(w:18));
    else
      borderTextfieldPadding = pad(w:18);
    return [
      if (title != null && title!.isNotEmpty)
        [
          CustomTitleText(
            text: title!,
            size: AppDimen.textSize_18,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).toStretch(isExpanded: false),
          if (tooltipcontent != null && tooltipcontent!.isNotEmpty)
            _getToolTips().toPad(top: 2)
        ].toRow(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center)
         .toPad(bottom: (isunderline ?? false) ? 0 : 10),
      toOnTap(
        onTap: onTap,
        child: Obx(() {
          changeTextFieldFocus.value;
          return (isunderline == null)
              ? Container(
                  padding: borderTextfieldPadding,
                  color: theme == 3 ? appColors.white : null,
                  child: getTextFieldItem(),
                )
              : isunderline
                  ? CustomUnderlineContainer(
                      padding: theme == 4
                          ? pad(start: 0, end: 18)
                          : borderTextfieldPadding,
                      borderColor: (focusNode?.hasFocus ?? false)
                          ? appColors.black
                          : (theme == 3 ? appColors.customBorderColor : null),
                      body: getTextFieldItem(),
                    )
                  : CustomBorderContainer(
                      padding: borderTextfieldPadding,
                      borderColor: (focusNode?.hasFocus ?? false)
                          ? appColors.black
                          : (theme == 3 ? appColors.customBorderColor : null),
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      color: theme == 3 ? appColors.white : null,
                      body: getTextFieldItem(),
                    );
        }),
      ),
    ].toColumn();
  }

  Widget getTextFieldItem(){
    return  [

      Expanded(
        child:
        Theme(
          data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionColor: appColors.secondaryColor.withValues(alpha: 0.2), cursorColor: appColors.black)),
          child:
          CustomTextField(
            textColor:  appColors.customTextColor,
            isReadOnly: isReadOnly,
            hintText: hintText ?? title,
            controller: controller,
            obscureText: isPasswordVisible?.value,
            textInputAction: textInputAction,
            enabled: enabled,
            isDense: isDense,
            hintTextColor: hintTextColor,
            onChanged: onChanged,
            keyboardType: keyboardType,
            filteringTextInputFormatter: filteringTextInputFormatter,
            characterlength: characterlength,
            onSubmitted:onSubmitted,
            maxLines:maxLines ?? 1,
            minLines:minLines ?? 1,
            textCapitalization: textCapitalization,
            focusNode: focusNode,
            contentPadding: contentPadding,
            textOverFlow: textOverFlow,
            isCharOnly: textfieldType =='password',
          ),
        ),
      ),

      if( textfieldType =='password') 15.toWidth(),
      if( textfieldType =='password')
        toOnTap(
            isRetainFocus: true,
            onTap: (){
              if(isPasswordVisible !=null)
                isPasswordVisible?.value = !isPasswordVisible!.value;
            },
            child: (isPasswordVisible !=null && isPasswordVisible!.value ? Assets.drawablePasswordInvisible : Assets.drawablePasswordVisible ).toSVG(colour: appColors.black)
        ),
      if(suffixIconWidget!=null)
        suffixIconWidget!,
      if( suffixIcon!=null)
        !(suffixIcon!.contains('.png'))?
        suffixIcon!.toSVG(
        colour:  appColors.black,
        quarterTurns: suffixIconQuarterTurns,
        size: suffixIconSize ?? 12,
      ) : suffixIcon!.toPng(
          colour:  appColors.black,
          quarterTurns: suffixIconQuarterTurns,
          width: suffixIconSize ?? 12,
          height: suffixIconSize ?? 12,
        ),
    ].toRow();
  }

}

class customMaterialTextSelectionControls extends MaterialTextSelectionControls {
  customMaterialTextSelectionControls(this.handleColor);
  final Color handleColor;
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) =>
      TextSelectionTheme(
          data: TextSelectionThemeData(selectionHandleColor: handleColor),
          child: Builder(builder: builder));
  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return _wrapWithThemeData((BuildContext context) =>
        super.buildHandle(context, type, textLineHeight));
  }
}