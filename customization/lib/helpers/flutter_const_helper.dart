import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:customization/customization.dart';
import 'package:customization/helpers/env_helper.dart';
import 'package:customization/helpers/ios_config_helper.dart';
import 'package:xml/xml.dart';

class FlutterConstHandler {

  File? _flutterConstFile;
  File? colorsFile;
  File? _JsonFile;
  EnvHandler? handler;
  XmlDocument? _document ;
  Logger logger = Logger.standard();
  FlutterConstHandler(String filePath, String colorsFilePath) {
    _flutterConstFile = File(filePath);
    colorsFile = File(colorsFilePath);
  }

  Future<void> removeBlockComments(File file) async {
    final content = await file.readAsString();
    final cleaned = content.replaceAll(
      RegExp(r'^\s*//.*$', multiLine: true),
      '',
    );
    await file.writeAsString(cleaned);
  }



  Future<File?> init(
      {Map<String, String>? data, EnvHandler? envHandler}) async {
    handler = envHandler!;
    final bool fileIsExists = _flutterConstFile!.existsSync();
    if (fileIsExists) {
      await _modifyString(data ?? {});
      _JsonFile = File('android/app/google-services.json');
      final iosfile = File('ios/Runner/GoogleService-Info.plist');


      final bool jsonfileIsExists = _JsonFile!.existsSync();

      if(jsonfileIsExists && iosfile.existsSync()){
        await _updateAndroidConfig();
        await _updateIOSConfig();
      }
      if (jsonfileIsExists) {
        await _updateAndroidConfig();
      } else if(iosfile.existsSync()) {
        await _updateIOSConfig();
      } else {
        var filelist = Directory('Apple Certificates').listSync();
        filelist.forEach((file) {
          if (file is File) {
            print('filename: ${(file as File).path}');
            if (!(file as File).path.toString().contains(".DS_Store") &&
                !(file as File).path.toString().contains("README.md")) {
              file.deleteSync();
            }
          } else {
            file.deleteSync();
          }
        });

        final readmeFile = File('${ Directory('Apple Certificates').path}/README.md');

        readmeFile.writeAsStringSync('''
            <please put your Development and distribution related certificates here>        
            ''');

        if(await Directory('Firebase Certificates').exists()) {
          var firebasefilelist = Directory('Firebase Certificates').listSync();
          firebasefilelist.forEach((file) {
            if (file is File) {
              print('filename: ${(file as File).path}');
              if (!(file as File).path.toString().contains(".DS_Store") &&
                  !(file as File).path.toString().contains("README.md")) {
                file.deleteSync();
              }
            } else {
              file.deleteSync();
            }
          });
        } else {
          await  Directory('Firebase Certificates').create(recursive: true);
        }

        final readmeFirebase = File('${ Directory('Firebase Certificates').path}/README.md');

        readmeFirebase.writeAsStringSync('''
            <please put your Firebase related documents here>        
            ''');

        var keystorefilelist = Directory('Keystore').listSync();
        if( keystorefilelist.length !=0) {
          keystorefilelist.forEach((file) {
            if (file is File) {
              String keyfilepath = (file as File).path.toString();
              print('keystorefilelist: ${keyfilepath}');
              if (!keyfilepath.contains(".DS_Store") &&
                  !keyfilepath.contains("README.md")) {
                file.deleteSync();
              } else if (keyfilepath.contains("README.md")) {
                file.writeAsStringSync(
                    '''key password: KEY_PASSWORD\nkey alias: KEY_ALIAS\nkeystore password: KEY_STORE_PASSWORD''');
              }
            } else {
              file.deleteSync();
            }
          });
        } else {
          final file = File('Keystore/README.md');
          await file.create(recursive: true);
          file.writeAsStringSync(
              '''key password: KEY_PASSWORD\nkey alias: KEY_ALIAS\nkeystore password: KEY_STORE_PASSWORD''');
        }

        final iosfile = File('ios/GoogleService-Info.plist');

        if (await iosfile.exists()) {
          await iosfile.delete();
        }

        final file = File('android/key.properties');

        if (await file.exists()) {
          await file.delete();
        }

        await file.create(recursive: true);

        const content = '''
keyPassword: KEY_PASSWORD
keyAlias: KEY_ALIAS
storePassword: KEY_STORE_PASSWORD
storeFile=./keystore.jks
''';

        await file.writeAsString(content);

        String keystorejksfilepath = 'android/app/keystore.jks';
        if(File(keystorejksfilepath).existsSync())
          File(keystorejksfilepath).deleteSync();

        String firebaseoptionpath = 'ios/firebase_app_id_file.json';
        Map<String, String> firebaseoptionmap = {};
        firebaseoptionmap['GOOGLE_APP_ID'] =
        '"GOOGLE_APP_ID": "GOOGLE_APP_ID",';
        firebaseoptionmap['FIREBASE_PROJECT_ID'] =
        '"FIREBASE_PROJECT_ID": "FIREBASE_PROJECT_ID",';
        firebaseoptionmap['GCM_SENDER_ID'] =
        '"GCM_SENDER_ID": "GCM_SENDER_ID" \n }';
        AppEnv.replaceLine(filePath: firebaseoptionpath,
            oldLineContent: '',
            replaceableString: '',
            replaceableContentMap: firebaseoptionmap);


        String firebaseoptiondartpath = 'lib/firebase_options.dart';
        Map<String, String> firebaseoptiondartmap = {};
        firebaseoptiondartmap['apiKey:'] = 'apiKey: "API_KEY",';
        firebaseoptiondartmap['appId:'] = 'appId: "APP_ID",';
        firebaseoptiondartmap['messagingSenderId:'] = 'messagingSenderId: "MESSAGE_SENDER_ID",';
        firebaseoptiondartmap['projectId: '] = 'projectId: "PROJECT_ID",';
        firebaseoptiondartmap['databaseURL:'] = 'databaseURL: "DATABASE_URL",';
        firebaseoptiondartmap['storageBucket:'] = 'storageBucket: "STORAGE_BUCKET",';
        firebaseoptiondartmap['androidClientId:'] = 'androidClientId: "ANDROID_CLIENT_ID",';
        firebaseoptiondartmap['iosClientId:'] = 'iosClientId: "IOS_CLIENT_ID",';
        firebaseoptiondartmap['iosBundleId:'] = 'iosBundleId: "IOS_BUNDLE_ID",';

        firebaseoptiondartmap.forEach((key,value){
          AppEnv.replaceLine(filePath: firebaseoptiondartpath,
            oldLineContent: key,
            replaceableString: '\t\t${value}',
          );
        });

        AppEnv.replaceLine(filePath: _flutterConstFile!.path,
          oldLineContent: 'const String ANDROID_FIREBASE_CLIENT_ID',
          replaceableString: 'const String ANDROID_FIREBASE_CLIENT_ID = \'ANDROID_FIREBASE_CLIENT_ID\';',
        );

        AppEnv.replaceLine(filePath: _flutterConstFile!.path,
          oldLineContent: 'const String IOS_FIREBASE_CLIENT_ID',
          replaceableString: 'const String IOS_FIREBASE_CLIENT_ID = \'IOS_FIREBASE_CLIENT_ID\';',
        );

        AppEnv.replaceLine(filePath: _flutterConstFile!.path,
          oldLineContent: 'const String FIREBASE_PROJECT_ID',
          replaceableString: 'const String FIREBASE_PROJECT_ID = \'FIREBASE_PROJECT_ID\';',
        );

        File  googleinfoPlistFile = File('ios/Runner/GoogleService-Info.plist');
        if(googleinfoPlistFile.existsSync())
          googleinfoPlistFile.deleteSync();

        logger.stdout("google-services.json file is missing");
      }
      return _flutterConstFile;
    }
    await _flutterConstFile!.create(recursive: true);
    await init(data: data, envHandler: envHandler);
    return null;
  }

