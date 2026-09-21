import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/staticPageContent/__generated__/static_page_content.data.gql.dart';
import 'package:gozy/graphql/staticPageContent/__generated__/static_page_content.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';

class StaticContentPageController extends BaseController {
  int staticpageId = 0;
  GgetStaticPageContentData? staticPageContentData;

  void getStaticPageContent() {
    final params = GgetStaticPageContentReq((b) => b
      ..vars.id = staticpageId
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getStaticPageContent, isViewLoader: false)?.then((res) {
      staticPageContentData = res.data as GgetStaticPageContentData;
      isLoading.value = false;
      isShowLoader = false;
    });
  }
}