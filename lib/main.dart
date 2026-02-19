import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:media_kit/media_kit.dart';
import 'package:tesis_app/shared/secure/data_storage.dart';
import 'env/environment.dart';
import 'env/theme/app_theme.dart';
import 'shared/providers/functional_provider.dart';
import 'shared/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  String environment = const String.fromEnvironment('ENVIRONMENT', defaultValue: Environment.dev);
  CatalogueStorage().preloadCatalogue();
  Environment().initConfig(environment);
  await dotenv.load(fileName: ".env");
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await initializeDateFormatting('es');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = Environment().config!.appName;

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FunctionalProvider())],
      child: KeyboardVisibilityProvider(
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES')],
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme().theme(),
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
