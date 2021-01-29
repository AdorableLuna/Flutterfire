import 'package:flutter/material.dart';
import 'package:flutterfire/providers/TextRecognitionProvider.dart';
import 'dart:ui';

class ContainerDetailsScreen extends StatefulWidget {
  final String imagePath;
  ContainerDetailsScreen(this.imagePath);

  @override
  _ContainerDetailsScreenState createState() => new _ContainerDetailsScreenState(imagePath);
}

class _ContainerDetailsScreenState extends State<ContainerDetailsScreen> {
  _ContainerDetailsScreenState(this.path);

  final String path;
  final TextRecognitionProvider textRecognitionProvider = new TextRecognitionProvider();
  String recognizedText;
  Widget image;

  void _initializeVision() async {
    recognizedText = await textRecognitionProvider.initializeContainerVision(path);
    _initializeImage();
    setState(() {});
  }

  void _initializeImage() {
    image = textRecognitionProvider.createImage(path);
    _showInfo();
  }

  void _showInfo() {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Identified container"),
      content: Text(recognizedText),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Container Details"),
      ),
      body: recognizedText != null && image != null
          ? Stack(
        children: <Widget>[
          image,
          Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onPressed: _showInfo,
              )
          ),
        ],
      )
          : Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}