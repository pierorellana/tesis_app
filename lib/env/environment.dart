import 'config/config_base.dart';
import 'config/config_dev.dart';
import 'config/config_prod.dart';
import 'config/config_qa.dart';

class Environment{
  static final Environment _environment = Environment._internal();

  factory Environment()=>_environment;

  Environment._internal();

  static const String dev='DEV';
  static const String qa='QA';
  static const String prod='PROD';

  BaseConfig? config;

  initConfig(String environment){
    config = _getConfig(environment);
  }

  BaseConfig _getConfig(String environment){
    switch(environment){
      case Environment.qa:
      return QaEnv();
      case Environment.prod:
      return ProdEnv();
      default:
      return DevEnv();
    }
  }
}