  Future<void> _modifyString(Map<String, String> data) async {
    try {
      await removeBlockComments(_flutterConstFile!);
      final hasIOSPackage =
          data.containsKey('IOS_PACKAGE_NAME') &&
              (data['IOS_PACKAGE_NAME'] ?? '').toString().trim().isNotEmpty;
      if (hasIOSPackage) {
        data['PACKAGE_NAME'] = data['IOS_PACKAGE_NAME']!;
      }
      for (var key in data.keys) {
        if (!key.contains('_VERSION') && !key.contains('APP_COLOR_')) {

          AppEnv.replaceLine(filePath: _flutterConstFile!.path,
              oldLineContent:'String ${key}',
              replaceableString: 'const String ${key} = \'${data[key]}\';');

        } else if (key.contains('APP_COLOR_PRIMARY')) {


          final fromColor = await getAppPrimaryColorHex();

          changeSVGColor(toColor: data[key]??"",fromColor: fromColor ?? '');
          AppEnv.replaceLine(filePath: colorsFile!.path,
              oldLineContent: 'lightprimaryColor =',
              replaceableString: '\t static const lightprimaryColor = Color(0xFF${data[key]});');
        }else if (key.contains('APP_COLOR_SECONDARY')) {
          final fromColor = await getAppPrimaryColorHex(colorType: r'lightprimaryColor\s*=\s*Color\(\s*0x([0-9A-Fa-f]{8})\s*\)' );
          changeSVGColor(toColor: data[key]??"",fromColor: fromColor ?? '');

          AppEnv.replaceLine(filePath: colorsFile!.path,
              oldLineContent: 'Color lightsecondaryColor',
              replaceableString: '\t static const Color lightsecondaryColor = Color(0xFF${data[key]});');
        }
      }
    } catch (_) {}
  }


