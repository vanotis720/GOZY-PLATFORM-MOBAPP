import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/wishlist/__generated__/wishlist.data.gql.dart';
import 'package:gozy/graphql/wishlist/__generated__/wishlist.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../home/home_controller.dart';
import '../searched/searched_listings_controller.dart';

class WishlistModifyController extends BaseController {
  String? name;
  int? listingId,
      wishListGroupId,
      argumentGroupId,
      overallWishlistCount = 0,
      overallWishlistGroupItemsCount = 0;
  RxInt wishlistCurrentpage = 1.obs;
  RxInt wishlistGroupsCurrentpage = 1.obs;
  List<dynamic> wishlistGroupItemList = [];
  CustomTextEditingController groupTitleEditingController = CustomTextEditingController();
  CustomFocusNode groupTitleFocusNode = CustomFocusNode();
  List<Map<String, dynamic>> allWishListGroupList = [];
  bool isBottomSheetOpen = false;
  RxBool isAddItemToGroup = true.obs;
  RxBool isViewScreen = false.obs;
  RxString updatedGroupName = ''.obs;
  int centerloadingIndex = -1;
  bool isLoadAllItems = false;
  ScrollController wishlistGroupScrollController = ScrollController();
  ScrollController wishlistGroupItemScrollController = ScrollController();

  late AnimationController wishlistViewAnimation;

  void checkValidate() {
    if (groupTitleEditingController.Ttext.isEmpty) {
      showToast(error_msg_empty.trParams({'field': label_the_title_of_wishlist_group.tr}));
    } else {
      change(rxVariable: isRxBottomSheetLoading, value: true);
      checkNetwork(createWishlistGroup);
    }
  }

  void createWishlistGroup() {
    change(rxVariable: isRxBottomSheetLoading, value: true);
    final params = GCreateWishListGroupReq((b) => b
      ..vars.name = groupTitleEditingController.Ttext
      ..vars.id = wishListGroupId
      ..vars.build());
    FerryLoggerClient.makeRequest(
            params, this, isViewErrorMessage: true, createWishlistGroup, isBottomSheetOpen: isBottomSheetOpen)
        ?.then((res) {
      GCreateWishListGroupData createWishListGroupData = res.data as GCreateWishListGroupData;
      debugPrint("emftrt:$wishListGroupId---${allWishListGroupList.length}");
      if (wishListGroupId != null) {
        for (var element in allWishListGroupList) {
          if (element['id'].toString() == wishListGroupId.toString()) {
            element['name'] = groupTitleEditingController.Ttext;
            debugPrint("updatedGroupName value: ${element['name']}");
            updatedGroupName.value = element['name'];
            break;
          }
        }
        change(rxVariable: isRxBottomSheetLoading, value: false);
        isLoading.value = false;
        Get.back();
        isShowLoader = false;
        Get.forceAppUpdate();
      } else {
        wishListGroupId = createWishListGroupData.CreateWishListGroup?.results?.id;
        if (listingId != null) {
          isAddItemToGroup.value = true;
          checkNetwork(updateItemToWishlistGroup);
          Get.back();
        } else {
          change(rxVariable: isRxBottomSheetLoading, value: false);
        }
      }
    });
  }

  void updateItemToWishlistGroup() {
    change(rxVariable: isRxBottomSheetLoading, value: (Get.isBottomSheetOpen ?? false));
    final params = GCreateWishListReq((b) => b
      ..vars.listId = listingId
      ..vars.wishListGroupId = wishListGroupId
      ..vars.eventKey = isAddItemToGroup.value
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, updateItemToWishlistGroup,
            isBottomSheetOpen: isBottomSheetOpen,
            isToGet400Message: true,
            isViewErrorMessage: false,
            isViewLoader: !(argumentGroupId != null && argumentGroupId == wishListGroupId))
        ?.then((res) {
      GCreateWishListData createWishListData = res.data as GCreateWishListData;
      if (createWishListData.CreateWishList?.status != 200 &&
          createWishListData.CreateWishList?.errorMessage != null) {
        showToast(createWishListData.CreateWishList?.errorMessage ?? '');
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
      } else {
        if (listingId != null) {
          _removeWishlistForListing(listingId!, updateValue: isAddItemToGroup.value);
          if (isAddItemToGroup.value) {
            wishlistedIds.add(listingId!);
          } else {
            wishlistedIds.remove(listingId!);
          }
          Get.find<HomeController>().update();
          if (Get.isRegistered<SearchedListingsController>()) {
            Get.find<SearchedListingsController>().update();
          }
        }
        checkNetwork(getAllWishlistWithGroup);
      }
    });
  }


  void getAllWishlistWithGroup() {
    int count = 0;
    for (var element in allWishListGroupList) {
      bool isdelete = (element['isdelete'] != null && element['isdelete']);
      if (isdelete) {
        count++;
      }
    }
    if(count !=0 && (wishlistCurrentpage.value > 1)) {
      wishlistCurrentpage.value = wishlistCurrentpage.value-1;
    }

    final params = GgetAllWishListGroupReq((b) {
      if (!isLoadAllItems) {
        b.vars.currentPage = wishlistCurrentpage.value;
      }
      b.vars.build();
    });
    FerryLoggerClient.makeRequest(params, this, getAllWishlistWithGroup,
            isBottomSheetOpen: Get.isBottomSheetOpen ?? false,
            isViewLoader: false,
            isToGet400Message: true,
            isViewErrorMessage: false)
        ?.then((res) {
      GgetAllWishListGroupData wishlistgroup = res.data as GgetAllWishListGroupData;
      if (wishlistgroup.getAllWishListGroup?.count != null) {
        overallWishlistCount = wishlistgroup.getAllWishListGroup?.count;
      }
      print("Condition--> ${wishlistCurrentpage.value} <-> $count");

      if(wishlistCurrentpage.value == 1) allWishListGroupList.clear();
      if(wishlistgroup.getAllWishListGroup!.results !=null){
        List<int> newwistlistIds = [];
        List.generate(wishlistgroup.getAllWishListGroup!.results!.toList().length, (index) {
          Map<String, dynamic> wishlistgroupmap =
              wishlistgroup.getAllWishListGroup!.results![index]!.toJson();
          wishlistgroup.getAllWishListGroup!.results![index]!.wishLists?.toList().forEach((idElement) {
            newwistlistIds.add(idElement?.listId ?? 1);
          });
          allWishListGroupList.add(wishlistgroupmap);

        });
      }
      isLoading.value = false;
      centerloadingIndex = -1;
      change(rxVariable: isRxBottomSheetLoading, value: false);
      WidgetsFlutterBinding.ensureInitialized().performReassemble();
    });
  }

