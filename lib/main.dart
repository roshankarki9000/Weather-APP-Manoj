import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'pages/intro_page.dart';
import 'providers/location_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => LocationProvider(),
          child: MaterialApp(
            title: 'Simple Weather App',
            theme: ThemeData(
              useMaterial3: true,
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),

              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white),
                elevation: 0,
              ),

              iconTheme: const IconThemeData(color: Colors.white),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
            home: child,
          ),
        );
      },
      child: const IntroPage(),
    );
  }
}
