import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import '../../screens/views/base_controller.dart';
import 'date_time_formatter.dart';
import 'date_picker_constants.dart';

const List<int> _solarMonthsOf31Days = <int>[1, 3, 5, 7, 8, 10, 12];

class DatePickerWidget extends CustomStatefulWidget {
  DatePickerWidget({
    super.key,
    this.firstDate,
    this.lastDate,
    this.titleText,
    this.confirmText,
    this.cancelText,
    this.initialDate,
    this.dateFormat = DATETIME_PICKER_DATE_FORMAT,
    this.locale,
    this.selectedDate,
    this.onCancel,
    this.onChange,
    this.onConfirm,
    this.looping = false,
  }) {
    DateTime minTime = firstDate ?? DateTime.parse(DATE_PICKER_MIN_DATETIME);
    DateTime maxTime = lastDate ?? DateTime.parse(DATE_PICKER_MAX_DATETIME);
    assert(minTime.compareTo(maxTime) < 0);
  }

  final DateTime? firstDate, lastDate, initialDate;
  final String? dateFormat;
  final String? titleText;
  final String? confirmText;
  final String? cancelText;
  final Locale? locale;
  final Rx<(String,DateTime)>? selectedDate;
  final DateVoidCallback? onCancel;
  final DateValueCallback? onChange, onConfirm;
  final bool looping;

  @override
  CustomStatefulWidgetState<CustomStatefulWidget> createState() =>
      _DatePickerWidgetState(firstDate, lastDate, initialDate);
}

class _DatePickerWidgetState extends CustomStatefulWidgetState<DatePickerWidget> {
  late DateTime _minDateTime, _maxDateTime;
  int? _currYear, _currMonth, _currDay;
  List<int>? _yearRange;
  late final RxList<int> _monthRange, _dayRange;
  FixedExtentScrollController? _yearScrollCtrl,
      _monthScrollCtrl,
      _dayScrollCtrl;

  late Map<String, FixedExtentScrollController?> _scrollCtrlMap;
  late Map<String, List<int>?> _valueRangeMap;