  Future<String?> getAppPrimaryColorHex({String? colorType}) async {
    final file = File(colorsFile!.path);

    if (!file.existsSync()) {
      print('appcolors.dart not found');
      return null;
    }

    final content = await file.readAsString();

    final regex = RegExp(
      colorType ?? r'lightprimaryColor\s*=\s*Color\(\s*0x([0-9A-Fa-f]{8})\s*\)',
    );

    final match = regex.firstMatch(content);

    if (match != null) {
      final fullHex = match.group(1)!; // e.g. FFCA0035
      final rgbHex = fullHex.substring(2); // remove alpha → CA0035
      return rgbHex.toUpperCase();
    }

    print('appColorPrimary not found');
    return null;
  }

  Future<void> changeSVGColor({
    required String fromColor,
    required String toColor,
  }) async {
    final svgDirectory = Directory('res/drawable');

    if (!svgDirectory.existsSync()) {
      print('Directory not found');
      return;
    }


    if (fromColor == null) return;


    toColor = toColor.replaceAll('#', '').toUpperCase();
    print('Updated: fromColor ${fromColor} -- ${toColor}');
    final files = svgDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.svg'));

    final regex = RegExp('#$fromColor', caseSensitive: false);

    for (final file in files) {
      String content = await file.readAsString();

      if (regex.hasMatch(content)) {
        content = content.replaceAll(regex, '#$toColor');

        await file.writeAsString(content);
        print('Updated: ${file.path}');
      }
    }

    print('SVG color replacement completed ✅');
  }

  Future<void> _updateAndroidConfig() async {
    String client_id = 'CLIENT_ID';
    String project_id = 'FIREBASE_PROJECT_ID';
    String apiKey = '';
    String appId = '';

    File jsonFile = File('android/app/google-services.json');
    if (jsonFile.existsSync()) {
      Map<String, dynamic> decodedData = jsonDecode(
          jsonFile.readAsStringSync());
      var client = decodedData['client'][0];
      int authLength = client['oauth_client'].length;

      client_id = client['oauth_client'][authLength - 1]['client_id'];
      project_id = decodedData['project_info']['project_id'];
      apiKey = client['api_key'][0]['current_key'];
      appId = client['client_info']['mobilesdk_app_id'];

      _updateFlutterConst('const String ANDROID_FIREBASE_CLIENT_ID', client_id);
      _updateFlutterConst('const String FIREBASE_PROJECT_ID', project_id);


      final androidBlockRegex = RegExp(
        r'(static const FirebaseOptions android = FirebaseOptions\([\s\S]*?\);)',
        multiLine: true,
      );

      final file = File('lib/firebase_options.dart');
      String content = await file.readAsString();

      final match = androidBlockRegex.firstMatch(content);
      if (match == null) return;
      String androidBlock = match.group(0)!;

      Map<String, String> androidMapping = {
        'apiKey:': 'apiKey: "${apiKey}"',
        'appId:': 'appId: "${appId}"',
        'messagingSenderId:': 'messagingSenderId: "${decodedData['project_info']['project_number']}"',
        'projectId: ': 'projectId: "${decodedData['project_info']['project_id']}"',
        'databaseURL:': 'databaseURL: "${decodedData['project_info']['firebase_url']}"',
        'storageBucket:': 'storageBucket: "${decodedData['project_info']['storage_bucket']}"',
      };

      androidMapping.forEach((key, value) {
        final keyRegex = RegExp('$key\\s*".*?"');
        androidBlock = androidBlock.replaceFirst(keyRegex, '\t\t$value');
      });

      content = content.replaceFirst(match.group(0)!, androidBlock);

      await file.writeAsString(content);
    }
  }

