import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:bobobidou/theme/bobo_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/meals_provider.dart';
import 'providers/pain_provider.dart';
import 'providers/analysis_provider.dart';
import 'pages/home_page/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
  warmUpBackend();
}

Future<void> warmUpBackend() async {
  try {
    debugPrint("=========> Warming up");
    final response = await http.get(Uri.parse('${AppConfig.backendUrl}/health'));
    debugPrint('=========> ✅ Backend warmup request status: ${response.statusCode}');
  } catch (e) {
    debugPrint('❌ Backend warmup request failed: $e');
    // No need to handle the error, just log it
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        ChangeNotifierProvider(create: (_) => PainProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _)
        {
          return MaterialApp(
            title: "Bobobidou",
            theme: BoboTheme.light,
            home: const AnnotatedRegion<SystemUiOverlayStyle>(
              // Dark status bar icons on the peach background
              value: SystemUiOverlayStyle.dark,
              child: HomePage(),
            ),
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('fr', ''), // French
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}