  bool _isChangeDateRange = false;
  bool _lock = false;
  _DatePickerWidgetState(
      DateTime? minDateTime, DateTime? maxDateTime, DateTime? initialDateTime) {
    DateTime initDateTime = initialDateTime ?? DateTime.now();
    _currYear = initDateTime.year;
    _currMonth = initDateTime.month;
    _currDay = initDateTime.day;

    _minDateTime = minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME);
    _maxDateTime = maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME);

    _yearRange = _calcYearRange();
    _currYear = min(max(_minDateTime.year, _currYear!), _maxDateTime.year);

    final monthRange = _calcMonthRange();
    _monthRange = monthRange.obs;
    _currMonth = _calcCurrentMonth();

    final dayRange = _calcDayRange();
    _dayRange = dayRange.obs;
    _currDay = min(max(_dayRange.first, _currDay!), _dayRange.last);

    _yearScrollCtrl = FixedExtentScrollController(
        initialItem: _currYear! - _yearRange!.first);
    _monthScrollCtrl = FixedExtentScrollController(
        initialItem: _currMonth! - _monthRange!.first);
    _dayScrollCtrl =
        FixedExtentScrollController(initialItem: _currDay! - _dayRange!.first);

    _scrollCtrlMap = {
      'y': _yearScrollCtrl,
      'M': _monthScrollCtrl,
      'd': _dayScrollCtrl
    };
    _valueRangeMap = {'y': _yearRange, 'M': _monthRange, 'd': _dayRange};
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        _monthRange;
        return _renderDatePickerWidget();
      }
    );
  }
  void _onSelectedChange() {
    if (widget.onChange != null) {
      DateTime dateTime = DateTime(_currYear!, _currMonth!, _currDay!);
      widget.onChange!(dateTime, _calcSelectIndexList());
    }
  }

  FixedExtentScrollController? _findScrollCtrl(String format) {
    FixedExtentScrollController? scrollCtrl;
    _scrollCtrlMap.forEach((key, value) {
      if (format.contains(key)) {
        scrollCtrl = value;
      }
    });
    return scrollCtrl;
  }

  List<int>? _findPickerItemRange(String format) {
    List<int>? valueRange;
    _valueRangeMap.forEach((key, value) {
      if (format.contains(key)) {
        valueRange = value;
      }
    });
    return valueRange;
  }

  Widget _renderDatePickerWidget() {
    List<Widget> pickers = [];
    List<String> formatArr =
        DateTimeFormatter.splitDateFormat(widget.dateFormat);
    for (var format in formatArr) {
      List<int> valueRange = _findPickerItemRange(format)!;

      Widget pickerColumn = _renderDatePickerColumnComponent(
          scrollCtrl: _findScrollCtrl(format),
          valueRange: valueRange,
          format: format,
          valueChanged: (value) {
            if (format.contains('y')) {
              _lock = true;
              _changeYearSelection(value);
              _lock = false;
            } else if (format.contains('M')) {
              if (_lock) {
                _lock = false;
                return;
              }
              _changeMonthSelection(value);
            } else if (format.contains('d')) {
              _changeDaySelection(value);
            }
          },
          fontSize: AppDimen.textSize_16);
      pickers.add(pickerColumn);
    }
    return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: pickers);
  }

  Widget _renderDatePickerColumnComponent(
      {required FixedExtentScrollController? scrollCtrl,
      required List<int> valueRange,
      required String format,
      required ValueChanged<int> valueChanged,
      double? fontSize}) {
    return Expanded(
      flex: 1,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              height: DATETIME_PICKER_HEIGHT,
              decoration:
              BoxDecoration(color: appColors.white),
              child: CupertinoPicker(
                selectionOverlay: const SizedBox.shrink(),
                backgroundColor: appColors.white,
                scrollController: scrollCtrl,
                squeeze: 1,
                diameterRatio: 2,
                itemExtent: DATETIME_PICKER_ITEM_HEIGHT,
                onSelectedItemChanged: valueChanged,
                looping: widget.looping,
                children: List<Widget>.generate(
                  valueRange.last - valueRange.first + 1,
                  (index) {
                    return _renderDatePickerItemComponent(
                      valueRange.first + index,
                      format,
                      fontSize,
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Container(
                width: 70,
                margin: const EdgeInsets.only(top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      child: Divider(
                        color: appColors.black,
                        height: 1,
                        thickness: 1.5,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02)
                  ],
                )),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: 70,
                margin: const EdgeInsets.only(top: 90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      child: Divider(
                        color: appColors.black,
                        height: 1,
                        thickness: 1.5,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  double sizeByFormat(String format) {
    if (format.contains("-MMMM") || format.contains("MMMM-")) {
      return DATETIME_PICKER_ITEM_TEXT_SIZE_SMALL;
    }

    return DATETIME_PICKER_ITEM_TEXT_SIZE_BIG;
  }

  Widget _renderDatePickerItemComponent(
      int value, String format, double? fontSize) {
    var weekday = DateTime(_currYear!, _currMonth!, value).weekday;

    return Container(
      height: DATETIME_PICKER_ITEM_HEIGHT,
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          DateTimeFormatter.formatDateTime(value, format, widget.locale, weekday),
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppFont.font,
            fontSize: AppDimen.textSize_16,
            color: appColors.customTextColor
          ),
        ),
      ),
    );
  }

  void _changeYearSelection(int index) {
    int year = _yearRange!.first + index;
    if (_currYear != year) {
      _currYear = year;
      _changeDateRange();
      _onSelectedChange();
    }
  }

  void _changeMonthSelection(int index) {

    final monthRange = _calcMonthRange();
    _monthRange.assignAll(monthRange);

    int month = _monthRange.first + index;
    if (_currMonth != month) {
      _currMonth = month;

      _changeDateRange();
      _onSelectedChange();
    }
  }

  void _changeDaySelection(int index) {
    if (_isChangeDateRange) {
      return;
    }

    int dayOfMonth = _dayRange.first + index;
    if (_currDay != dayOfMonth) {
      _currDay = dayOfMonth;
      _onSelectedChange();
    }
  }

  int? _calcCurrentMonth() {
    int? currMonth = _currMonth!;
    List<int> monthRange = _calcMonthRange();
    if (currMonth < monthRange.last) {
      currMonth = max(currMonth, monthRange.first);
    } else {
      currMonth = max(monthRange.last, monthRange.first);
    }

    return currMonth;
  }

  void _changeDateRange() {
    if (_isChangeDateRange) {
      return;
    }
    _isChangeDateRange = true;

    List<int> monthRange = _calcMonthRange();
    bool monthRangeChanged = _monthRange.first != monthRange.first ||
        _monthRange.last != monthRange.last;
    if (monthRangeChanged) {
      _currMonth = _calcCurrentMonth();
    }

    List<int> dayRange = _calcDayRange();
    bool dayRangeChanged =
        _dayRange.first != dayRange.first || _dayRange.last != dayRange.last;
    if (dayRangeChanged) {
      _currDay = max(min(_currDay!, dayRange.last), dayRange.first);
    }

    _monthRange.assignAll(monthRange);
    _dayRange.assignAll(dayRange);
    _monthRange.refresh();
    _dayRange.refresh();

    _valueRangeMap['M'] = _monthRange;
    _valueRangeMap['d'] = _dayRange;

    if (monthRangeChanged) {
      int currMonth = _currMonth!;
      _monthScrollCtrl!.jumpToItem(monthRange.last - monthRange.first);
      if (currMonth < monthRange.last) {
        _monthScrollCtrl!.jumpToItem(currMonth - monthRange.first);
      }
    }

    if (dayRangeChanged) {
      int currDay = _currDay!;

      if (currDay < dayRange.last) {
        _dayScrollCtrl!.jumpToItem(currDay - dayRange.first);
      } else {
        _dayScrollCtrl!.jumpToItem(dayRange.last - dayRange.first);
      }
    }

    _isChangeDateRange = false;
  }

  int _calcDayCountOfMonth() {
    if (_currMonth == 2) {
      return isLeapYear(_currYear!) ? 29 : 28;
    } else if (_solarMonthsOf31Days.contains(_currMonth)) {
      return 31;
    }
    return 30;
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  List<int> _calcSelectIndexList() {
    int yearIndex = _currYear! - _minDateTime.year;
    int monthIndex = _currMonth! - _monthRange!.first;
    int dayIndex = _currDay! - _dayRange!.first;
    return [yearIndex, monthIndex, dayIndex];
  }

  List<int> _calcYearRange() {
    return [_minDateTime.year, _maxDateTime.year];
  }

  List<int> _calcMonthRange() {
    int minMonth = 1, maxMonth = 12;
    int minYear = _minDateTime.year;
    int maxYear = _maxDateTime.year;
    if (minYear == _currYear) {
      minMonth = _minDateTime.month;
    }
    if (maxYear == _currYear) {
      maxMonth = _maxDateTime.month;
    }
    return [minMonth, maxMonth];
  }

  List<int> _calcDayRange({currMonth}) {
    int minDay = 1, maxDay = _calcDayCountOfMonth();
    int minYear = _minDateTime.year;
    int maxYear = _maxDateTime.year;
    int minMonth = _minDateTime.month;
    int maxMonth = _maxDateTime.month;
    currMonth ??= _currMonth;
    if (minYear == _currYear && minMonth == currMonth) {
      minDay = _minDateTime.day;
    }
    if (maxYear == _currYear && maxMonth == currMonth) {
      maxDay = _maxDateTime.day;
    }
    return [minDay, maxDay];
  }

}