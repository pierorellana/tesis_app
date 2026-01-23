import 'package:flutter/material.dart';
import 'package:tesis_app/modules/home/pages/home_page.dart';
import 'package:tesis_app/modules/splash/page/splash_page.dart';

import '../../modules/not_found/pages/not_fount_page.dart';


class AppRoutes {
  static const initialRoute = '/splash';

  static Map<String, Widget Function(BuildContext)> routes = {
    '/splash': (_) => const SplashPage(),
    '/home': (_) => const HomePage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const PageNotFound(),
    );
  }
}
