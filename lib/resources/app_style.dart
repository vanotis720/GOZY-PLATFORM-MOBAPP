import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'app_dimen.dart';
import 'app_font.dart';

class AppTheme {
  ThemeData lightTheme(){
        appColors.changetolightMode();
       if (Platform.isAndroid) {
         SystemChrome.setSystemUIOverlayStyle(
           SystemUiOverlayStyle.light.copyWith(
             systemNavigationBarIconBrightness: Brightness.dark,
             systemNavigationBarColor: appColors.white,
             statusBarIconBrightness: Brightness.dark,
             statusBarColor: appColors.white,
           ),
         );
       }else {
         SystemChrome.setSystemUIOverlayStyle(
           SystemUiOverlayStyle.light.copyWith(
             statusBarBrightness: Brightness.light,
           ),
         );
       }

       final ThemeData base = ThemeData.light();
       return _getBaseThemeData(base);
  }

   ThemeData darkTheme(){
    appColors.changetoDarkMode();
       if (Platform.isAndroid) {
         SystemChrome.setSystemUIOverlayStyle(
           SystemUiOverlayStyle.dark.copyWith(
             systemNavigationBarIconBrightness: Brightness.light,
             systemNavigationBarColor: appColors.white,
             statusBarIconBrightness: Brightness.light,
             statusBarColor: appColors.white,
           ),
         );
       }else {
         SystemChrome.setSystemUIOverlayStyle(
           SystemUiOverlayStyle.dark.copyWith(
             statusBarBrightness: Brightness.dark,
           ),
         );
       }
       final ThemeData base = ThemeData.dark();
       return _getBaseThemeData(base);
   }

  ThemeData _getBaseThemeData(ThemeData base) {
     return base.copyWith(
       primaryColor: appColors.primaryColor,
       primaryColorLight: appColors.primaryColor,
       primaryColorDark: appColors.primaryColor,
       splashFactory: NoSplash.splashFactory,
       splashColor: Colors.transparent,
       highlightColor: Colors.transparent,
       textTheme: base.textTheme.apply(
         bodyColor: appColors.black,
         fontFamily: AppFont.font,
       ),


       checkboxTheme: CheckboxThemeData(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(4),
         ),
         side: WidgetStateBorderSide.resolveWith(
               (states) => BorderSide(width: 0.8, color: appColors.secondaryColor),
         ),
       ),
       scrollbarTheme:  ScrollbarThemeData(
         thumbColor: WidgetStatePropertyAll(appColors.textfieldBorderColor),
         radius:  Radius.circular(16),
         thickness: WidgetStatePropertyAll(2.5),
       ),
       appBarTheme:  AppBarTheme(
         backgroundColor: appColors.black,
         titleTextStyle: TextStyle(fontSize:AppDimen.textSize_20,
             fontFamily: AppFont.font,
             fontWeight: FontWeight.w500,color: appColors.white),
         toolbarTextStyle: TextStyle(fontSize:AppDimen.textSize_20,
             fontFamily: AppFont.font,
             fontWeight: FontWeight.w500,color: appColors.white),
       ),
       snackBarTheme:  SnackBarThemeData(
           contentTextStyle: TextStyle(
             color: appColors.white,
             fontWeight: FontWeight.w600,
             fontSize: AppDimen.textSize_16,
             fontFamily:AppFont.font,
           )
       ),
       dialogTheme:  DialogThemeData(
         backgroundColor: appColors.white,
         contentTextStyle: TextStyle(
           fontFamily: AppFont.font,
           color: appColors.black,
         ),
       ),
       inputDecorationTheme:  InputDecorationTheme(

         hintStyle: TextStyle(
           color: appColors.textfieldHintColor,
           fontSize: AppDimen.textSize_16,
           fontWeight: FontWeight.w300,
           fontFamily: AppFont.font,

         ),
         labelStyle: TextStyle(
             color: appColors.secondaryTextColor,
             fontSize: AppDimen.textSize_16,
             fontWeight: FontWeight.bold,
             fontFamily: AppFont.font
         ),
         errorStyle: TextStyle(
             color: appColors.errorRed,
             fontWeight: FontWeight.w300,
             fontSize: AppDimen.textSize_14,
             fontFamily: AppFont.font
         ),

       ),
       textSelectionTheme: TextSelectionThemeData(
         cursorColor: appColors.customTextColor,
         selectionHandleColor: Colors.transparent,
         selectionColor: appColors.greyBorderColor,
       ),
     );
  }
}