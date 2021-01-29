import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterfire/screens/uploaddetailscreen.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final imagePicker = ImagePicker();

  Future _getImageFromGallery() async {
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload image'),
      ),
      body: Center(
        child: RaisedButton.icon(
          icon: Icon(Icons.image),
          label: Text("Upload"),
          onPressed: () async {
            final File _image = await _getImageFromGallery();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadDetailScreen(_image),
              ),
            );
          },
        ),
      ),
    );
  }
}