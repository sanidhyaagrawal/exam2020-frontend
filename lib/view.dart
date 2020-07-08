import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'login.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

String api;
//String examcode;

String id;
class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}
String Appbar = 'Loading...';

class View extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<View> {

  List data;

  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    api = prefs.getString("api") ?? "null";
    String examcode = prefs.getString("examcode") ?? "null";
    //api= prefs.getString(api) ?? null;
    id = prefs.getString('Qid');

    var response = await http.get(
      Uri.encodeFull(api+"/apis/getanswers/"+id),
    );

    this.setState(() {
      data = json.decode(response.body);
    });



    setState(() {
      Appbar =  data[0]["name"]+'['+data[0]["part"]+']';
    });


    return "Success!";
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
  @override
  void initState(){
    this.getData();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
//      backgroundColor: Colors.transparent,
          backgroundColor: Color(0x44000000),
          elevation: 0,
          title: Text('Answers for Q. '+"$Appbar"),
        ),
      ),
      //appBar: new AppBar(title: Text('Answers for Q. '+"$Appbar"), backgroundColor: Colors.black),
      body: new ListView.builder(
        itemCount: data == null ? 0 : data[0]["answers"].length,
        itemBuilder: (BuildContext context, int index){
          return new Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  isThreeLine: true,
                  title:  Text( data[0]["answers"][index]["by"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17)),//Text(data[index]["title"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new SizedBox(
                        child:  PhotoView(
                          imageProvider: CachedNetworkImageProvider(api+data[0]["answers"][index]["image"]),


                          //NetworkImage(api+data[0]["answers"][index]["image"]),
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 1.8,
                          enableRotation: true,
                          backgroundDecoration: BoxDecoration(color: Colors.white),

                        ),
                        //Image.file(File(imagePath)),
                        height: 590.0,
                      ),
                      new SelectableText(
                        data[0]["answers"][index]["note"],
                        style: new TextStyle(),
                      ),
                    ],
                  ),


                ),

              ],
            ),




          );
        },
      ),
    );
  }
}