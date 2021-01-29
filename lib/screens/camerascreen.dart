import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/icons/flutterfire_icons.dart';
import 'package:flutterfire/screens/uploadscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'barcodescreen.dart';
import 'containerdetailscreen.dart';
import 'historyscreen.dart';
import 'textdetailscreen.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController _controller;
  final imagePicker = ImagePicker();
  int toggleIndex = 0;
  bool textDetails = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(cameras[0], ResolutionPreset.ultraHigh, enableAudio: false);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller != null
          ? _initializeCamera()
          : null; //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }

  void _initializeCamera() {
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initalized");
      return null;
    }

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String formattedDateTime = formatter.format(now);
    // String dateTime = DateFormat('yyyy-MM-dd H-m-s')
    //     .addPattern('-')
    //     .add_Hms()
    //     .format(DateTime.now())
    //     .toString();

    // String formattedDateTime = dateTime.replaceAll(' ', '');
    print("Formatted: $formattedDateTime");

    // Retrieving the path for saving an image
    List<StorageInfo> _storageInfo = await PathProviderEx.getStorageInfo();
    final Directory storageDirectory = Directory(_storageInfo[0].rootDir);

    final Directory extDirectory = await getApplicationDocumentsDirectory();
    final String visionDir = '${storageDirectory.path}/DCIM/camera';
    // await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/$formattedDateTime.jpg';

    // Checking whether the picture is being taken
    // to prevent execution of the function again
    // if previous execution has not ended
    if (_controller.value.isTakingPicture) {
      print("Processing is in progress...");
      return null;
    }

    try {
      // Captures the image and saves it to the
      // provided path
      await _controller.takePicture(imagePath);
      //GallerySaver.saveImage(imagePath, albumName: 'OCR');

      return imagePath;
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Scanner'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Flutterfire.barcode,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _controller.value.isInitialized
          ? Stack(
        children: <Widget>[
          CameraPreview(_controller),
          Container(
            alignment: Alignment.topRight,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: RaisedButton.icon(
                icon: Icon(Icons.camera),
                label: Text("Click"),
                onPressed: () async {
                  await _takePicture().then((String path) {
                    if (path != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => textDetails ? DetailScreen(path) : ContainerDetailsScreen(path),
                        ),
                      );
                    }
                  });
                },
              ),
            ),
          )
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