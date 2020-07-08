import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//import 'constants.dart';
import 'main.dart';


final user_name = TextEditingController();
final examcode = TextEditingController();
final api = TextEditingController();




class Signup extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  String _counter;
  bool eye = true;

  void _toggle() {
    setState(() {
      eye = !eye;
    });
  }


  bool isEnabled = true ;
  enableButton(){

    setState(() {
      isEnabled = true;
    });
  }


  Future getData() async {
    print('Heloooo');
    FocusScope.of(context).requestFocus(FocusNode());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user_name",user_name.text);
      prefs.setString("examcode",examcode.text);
      prefs.setString("api",api.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          new AbsorbPointer(
            absorbing: !isEnabled,
            child:Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
              child: new FlatButton(
                child: new Text("Not Made For Cheating",
                  style: new TextStyle(color: Colors.grey, fontSize: 17),),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                highlightColor: Colors.black,
                shape: StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: !isEnabled,
        child: SingleChildScrollView(


          child: new Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Form(
              key: _formKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text(
                    "End Sem Exams 2020",
                    style: new TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                  ),
                  new SizedBox(
                    height: 70,
                  ),
                  new TextFormField(
                    controller: user_name,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your Name';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      // hintText: "Email",
                      labelText: "Your Name",
                    ),
                  ),
                  new SizedBox(
                    height: 30,
                  ),
                  new TextFormField(
                    controller: api,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter URL';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      // hintText: "Email",
                      labelText: "Enter API URL",
                    ),
                  ),
                  new SizedBox(
                    height: 30,
                  ),
                  new TextFormField(
                    controller: examcode,
                    validator: (value) {
                      if (value.length == 0) {
                        return 'Input Exam Code';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      labelText: "Exam Code",
                      suffixIcon: new GestureDetector(
                        child: new Icon(
                          Icons.remove_red_eye,
                        ),
                        onTap: _toggle,
                      ),
                    ),
                    obscureText: eye,
                  ),
                  new SizedBox(
                    height: 50,
                  ),
                  new SizedBox(
                    height: 50,
                    child: new RaisedButton(
                        child: new Text("Join",
                            style: new TextStyle(color: Colors.white)),
                        color: Colors.black,
                        elevation: 15.0,
                        shape: StadiumBorder(),
                        splashColor: Colors.white54,
                        onPressed: () {
                          if (_formKey.currentState.validate())
                          {
                            if(isEnabled)
                            {
                              getData();
                            }
                            else
                            {
                              null;
                            }
                          }
                        }
                    ),
                  ),
                  new Container(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: new Text(
                      "Or sign up with social account",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Expanded(

                        child: new OutlineButton(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                FontAwesomeIcons.facebookF,
                                size: 20,
                              ),
                              new SizedBox(
                                width: 5,
                              ),
                              new Text("Facebook",
                                  style: new TextStyle(color: Colors.black)),
                            ],
                          ),
                          shape: StadiumBorder(),
                          highlightedBorderColor: Colors.black,
                          borderSide: BorderSide(color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                      new SizedBox(
                        width: 20,
                      ),
                      new Expanded(

                        child: new OutlineButton(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                FontAwesomeIcons.twitter,
                                size: 20,
                              ),
                              new SizedBox(
                                width: 5,
                              ),
                              new Text("Twitter",
                                  style: new TextStyle(color: Colors.black)),
                            ],
                          ),
                          shape: StadiumBorder(),
                          highlightedBorderColor: Colors.black,
                          borderSide: BorderSide(color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  new SizedBox(height: 60),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("By signing up you agree to our "),
                      new GestureDetector(
                          child: Text("Terms of Use",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              )),
                          onTap: () {})
                    ],
                  ),
                  new SizedBox(
                    height: 5,
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("and "),
                      new GestureDetector(
                          child: Text("Privacy Policy",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              )),
                          onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );



  }
}
