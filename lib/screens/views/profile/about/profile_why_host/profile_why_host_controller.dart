import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'dart:async';
import '../../../../../config/client.dart';
import '../../../../../graphql/getWhyHostData/__generated__/getWhyHostData.data.gql.dart';
import '../../../../../graphql/getWhyHostData/__generated__/getWhyHostData.req.gql.dart';
import '../../../owner/owner_property_list/owner_property_list_controller.dart';


class ProfileWhyHostController extends OwnerPropertyListController {

  GgetWhyHostDataData?  getWhyHostData;
  PageController? hostPageController;
  var rxCurrentPage = ReactiveVariable('rxCurrentPage', 0);


  Future<bool> getWhyHost() {
    isLoading.value = true;
    final Completer<bool> completer = Completer<bool>();
    final params = GgetWhyHostDataReq((b) => b..vars.build());
    FerryLoggerClient.makeRequest(params, this, getWhyHost, isBottomSheetOpen: true)?.then((res) async {
      getWhyHostData = await res.data as GgetWhyHostDataData;
      isLoading.value = false;
      completer.complete(true);
    }).catchError((error) {
      isLoading.value = false;
      completer.completeError(error);
    });
    return completer.future;
  }
}