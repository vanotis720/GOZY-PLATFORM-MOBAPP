import 'dart:async';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:customization/helpers/android_xml_helper.dart';
import 'package:customization/helpers/env_helper.dart';
import 'package:customization/helpers/flutter_const_helper.dart';
import 'package:customization/helpers/flutter_lang_helper.dart';
import 'package:customization/helpers/ios_config_helper.dart';
import 'package:customization/package_changes/android_rename_steps.dart';
import 'package:customization/package_changes/flutter_rename_steps.dart';
import 'package:customization/package_changes/ios_rename_steps.dart';


class AppEnv {
  static String get _stringXml => 'android/app/src/main/res/values/strings.xml';

  static String get _appgradle => 'android/app/build.gradle';

  static String get _iOSConfig => 'ios/Flutter/AppEnvConfig.xcconfig';

  static String get _flutterConfig => 'lib/constant.dart';

  static String get _flutterAppColorConfig => 'lib/resources/app_colors.dart';

  static String get _flutterPubSpecConfig => 'pubspec.yaml';
  static Logger logger = Logger.standard();


  static Future<void> process(String envFileName) async {
    final EnvHandler env = EnvHandler(envFileName);
    final String envFilePath = await env.fileContent;

    final Map<String, String> data = await env.extract();

    logger.stdout("datamessage: ${data['PACKAGE_NAME']}");
    if (data['PACKAGE_NAME'] != null) {
      String? newpackageName = data['PACKAGE_NAME'];
      await AndroidRenameSteps(newpackageName!, _appgradle, data: data)
          .process();
      await IosRenameSteps(newpackageName).process();
      if (data['APP_NAME'] != null)
        await FlutterRenameSteps(_flutterPubSpecConfig).process(
            data['APP_NAME'] ?? '', packagename: newpackageName,appversion: formatAppVersion (data['APP_VERSION'] ?? '1.0'));
    //  data.remove('PACKAGE_NAME');
    }

    await AndroidXMLHandler(_stringXml, _appgradle).init(
        data: data, envHandler: env);
    await IOSConfigHandler(_iOSConfig).modify(envFilePath);
    await FlutterConstHandler(_flutterConfig, _flutterAppColorConfig).init(
        data: data, envHandler: env);
    await Future.delayed(const Duration(milliseconds: 3000));
    Process.runSync('flutter', ['pub', 'get'], runInShell: true);
  }

  static String formatAppVersion(String input) {
    RegExp threePartVersion = RegExp(r'\d+\.\d+\.\d+');
    if (threePartVersion.hasMatch(input)) {
      return input;
    } else {
      return '$input.0';
    }
  }


  static Future<void> addLang(String key, String value) async {
    logger.stdout("message: ${key}---${value}");
    final EnvHandler env = EnvHandler(key);
    String _langConfig = 'lib/resources/app_lang.dart';
    Map<String, String>? data = {};
    data[key] = value;
    await FlutterLangHandler(_langConfig).init(data: data, envHandler: env);
  }

  static Future<String?> checkAndChangeContent(
      {required String filePath, required String regexStr, required String replaceableString, bool? isReplaceAll = false, bool isRegexEnable = true }) async {
    File file = File(filePath);
    String contents = file.readAsStringSync();
    String? oldname;
    if (isRegexEnable) {

      var reg = RegExp(regexStr, caseSensitive: true, multiLine: false);
      oldname = reg.firstMatch(contents!)!.group(1);
    } else {
      oldname = regexStr;
    }
    logger.stdout("message: gradle file ${oldname} -- ${replaceableString} --- ${filePath}");
    String replacingcontents = '';
    if (isReplaceAll != null && isReplaceAll) {
      replacingcontents = contents.replaceAll(oldname!, replaceableString);
    } else {
      replacingcontents = contents.replaceFirstMapped(oldname!, (m) {
        return replaceableString;
      });
    }
    file.writeAsStringSync(replacingcontents);
    return oldname;
  }

  static replaceLine(
      {required String filePath, required String oldLineContent, required String replaceableString, Map<
          String,
          String>? replaceableContentMap, String updatedString =''}) {
    var gradleFile = File(filePath);
    List<String> lines = gradleFile.readAsLinesSync();
    List<String> updatedLines = [];

    if (replaceableContentMap != null && replaceableContentMap.isNotEmpty) {
      for (String line in lines) {
        for (String key in replaceableContentMap.keys) {
          if (!line.contains(key)) {
            updatedLines.add(line);
            break;
          } else {
            updatedLines.add(replaceableContentMap[key] ?? '');
            replaceableContentMap.remove(key);
            break;
          }
        }
      }
    } else {
      String type ='';
      for (String line in lines) {
        if (!line.contains(oldLineContent)) {
          if(line.contains('static const FirebaseOptions android')){
            type = 'android';
          }else if(line.contains('static const FirebaseOptions ios')){
            type = 'ios';
          }
          updatedLines.add(line);
        } else {
          if(updatedString.isNotEmpty &&  type == 'android')
            updatedLines.add(updatedString);
          else
          updatedLines.add(replaceableString);

        }
      }
    }
    gradleFile.writeAsStringSync(updatedLines.join('\n'));
  }


  static Future<void> updateKeystore(String keystorefilepath) async {
    File sourceFile = File(keystorefilepath);

    if (!sourceFile.existsSync()) {
      print("❌ File does not exist: ${keystorefilepath}");
      return;
    }

    String destinationPath = "Keystore/keystore.jks";
    String destinationPath1 = "android/app/keystore.jks";

    try {
      // Copy the file
      sourceFile.copySync(destinationPath);
      sourceFile.copySync(destinationPath1);
      print("Enter the Keystore password:");
      String? keystorepassword = stdin.readLineSync();
      print("Enter the Key password:");
      String? keypassword = stdin.readLineSync();
      print("Enter the Key Alias:");
      String? keyalias = stdin.readLineSync();
      print("✅ File copied successfully to: ${keystorepassword} - ${keypassword} ---- ${keyalias}");

      String keystorefilepath = 'android/key.properties';
      String keystorefilepath2 = 'Keystore/README.md';
      Map<String, String> replacemap = {};
      replacemap['storePassword='] = 'storePassword= ${keystorepassword}';
      replacemap['keyPassword='] = 'keyPassword= ${keypassword}';
      replacemap['keyAlias='] = 'keyAlias= ${keyalias}';
      replacemap['storeFile='] = 'storeFile= ./keystore.jks';
      AppEnv.replaceLine(filePath: keystorefilepath,
          oldLineContent: '',
          replaceableString: '',
          replaceableContentMap: replacemap);

      Map<String, String> replacemap2 = {};
      replacemap2['key password:'] = 'key password: ${keypassword}';
      replacemap2['alias:'] = 'key alias: ${keyalias}';
      replacemap2['keystore password:'] =
      'keystore password: ${keystorepassword}';

      AppEnv.replaceLine(filePath: keystorefilepath2, oldLineContent: '', replaceableString: '',replaceableContentMap: replacemap2);


    } catch (e) {
      print("❌ Error copying file: $e");
    }
  }

}



