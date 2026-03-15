import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:bobobidou/providers/theme_provider.dart';
import 'package:flutter/material.dart';
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
    print("=========> Warming up");
    final response = await http.get(Uri.parse('${AppConfig.backendUrl}/health'));
    print('=========> ✅ Backend warmup request status: ${response.statusCode}');
  } catch (e) {
    print('❌ Backend warmup request failed: $e');
    // No need to handle the error, just log it
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        ChangeNotifierProvider(create: (_) => PainProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AppTheme()),
      ],
      child: Consumer<AppTheme>(
        builder: (context, appTheme, _)
        {

          final localeProvider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            title: "Bobobidou",
            theme: appTheme.currentTheme,
            home: const HomePage(),
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