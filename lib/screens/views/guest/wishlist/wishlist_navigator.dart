import 'package:get/get.dart';
import 'package:gozy/screens/binding/wishlist_binding.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_group_item/wishlist_group_item.dart';

enum WishlistScreen { groupItem }

class WishlistNavigator {
  void navigateScreen(WishlistScreen screen, {dynamic param}) {
    switch (screen) {
      case WishlistScreen.groupItem:
        Get.to(() => WishlistGroupItemScreen(), binding: WishlistBinding(), arguments: param);
    }
  }

}