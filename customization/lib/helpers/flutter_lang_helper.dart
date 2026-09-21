import 'dart:convert';
import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:customization/helpers/env_helper.dart';
import 'package:http/http.dart' as http;


class FlutterLangHandler {

  File? _flutterLangFile;
  EnvHandler? handler;
  FlutterLangHandler(String filePath) {
    _flutterLangFile = File(filePath);
  }
  Logger logger = Logger.standard();
  Future<File?> init({Map<String, String>? data, EnvHandler? envHandler}) async {
    try {
      handler =  envHandler!;
      final bool fileIsExists = _flutterLangFile!.existsSync();
      if (fileIsExists) {
        await _modifyString(data ?? {});
        await _modifyEngString(data ?? {});
        await _modifyMultiLangString(data ?? {}, 'es');
        await _modifyMultiLangString(data ?? {}, 'fr');
        await _modifyMultiLangString(data ?? {}, 'it');
        await _modifyMultiLangString(data ?? {}, 'pt');
        await _modifyMultiLangString(data ?? {}, 'he');
        await _modifyMultiLangString(data ?? {}, 'ar');
        return _flutterLangFile;
      }
      await _flutterLangFile!.create(recursive: true);
      await init(data: data, envHandler: envHandler);
    } on Exception {
      logger.stdout("strings.xml wrong formatted");
    }
    return null;
  }

  Future<void> _modifyString(Map<String, String> data) async {
    try {
      String? contents =  _flutterLangFile?.readAsStringSync();
      String? updatedcontents = contents;


      for (var key in data.keys){
        if(!updatedcontents!.contains('const String ${key}')){
          updatedcontents = updatedcontents.trim() + '\n'+ 'const String ${key} = "${key}";';
          _flutterLangFile!.writeAsStringSync(updatedcontents!.trim(), );
        }
      }

      updatedcontents!.split('\n').forEach((constval) {
        for (var key in data.keys){
          var reg = RegExp('const String ${key} = (.*);', caseSensitive: true, multiLine: false);
          var oldconstvalue = reg.firstMatch(updatedcontents!)!.group(1);
          if(constval != '"${key}";') {
            var newconstvalue = '"${key}"';
            updatedcontents = updatedcontents!.replaceFirstMapped(oldconstvalue!, (m) {return newconstvalue;});
            _flutterLangFile!.writeAsStringSync(updatedcontents!, );
            break;
          }
        }
      });

    } catch (_) {}
  }

  _modifyEngString(Map<String, String> map) {
    String englishcontentpath = 'lib/lang/en.dart';
    File _engContentFile = File(englishcontentpath);
    String? engcontents =  _engContentFile.readAsStringSync();
    String? updatedContents = '';
    engcontents =   engcontents.replaceFirst('};', '').trim()+ '};';
      engcontents.split('\n').forEach((engcontent) {
      String key =   engcontent.split(':')[0].trim();

        if(key != map.keys.first ){
          if(engcontent.trim().contains('};')){
            updatedContents = engcontents!.replaceFirstMapped('};', (m) {return '\n${map.keys.first}:\'${map.values.first}\',\n };';});
        }
        }else{

          if(engcontent.trim().contains('};')){
            updatedContents = engcontents!.replaceFirstMapped(engcontent, (m) {return '${map.keys.first}:\'${map.values.first}\',\n };';});
          }else{

            var reg = RegExp('${map.keys.first}:(.*)', caseSensitive: true, multiLine: false);
            var oldconstvalue = reg.firstMatch(engcontents!)!.group(0);
            var newconstvalue = '${map.keys.first}:\'${map.values.first}\',';
            updatedContents = engcontents!.replaceFirst(oldconstvalue!,newconstvalue);

          }

        }
      });
      _engContentFile!.writeAsStringSync(updatedContents!, );

  }

  _modifyMultiLangString(Map<String, String> map,  String langCode) async{

     String multilangcontentpath = 'lib/lang/${langCode}.dart';
     String langchangedvalue = map.values.first;

    File _multilangContentFile = File(multilangcontentpath);
    String? multilangcontents =  _multilangContentFile.readAsStringSync();
    if(!multilangcontents.contains('${map.keys.first}\'')){
    //  String url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${langCode}&dt=t&q=${map.values.first}";
    String url = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=auto&tl=${langCode}&q=${map.values.first}";
      var uri = Uri.parse(url);
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        String data = response.body;
        List<dynamic> decodedData = jsonDecode(data);
        logger.stdout('decodedData: ${decodedData[0][0]} --- ');
        langchangedvalue = decodedData[0][0];
      }
        multilangcontents =   multilangcontents.replaceFirst('};', '').trim()+ '};';
        multilangcontents.split('\n').forEach((multilangcontent) {
        String key =   multilangcontent.split(':')[0].trim();
        if(!key.contains('${map.keys.first}')){
          if(multilangcontent.trim().contains('};')){
            multilangcontents = multilangcontents!.replaceFirstMapped('};', (m) {return '\n${map.keys.first}:\'${langchangedvalue}\',\n };';});
          }
          }else{
          if(multilangcontent.trim().contains('};')){
            multilangcontents = multilangcontents!.replaceFirstMapped(multilangcontent, (m) {return '${map.keys.first}:\'${map.values.first}\',\n };';});
          }else{
            multilangcontents = multilangcontents!.replaceFirstMapped(multilangcontent, (m) {return '\n${map.keys.first}:\'${map.values.first}\',\n';});
          }
        }
        });
        _multilangContentFile.writeAsStringSync(multilangcontents!, );
    }
  }

}


