import 'package:daily_sales/firebase_options.dart';
import 'package:daily_sales/widget/CustomBottomNav.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    final options = Firebase.app().options;
print(" Connected to Firebase Project: ${options.projectId}");


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQueryData.fromView(View.of(context));

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0), 
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Al Marsa',
            theme: ThemeData(),
            home: BottomNavBar()
          ),
        );
      },
    );
  }
}
