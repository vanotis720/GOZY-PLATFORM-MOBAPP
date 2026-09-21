import 'package:get/get.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';


class AppSettingsController extends ProfileController {
  @override
  Map<String,List<Map<String,dynamic>>> profileItems = {};
  RxString isLangDownloading = "".obs;
  List<dynamic>? listOfCurrencies = [];
   void getCurrenciesList() {
     getCurrencyList().then((currencyListData){
       listOfCurrencies?.clear();
       currencyListData.getCurrencies?.results?.forEach((p0) {
         StepItemModel stepItemModel =  StepItemModel(
             itemValue: p0?.symbol,
             itemName: "${getCurrencySymbol(currency: p0?.symbol)} ${p0?.symbol}"
         );
         listOfCurrencies?.add(stepItemModel);
       });
     });
  }
}