  Future<void> _updateIOSConfig() async {
    String serviceinfoPath = 'ios/Runner/GoogleService-Info.plist';
    if (!File(serviceinfoPath).existsSync()) return;

    _document = XmlDocument.parse(File(serviceinfoPath).readAsStringSync());
    Map<String, String> plist = parsePlist();

    // 1. Update Native iOS Config
    String reverseClientId = plist['REVERSED_CLIENT_ID'] ?? '';
    if (reverseClientId.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await IOSConfigHandler('ios/Flutter/AppEnvConfig.xcconfig')
            .update("REVERSE_CLIENT_ID = $reverseClientId");
      });
    }

    _updateFlutterConst('const String IOS_FIREBASE_CLIENT_ID', "${plist['ANDROID_CLIENT_ID']}");
    _updateFlutterConst('const String FIREBASE_PROJECT_ID', "${plist['PROJECT_ID']}");
    // 2. Update firebase_app_id_file.json

    Map<String, String> firebaseoptionmap = {};
    firebaseoptionmap['GOOGLE_APP_ID'] = '"GOOGLE_APP_ID": "${plist['GOOGLE_APP_ID']}",';
    firebaseoptionmap['FIREBASE_PROJECT_ID'] = '"FIREBASE_PROJECT_ID": "${plist['PROJECT_ID']}",';
    firebaseoptionmap['GCM_SENDER_ID'] = '"GCM_SENDER_ID": "${plist['GCM_SENDER_ID']}" \n }';
    AppEnv.replaceLine(filePath: 'ios/firebase_app_id_file.json',
        oldLineContent: '',
        replaceableString: '',
        replaceableContentMap: firebaseoptionmap);

    final iosBlockRegex = RegExp(
      r'(static const FirebaseOptions ios = FirebaseOptions\([\s\S]*?\);)',
      multiLine: true,
    );

    final file = File('lib/firebase_options.dart');
    String content = await file.readAsString();

    final match = iosBlockRegex.firstMatch(content);
    if (match == null) return;
    String iosBlock = match.group(0)!;

    print("iosmap: ${firebaseoptionmap}");

    // 3. Update firebase_options.dart for iOS fields
    Map<String, String> iosMapping = {
      'apiKey:': 'apiKey: "${plist['API_KEY']}"',
      'appId:': 'appId: "${plist['GOOGLE_APP_ID']}"',
      'messagingSenderId:': 'messagingSenderId: "${plist['GCM_SENDER_ID']}"',
      'projectId: ': 'projectId: "${plist['PROJECT_ID']}"',
      'databaseURL:': 'databaseURL: "${plist['DATABASE_URL']}"',
      'storageBucket:': 'storageBucket: "${plist['STORAGE_BUCKET']}"',
      'androidClientId:': 'androidClientId: "${plist['ANDROID_CLIENT_ID']}"',
      'iosClientId:': 'iosClientId: "${plist['CLIENT_ID']}"',
      'iosBundleId:': 'iosBundleId: "${plist['BUNDLE_ID']}"',
    };

    // 3. Perform replacements ONLY on the isolated iOS block string
    iosMapping.forEach((key, value) {
      // Uses lookahead to ensure we only replace the value following the key
      final keyRegex = RegExp('$key\\s*".*?"');
      iosBlock = iosBlock.replaceFirst(keyRegex, '\t\t$value');
    });

    // 4. Put the modified iOS block back into the full file content
    content = content.replaceFirst(match.group(0)!, iosBlock);

    // 5. Write back to file
    await file.writeAsString(content);
  }

  void _updateFlutterConst(String label, String newValue) {
    String contents = _flutterConstFile!.readAsStringSync();
    if (!contents.contains(label)) {
      contents = '$contents\n$label = "$newValue";';
    } else {
      var reg = RegExp('$label = (.*);');
      contents = contents.replaceFirstMapped(reg, (m) => '$label = "$newValue";');
    }
    _flutterConstFile!.writeAsStringSync(contents.trim());
  }

  Map<String, String> parsePlist() {
    final dict = _document!.findAllElements('dict').first;
    final elements = dict.children.whereType<XmlElement>().toList();

    Map<String, String> data = {};
    for (int i = 0; i < elements.length; i += 2) {
      if (i + 1 < elements.length) {
        String key = elements[i].innerText;
        var valueElement = elements[i + 1];
        if (valueElement.name.local == 'string') {
          data[key] = valueElement.innerText;
        } else if (valueElement.name.local == 'integer') {
          data[key] = (int.tryParse(valueElement.innerText) ?? 0).toString();
        } else if (valueElement.name.local == 'true') {
          data[key] = true.toString();
        } else if (valueElement.name.local == 'false') {
          data[key] = false.toString();
        }
      }
    }
    return data;
  }

}
