import 'package:get/get.dart';
import 'package:gozy/screens/views/base_controller.dart';

class BottomSheetController extends BaseController {

  RxBool isRefresh = false.obs;
  var isUpdateItemList = ReactiveVariable("isUpdateItemList", false);

  void refreshSheet() {
    isRefresh.value = isDarkMode();
    isRefresh.refresh();
  }
}