import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:investy/firebase_options.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:investy/viewmodel/portfolio_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioViewModel()),
      ],
      child: MaterialApp(
        title: 'Investy app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
