import 'package:flutter/material.dart';

typedef DateValueCallback = Function(DateTime dateTime, List<int> selectedIndex);

typedef DateVoidCallback = Function();

const String DATE_PICKER_MIN_DATETIME = "1900-01-01 00:00:00";

const String DATE_PICKER_MAX_DATETIME = "2100-12-31 23:59:59";

const String DATETIME_PICKER_DATE_FORMAT = 'yyyy-MMM-dd';

const String DATETIME_PICKER_TIME_FORMAT = 'HH:mm:ss';

const String DATETIME_PICKER_DATETIME_FORMAT = 'yyyyMMdd HH:mm:ss';

const DATETIME_PICKER_BACKGROUND_COLOR = Colors.white;

const DATETIME_PICKER_SHOW_TITLE_DEFAULT = true;

const double DATETIME_PICKER_HEIGHT = 140.0;

const double DATETIME_PICKER_TITLE_HEIGHT = 36.0;

const double DATETIME_PICKER_ITEM_HEIGHT = 40.0;


const double DATETIME_PICKER_ITEM_TEXT_SIZE_SMALL = 15;
const double DATETIME_PICKER_ITEM_TEXT_SIZE_BIG = 17;