  @override
  void dispose() {
    allWishListGroupList.clear();
    super.dispose();
  }

  void deleteWishlistGroup() {
    final params = GDeleteWishListGroupReq((b) => b
      ..vars.id = wishListGroupId
      ..vars.build());
    FerryLoggerClient.makeRequest(
            params, this, isViewErrorMessage: true, deleteWishlistGroup, isViewLoader: false)
        ?.then((res) {
      List<int> deleteidlist = [];
      for (var element in allWishListGroupList) {
        bool isdelete = (element['id'] == wishListGroupId);
        if (isdelete) {
          element['wishLists'].forEach((idelement) {
            deleteidlist.add(idelement?['listId']);
          });
          element['isdelete'] = true;
        }
      }

      for (var element in allWishListGroupList) {
        if (element['wishLists'] != null) {
          List<dynamic> idlist = List.from(element['wishLists']);
          for (var idelement in idlist) {
            if (deleteidlist == idelement?['listId']) {
              deleteidlist.remove(idelement?['listId']);
            }
          }
        }
      }

      for (var element in deleteidlist) {
        _removeWishlistForListing(element);
      }

      overallWishlistCount = (overallWishlistCount! - 1);
      if (overallWishlistCount == 0) {
        allWishListGroupList.removeWhere((element) {
          bool isdelete = (element['isdelete'] != null && element['isdelete']);
          return isdelete;
        });
      } else if (overallWishlistCount != 0) {
        int count = 0;
        for (var element in allWishListGroupList) {
          bool isdelete = (element['isdelete'] != null && element['isdelete']);
          if (isdelete) count++;
        }
        if (count == allWishListGroupList.length) {
          checkNetwork(getAllWishlistWithGroup);
        }
      }

      wishListGroupId = null;
      isLoading.value = false;
      wishlistViewAnimation.reverse();
      isViewScreen.value = false;
    });
  }

  int appendEmptyItemAtEnd() {
    int count = 0;
    allWishListGroupList.removeWhere((element) {
      bool isdelete = (element['isdelete'] != null && element['isdelete']);
      if (isdelete) {
        count++;
      }
      return isdelete;
    });

    List.generate(count, (index) {
      Map<String, dynamic> map = {};
      map['isdelete'] = true;
      allWishListGroupList.add(map);
    });
    return count;
  }

  void getWishListGroup() {
    if (wishListGroupId == null) return;
    final params = GgetWishListGroupReq((b) => b
      ..vars.id = wishListGroupId
      ..vars.currentPage = wishlistGroupsCurrentpage.value
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, getWishListGroup, isViewLoader: false)?.then((res) {
      GgetWishListGroupData wishlistgroupItems = res.data as GgetWishListGroupData;
      wishlistGroupItemScrollController = ScrollController();
      if (wishlistgroupItems.getWishListGroup?.results?.wishListCount != null) {
        overallWishlistGroupItemsCount = wishlistgroupItems.getWishListGroup?.results?.wishListCount;
      }
      List<dynamic> wistlists = wishlistgroupItems.getWishListGroup!.results!.wishLists?.toList() ?? [];

      if (wistlists.isNotEmpty) {
        for (var element in allWishListGroupList) {
          if (element['id'] == wishListGroupId) {
            element['wishListCount'] = overallWishlistGroupItemsCount;
            Map<String, dynamic> listDatamap1 = {};
            if (overallWishlistGroupItemsCount! > 0) {
              listDatamap1 = wistlists[0]?.toJson();
            }
            element['wishListCover'] = listDatamap1;
            element['name'] = wishlistgroupItems.getWishListGroup?.results?.name ?? "";

            List<dynamic> idlist = List.from(element['wishLists']);
            if (idlist.isNotEmpty) {
              idlist[0] = listDatamap1;
            }

            element['wishLists'] = idlist;
          }
        }
        if (wishlistGroupsCurrentpage.value == 1) {
          wishlistGroupItemList = wistlists;
        } else {
          wishlistGroupItemList = wishlistGroupItemList + wistlists;
        }
      }
      isLoading.value = false;
    });
  }


  bool _removeWishlistForListing(int id, {bool? updateValue}) {
    final data = getShortListingFragmentData(id: id);
    final fragment = data.$1;
    if (fragment == null) return false;
    bool prevWishlistStatus = data.$1?.wishListStatus ?? false;
    if (FerryLoggerClient.client?.cache != null) {
      FerryLoggerClient.client?.cache.writeFragment(
        data.$2,
        data.$1?.rebuild((b) => b..wishListStatus = updateValue ?? false),
      );
    }
    debugPrint('_removeWishlistForListing: $id --- $updateValue');
    return prevWishlistStatus != updateValue;
  }

}