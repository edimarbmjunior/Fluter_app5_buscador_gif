import 'package:app5buscadorgif/ui/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(
    MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        hintColor: Colors.white,
        primaryColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    )
);

