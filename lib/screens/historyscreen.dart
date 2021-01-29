import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterfire/modules/scannedObject.dart';
import 'package:path_provider/path_provider.dart';
import 'historydetailscreen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => new _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScannedObject> scannedObjects = [];
  List<Widget> widgetList = List();

  _HistoryScreenState() {
    _getHistory().then((value) {
      _getWidgets();
      setState(() {});
    });
  }

  Future<void> _getHistory() async {
    final Directory appDocDir = await getExternalStorageDirectory();
    final String historyPath = '${appDocDir.path}/history.json';

    if (FileSystemEntity.typeSync(historyPath) != FileSystemEntityType.notFound) {
      File historyFile = File(historyPath);
      List<dynamic> history = jsonDecode(historyFile.readAsStringSync());

      for (dynamic scannedObject in history) {
        scannedObjects.add(new ScannedObject(scannedObject['imagePath'], scannedObject['text']));
      }
    }
  }

  void _getWidgets() {
    Row row;

    for (int i = 0; i < scannedObjects.length; i++) {
      if (i.isEven) {
        row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [],
        );
      }

      row.children.add(InkWell(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Image.file(
            _getImageFile(scannedObjects[i].getImagePath()),
            cacheHeight: 200,
            cacheWidth: 110,
            fit: BoxFit.cover,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailScreen(scannedObjects[i]),
            ),
          );
        },
      ));

      if (i.isEven) {
        row.children.add(Spacer());
      }

      if (i == (scannedObjects.length - 1)) {
        widgetList.add(row);
        return;
      }

      if (i.isOdd) {
        widgetList.add(row);
      }
    }
  }

  File _getImageFile(String filePath) {
    return new File(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image History"),
      ),
      body: scannedObjects.length != 0 ? Container(
        padding: EdgeInsets.all(10),
          child: ListView(
            children:
              widgetList,
          ),
      ) : Center(
        child: Text("History is empty"),
      ),
    );
  }
}