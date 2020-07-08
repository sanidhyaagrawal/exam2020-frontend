import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'constants.dart';
import 'dart:math';
import 'view.dart';
import 'login.dart';
import 'signup.dart';
import 'package:permission_handler/permission_handler.dart';



class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}
String Appbar = 'Loading...';

class Home extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<Home> {

  List data;
  Future<String> getData() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      print(statuses[Permission.storage]); // it should print PermissionStatus.granted
    }

    var response;
    try {
      print('#############HELLO##############');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String api = prefs.getString("api") ?? "null";
      String examcode = prefs.getString("examcode") ?? "null";

      response = await http.get(
        Uri.encodeFull(api + "/apis/exampaper/" + examcode),
      );


      this.setState(() {
        data = json.decode(response.body);
      });

      setState(() {
        Appbar = data[0]["name"];
      });

      print(data[0]["questions"][0]);

      return "Success!";
    }
  catch (err) {
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signup()),
      );
  }
  }

  Future<String> answer(String name,String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Qname', name);
    prefs.setString('Qid', id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraWidget()),
    );

    return "Success!";
  }


  Future<String> view(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Qid', id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => View()),
    );

    return "Success!";
  }


  @override
  void initState(){
    this.getData();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(title: Text("$Appbar"), backgroundColor: Colors.black, actions: <Widget>[
      // action button
        IconButton(
          icon: Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );

          },
        ),
    ],
    ),
      body: new ListView.builder(
        itemCount: data == null ? 0 : data[0]["questions"].length,
        itemBuilder: (BuildContext context, int index){
          return new Card(
            child: InkWell(
              splashColor: Colors.black.withAlpha(30),
              onTap: () {
                view(data[0]["questions"][index]["id"].toString());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Text(
                        'Q. ' + data[0]["questions"][index]["name"],
                        style: TextStyle(
                            fontSize: 18)
                    ),
                    title:  Text( '[ '+data[0]["questions"][index]["part"]+' ]',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17)),//Text(data[index]["title"]),
                    subtitle:  Text(
                        "Answers- "+data[0]["questions"][index]["answers"].length.toString(),
                        style: TextStyle(
                            color: Color.fromRGBO(170, 195*(2 + (1.217672e-8 - 2)/(1 + pow ((data[0]["questions"][index]["answers"].length/0.5182484),4.14112e-8))).toInt(), 0, 1),
                            fontSize: 16)
                    ),
                    trailing:  FlatButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: (){
                        answer('Answering Q. '+data[0]["questions"][index]["name"]+'['+data[0]["questions"][index]["part"]+']', data[0]["questions"][index]["id"].toString() );
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Answer"),
                    ),

                  ),

                ],
              ),



            ),
          );
        },
      ),
    );
  }
}









