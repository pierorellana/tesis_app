
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config_base.dart';

class ProdEnv extends BaseConfig {
  @override
  String get serviceUrl => dotenv.env['URL']!;

  @override
  String get appName => 'NAME APP';
}
