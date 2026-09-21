import 'dart:io';

import 'package:cli_util/cli_logging.dart';

class IOSConfigHandler {
  File? _file;
  String? _filePath;
  Logger logger = Logger.standard();
  IOSConfigHandler(String filePath) {
    _filePath = filePath;
  }

  Future<void> _checkFileExistOrCreate() async {
    _file = File(_filePath!);
    final bool fileIsExists = _file!.existsSync();

    if (fileIsExists) return;
  }
  Future<void> modify(String content) async {
    await _checkFileExistOrCreate();

    String fileContent = await _file!.readAsString();

    content = content.replaceAll('//', '/\$()/');

    const excludedKeys = {
      'GOOGLE_PAY_MERCHANT_ORGANIZATION',
      'GOOGLE_PAY_MERCHANT_ID',
      'APP_COLOR_PRIMARY',
      'APP_COLOR_SCREEN_BG',
      'APP_COLOR_BOTTOM_NAV_BAR_BG'
      'APP_COLOR_SECONDARY',
      'PLATFORM_NAME',
      'IOS_PACKAGE_NAME',
    };

    String? packageName;
    String? iosPackageName;

    final lines = content.split('\n');

    // 🔍 Extract values
    for (var line in lines) {
      final parts = line.split('=');
      if (parts.length < 2) continue;

      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();

      if (key == 'PACKAGE_NAME') {
        packageName = value;
      } else if (key == 'IOS_PACKAGE_NAME') {
        iosPackageName = value;
      }
    }

    // 🎯 Apply logic
    if (iosPackageName != null && iosPackageName.isNotEmpty) {
      packageName = iosPackageName;
    }

    // 🧹 Remove excluded keys
    final filteredContent = lines.where((line) {
      final key = line.split('=').first.trim();
      return !excludedKeys.contains(key);
    }).join('\n');

    // 🏗 Replace PACKAGE_NAME in filtered content
    final updatedContent = filteredContent.replaceAllMapped(
      RegExp(r'^PACKAGE_NAME\s*=.*$', multiLine: true),
          (_) => 'PACKAGE_NAME = ${packageName ?? ''}',
    );

    final buffer = StringBuffer()
      ..writeln(iOSConfigFileContent)
      ..writeln('PRODUCT_BUNDLE_IDENTIFIER = \$(PACKAGE_NAME)')
      ..writeln(updatedContent);

    await _file!.writeAsString(buffer.toString());
  }
  Future<void> update(String content) async {
    await _checkFileExistOrCreate();
    String fileContent = await _file!.readAsString();
    logger.stdout("reverseclientid:${content}");
    fileContent = '$fileContent$content';
    _file!.writeAsString(fileContent);
  }
}

const iOSConfigFileContent = '''
#include "Flutter/Generated.xcconfig"
''';
