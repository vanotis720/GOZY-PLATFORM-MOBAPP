import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef TabBarItemModel = ({
int totalCount,
RxInt listCurrentpage,
ScrollController tabliistScrollController,
PageStorageKey pageStorageKey,
List<dynamic> tabBarListData,
bool isTabLoading,
String type,
List<dynamic>? nonFilterTabBarListData,
});