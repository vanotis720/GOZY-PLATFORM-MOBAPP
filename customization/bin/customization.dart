import 'dart:async';
import 'package:cli_util/cli_logging.dart';
import 'package:customization/customization.dart';


Future<void> main(List<String> args) async {
  Logger logger = Logger.standard();
  if (args.isEmpty) {
    await AppEnv.process('.env');
    return;
  }
  parseArguments(args);
}

void parseArguments(List<String> args) async {
  Logger logger = Logger.standard();
  if(args.contains('updatekeystore')){
    await AppEnv.updateKeystore(args[1]);
    return;
  }

  for (var arg in args) {
    List<String> splitted = arg.split('==');

    if (splitted.length != 2) {
      logger.stdout("HELP");
      return;
    }
    if (splitted.first == 'lang') {
      List<String> langvalue = splitted![1].split('=');
      logger.stdout("langvalue:${langvalue}");
      await AppEnv.addLang(langvalue[0],langvalue[1]);
    }
  }

  }
