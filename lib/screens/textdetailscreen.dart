import 'package:flutter/material.dart';
import 'package:flutterfire/providers/TextRecognitionProvider.dart';
import 'dart:ui';

class DetailScreen extends StatefulWidget {
  final String imagePath;
  DetailScreen(this.imagePath);

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path);

  final String path;
  final TextRecognitionProvider textRecognitionProvider = new TextRecognitionProvider();
  String recognizedText;
  Widget image;

  Future<void> _initializeVision() async {
    recognizedText = await textRecognitionProvider.initializeTextVision(path);
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

  // Future<void> _getImageSize(File imageFile) async {
  //   final Completer<Size> completer = Completer<Size>();
  //
  //   // Fetching image from path
  //   final Image image = Image.file(imageFile);
  //
  //   // Retrieving its size
  //   image.image.resolve(const ImageConfiguration()).addListener(
  //     ImageStreamListener((ImageInfo info, bool _) {
  //       completer.complete(Size(
  //         info.image.width.toDouble(),
  //         info.image.height.toDouble(),
  //       ));
  //     }),
  //   );
  //
  //   final Size imageSize = await completer.future;
  //   setState(() {
  //     _imageSize = imageSize;
  //   });
  // }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Details"),
      ),
      body: recognizedText != null && image != null ? Stack(
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