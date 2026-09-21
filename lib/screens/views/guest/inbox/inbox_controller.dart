import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/__generated__/all_thread_fragment.data.gql.dart';
import 'package:gozy/graphql/__generated__/all_thread_fragment.req.gql.dart';
import 'package:gozy/graphql/inbox/__generated__/Inbox.data.gql.dart';
import 'package:gozy/graphql/inbox/__generated__/Inbox.req.gql.dart';
import 'package:gozy/screens/views/guest/my_trips/my_trip_list_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';

import '../../../../constant.dart';

class InboxController extends MyTripListController {
  RxInt inboxCurrentpage = 1.obs;
  List<GgetAllThreadsData_getAllThreads_results?>? inboxList = [];
  int inboxListCount =0;
  ScrollController inboxScrollController = ScrollController();
  HomeNavigator? homeNavigator;
  @override
  void onReady(){
    homeNavigator = HomeNavigator();
    super.onReady();
  }
  getAllThreads(){
    final params = GgetAllThreadsReq((b) =>
    b
      ..vars.threadType = appPreference.isOwner! ? 'owner' : 'renter'
      ..vars.currentPage = inboxCurrentpage.value
      ..vars.build());
    FerryLoggerClient.makeRequest(params,this, getAllThreads,isViewLoader: false,isAutoCloseLoader: false)?.then((res) {
      GgetAllThreadsData allThreadsData = res.data as GgetAllThreadsData;
      if(inboxCurrentpage.value ==1) {
        inboxList = allThreadsData.getAllThreads?.results?.toList();
      } else {
        inboxList?.addAll(allThreadsData.getAllThreads?.results?.toList() ?? []);
      }
      debugPrint("removeWhere.id: getAllThreads --- ${inboxList?.length}");
      inboxListCount = allThreadsData.getAllThreads?.count ??0;
      isLoading.value = false;
    });
  }

  (GallThreadsFragmentData?, GallThreadsFragmentReq)  getallThreadsInfo({required int threadId}){
    GallThreadsFragmentReq fragmentReq = GallThreadsFragmentReq((b) => b..idFields = {'id': threadId});
    return (FerryLoggerClient.client?.cache.readFragment(fragmentReq),fragmentReq);
  }

  void refreshList() {
    inboxCurrentpage.value = 1;
    inboxList!.clear();
    isShowLoader = false;
    isLoading.value = true;
    checkNetwork(getAllThreads);
  }


}