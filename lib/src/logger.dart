import 'package:logging/logging.dart';

void section(Logger logger, String header) {
  String line = '-' * header.length;
  logger.info('''
  
$line
$header
$line
  ''');
}
