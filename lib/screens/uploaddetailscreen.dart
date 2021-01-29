import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'containerdetailscreen.dart';
import 'textdetailscreen.dart';

class UploadDetailScreen extends StatefulWidget {
  final File _image;
  UploadDetailScreen(this._image);

  @override
  _UploadDetailScreenState createState() => _UploadDetailScreenState(_image);
}

class _UploadDetailScreenState extends State<UploadDetailScreen> {
  _UploadDetailScreenState(this._image);

  final File _image;
  int toggleIndex = 0;
  bool textDetails = true;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Stack(
              children: <Widget>[
                Image(
                  image: FileImage(
                      _image
                  ),
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.all(10),
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                ),
                Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(10),
                    child: ToggleSwitch(
                        initialLabelIndex: toggleIndex,
                        minWidth: 90.0,
                        cornerRadius: 5.0,
                        activeBgColor: Colors.blue,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        labels: ['Text', 'Container'],
                        onToggle: (index) {
                          if (index == 0) {
                            textDetails = true;
                          }
                          else {
                            textDetails = false;
                          }

                          toggleIndex = index;
                        }
                    )
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.only(bottom: 10),
                  child: RawMaterialButton(
                    fillColor: Colors.blueAccent,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => textDetails ? DetailScreen(_image.path) : ContainerDetailsScreen(_image.path),
                        ),
                      ).then((value) => Navigator.pop(context));
                    },
                  ),
                )
              ]
          ),
        ),
      ),
    );
  }
}