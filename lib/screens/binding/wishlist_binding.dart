import 'package:get/get.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';



class WishlistBinding extends Bindings{
  WishlistBinding._privateConstructor();
  static final WishlistBinding _instance = WishlistBinding._privateConstructor();
  factory WishlistBinding() {
    return _instance;
  }
  @override
  void dependencies() {
    Get.lazyPut<WishlistModifyController>(() => WishlistModifyController(), fenix: true);
  }
}