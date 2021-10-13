import 'package:logging/logging.dart';

void section(final Logger logger, final String header) {
  final String line = '-' * header.length;
  logger.info('''
$line
$header
$line
  ''');
}
