import 'dart:io';

import 'package:cli_util/cli_logging.dart';


class FlutterRenameSteps {
  File? _flutterPubSpecFile;
  Logger logger = Logger.standard();

  FlutterRenameSteps(String filePath) {
    _flutterPubSpecFile = File(filePath);
  }
  Future<void> process(String appname, {required String packagename, required String appversion}) async {
    final bool fileIsExists = _flutterPubSpecFile!.existsSync();
    if (fileIsExists) {
      var content =await  _flutterPubSpecFile!.readAsStringSync();
      var reg = RegExp('name: (.*)', caseSensitive: true, multiLine: false);
      var oldname = reg.firstMatch(content)!.group(1);
      print('FLutter package change: ${oldname} --- ${appname}');
     content = content.replaceAll(
        RegExp(r'^version:.*$', multiLine: true),
        'version: ${appversion}',
      );

      String updatedContent = content.replaceAll(
        RegExp(r'^description:.*$', multiLine: true),
        'description: A ${appname} Flutter project',
      );
      updatedContent = updatedContent.replaceFirstMapped(oldname!, (m) {return '${appname.replaceAll(' ', '_').toLowerCase()}';});
      await _flutterPubSpecFile!.writeAsString(updatedContent);

     changeImportPackageName(directory: 'lib/', oldname: 'package:${oldname}/',newName:   'package:${appname.replaceAll(' ', '_').toLowerCase()}/' );
    }
  }


  void changeImportPackageName({required String directory, required String oldname, required String newName, }) {
    var filelist =  Directory(directory).listSync();
    filelist.forEach((file){
       if (file is File) {
         if(!(file as File).path.toString().contains(".DS_Store")) {
           final content = file.readAsStringSync();
           String updatedcontents = content!.replaceAll(oldname!,newName);
           file!.writeAsStringSync(updatedcontents!.trim(),);
         }
       } else {
         changeImportPackageName(directory: file.path, oldname: oldname, newName: newName);
       }
    });

  }


}


