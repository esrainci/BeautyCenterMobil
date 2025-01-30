import 'package:firstproject/profile.dart';
import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'registerscreen.dart';
import 'homescreen.dart';
import 'calisantakvim.dart';
import 'yorum_sistemi.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Güzellik Merkezi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/calisantakvim': (context) => CalisanTakvimPage(),
        '/yorumsistemi': (context) => YorumSistemiPage(),
      },
    );
  }
}
