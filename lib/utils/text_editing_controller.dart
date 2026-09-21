import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';

class CustomTextEditingController extends TextEditingController {
  // @override
  String get Ttext => value.text.trim();

  String get initalCapitalText => value.text.trim().capitalizeFirst!;

  factory CustomTextEditingController({String? text}) {
    var textcontroller = CustomTextEditingController._(text: text);
    disposableObjects.add(textcontroller);
    return textcontroller;
  }

  CustomTextEditingController._({String? text}) {
    this.text = text ?? '';
  }
}