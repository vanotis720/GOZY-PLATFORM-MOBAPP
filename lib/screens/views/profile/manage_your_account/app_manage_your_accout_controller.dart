import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';

import '../../../../config/client.dart';
import '../../../../graphql/UserAuth/__generated__/user_auth.data.gql.dart';
import '../../../../graphql/UserAuth/__generated__/user_auth.req.gql.dart';
import '../../base_controller.dart';
import '../../home/home_navigator.dart';

class AppManageYourAccountController extends ProfileController {
  void getDeleteUseData() {
    isLoading.value = true;
    final params = GdeleteUserReq((b) => b..vars.build());

    FerryLoggerClient.makeRequest(params, this, getDeleteUseData, isBottomSheetOpen: false)?.then((res) {
      GdeleteUserData deleteUserData = res.data as GdeleteUserData;
      if (deleteUserData.deleteUser?.status == 200) {
        showToast('delete_content'.tr);
        clearLoginSession(screen: HomeScreen.splash);
      }
    });
  }
}