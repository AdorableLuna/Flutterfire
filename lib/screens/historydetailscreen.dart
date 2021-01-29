import 'package:flutter/material.dart';
import 'package:flutterfire/modules/scannedObject.dart';

import 'package:flutterfire/providers/TextRecognitionProvider.dart';

class HistoryDetailScreen extends StatefulWidget {
  final ScannedObject scannedObject;
  HistoryDetailScreen(this.scannedObject);

  @override
  _HistoryDetailScreenState createState() => new _HistoryDetailScreenState(scannedObject);
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  _HistoryDetailScreenState(this.scannedObject);

  final ScannedObject scannedObject;
  final TextRecognitionProvider textRecognitionProvider = new TextRecognitionProvider();
  Widget image;
  String recognizedText = "Loading ...";

  void _initializeImage() async {
    image = textRecognitionProvider.createImage(scannedObject.getImagePath());

    setState(() {
      recognizedText = scannedObject.getText();
    });
  }

  void _showInfo() {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Identified text"),
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
    _initializeImage();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Details"),
      ),
      body: recognizedText != null && image != null
          ? Stack(
        children: <Widget>[
          textRecognitionProvider.createImage(scannedObject.getImagePath()),
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
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Card(
          //     elevation: 8,
          //     color: Colors.white,
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Row(),
          //           Padding(
          //             padding: const EdgeInsets.only(bottom: 8.0),
          //             child: Text(
          //               "Identified text",
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Container(
          //             height: 200,
          //             child: SingleChildScrollView(
          //               child: Text(
          //                 recognizedText,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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