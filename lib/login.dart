import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'home.dart';
import 'package:photo_view/photo_view.dart';
import 'constants.dart';

bool isEnabled = true ;
List<CameraDescription> cameras;
String name;
String id;
String loading;
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

class CameraWidget extends StatefulWidget {
  @override
  CameraState createState() => CameraState();
}


class CameraState extends State<CameraWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<CameraDescription> cameras;
  CameraController controller;
  bool isReady = false;
  bool showCamera = true;
  String imagePath;
  // Inputs
  TextEditingController nameController = TextEditingController();


  Future<String> getData() async {
    setState(() {
      isEnabled = false;
    });
    setState(() {
      loading = "Posting..";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //create multipart request for POST or PATCH method

    String api = prefs.getString("api") ?? "null";
    String user_name = prefs.getString("user_name") ?? "null";

    var request = http.MultipartRequest("POST", Uri.parse(api+"/apis/answer/"));
    //add text fields

    request.fields["qid"] = id;
    request.fields["note"] = nameController.text;
    request.fields["name"] = user_name;

    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("image", imagePath);
    //add multipart to request
    request.files.add(pic);

    try {
    var response = await request.send();
    setState(() {
      isEnabled = true;
    });

    //Get the response from the server
  //  var responseData = await response.stream.toBytes();
  //  var responseString = String.fromCharCodes(responseData);
   // print(responseString);

    if (response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }

    else {

      setState(() {
        isEnabled = true;
        loading= "Something Went Wrong, Please Try Again";
      });
    }
    } catch (e) {
      print(e);
      setState(() {
        isEnabled = true;
        loading= "Api might be expired, Go back to home and try refreshing.";
      });
    }

  }





  @override
  void initState() {
    super.initState();
    setState(() {
      loading = "Post Answer";
    });
    setupCameras();
  }

  Future<void> setupCameras() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('Qname');
    id = prefs.getString('Qid');
    try {
      cameras = await availableCameras();
      controller = new CameraController(cameras[0], ResolutionPreset.high);
      await controller.initialize();
    } on CameraException catch (_) {
      setState(() {
        isReady = false;
      });
    }
    setState(() {
      isReady = true;
    });
  }



  Widget build(BuildContext context) {

    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.black,
          elevation: 0.0,
          actions: <Widget>[
            new AbsorbPointer(

              child:Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
                child: new FlatButton(
                  child: new Text(name ?? 'Loading...',
                    style: new TextStyle(color: Colors.white, fontSize: 17),),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraWidget()),
                    );
                  },
                  highlightColor: Colors.white,
                  shape: StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
        key: scaffoldKey,
        body: AbsorbPointer(
          absorbing: !isEnabled,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Center(
                    child: showCamera
                        ? Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(

                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Center(child: cameraPreviewWidget()),
                              ),
                            )
                          ],
                        )




                        : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          imagePreviewWidget(),
                          editCaptureControlRowWidget(),
                        ]),
                  ),
                  showCamera ? captureControlRowWidget() : Container(),
                  cameraOptionsWidget(),
                  beerInfoInputsWidget()
                ],
              ),
            ))));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showInSnackBar('Camera error ${e}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget cameraOptionsWidget() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showCamera ? cameraTogglesRowWidget() : Container(),
        ],
      ),
    );
  }

  Widget cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras != null) {
      if (cameras.isEmpty) {
        return const Text('No camera found');
      } else {

        for (CameraDescription cameraDescription in cameras) {
          toggles.add(
            SizedBox(
              width: 150.0,
             child: Center(
              child: RadioListTile<CameraDescription>(
                title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
                groupValue: controller?.description,
                value: cameraDescription,
                onChanged: controller != null ? onNewCameraSelected : null,
              ),
              ),
            ),
          );
        }


      }
    }

    return Row(children: toggles);
  }

  Widget captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
    FlatButton.icon(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0))),
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    color: Colors.black,
    textColor: Colors.white,
    onPressed: controller != null && controller.value.isInitialized
    ? onTakePictureButtonPressed
        : null,
    icon: Icon(Icons.camera),
    label: Text("Capture"),
    )

      ],
    );
  }

  Widget beerInfoInputsWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 4.0),
          child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Additional Notes',
              )),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {

              return FlatButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  getData();
                },
                icon: Icon(Icons.send),
                label: Text(loading?? "Post Answer"),

              );
            },
          ),
        ),
      ],
    );
  }

  Widget editCaptureControlRowWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Align(
        alignment: Alignment.topCenter,
        child: FlatButton.icon(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              showCamera = true;
            });
          },
          icon: Icon(Icons.camera_alt),
          label: Text("Re-take"),
        ),




      ),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          showCamera = false;
          imagePath = filePath;
        });
      }
    });
  }

  void showInSnackBar(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  Widget cameraPreviewWidget() {
    if (!isReady || !controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Widget imagePreviewWidget() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: imagePath == null
                ? null
                : SizedBox(
              child: Image.file(File(imagePath)),
                //Image.file(File(imagePath)),
              height: 490.0,
            ),
          ),
        ));
  }
}