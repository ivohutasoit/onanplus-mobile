import 'package:flutter/material.dart';
import 'package:onanplus/constant/constant.dart';
import 'package:onanplus/page/page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: kDefaultColor,
        canvasColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0.0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}