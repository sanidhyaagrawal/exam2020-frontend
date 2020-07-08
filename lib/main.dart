import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
import 'signup.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'constants.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/Signup': (BuildContext context) => new Signup(),
      '/Home': (BuildContext context) => new Home()
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('api') ?? null;
    print(stringValue);
    if(stringValue != null){
      Navigator.of(context).pushReplacementNamed('/Home');
    }
    else
    {
      Navigator.of(context).pushReplacementNamed('/Signup');
    }
  }



  @override
  void initState() {
    super.initState();
    startTime();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new  Icon(
          FontAwesomeIcons.accusoft,
          size: 50,
        ),
      ),
    );
  }

}