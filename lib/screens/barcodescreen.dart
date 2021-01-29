import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScreen extends StatefulWidget {
  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  static const EventChannel scanChannel = EventChannel('com.example.flutterfire/scan');
  static const MethodChannel methodChannel = MethodChannel('com.example.flutterfire/command');
  String _barcodeString;
  String _barcodeSymbology;
  String _scanTime;
  bool currentlyScanning = false;

  @override
  void initState() {
    super.initState();
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _createProfile("DataWedgeFlutterfire");
  }

  void _onEvent(Object event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);
      _barcodeString = "Barcode: " + barcodeScan['scanData'];
      _barcodeSymbology = "Symbology: " + barcodeScan['symbology'];
      _scanTime = "At: " + barcodeScan['dateTime'];
    });
  }

  void _onError(Object error) {
    setState(() {
      _barcodeString = "Barcode: error";
      _barcodeSymbology = "Symbology: error";
      _scanTime = "At: error";
    });
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = "{\"command\":$command,\"parameter\":$parameter}";
      await methodChannel.invokeMethod("sendDataWedgeCommandStringParameter", argumentAsJson);
    } on PlatformException {
      // Error
    }
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      // Error
    }
  }

  void startScan() {
    setState(() {
      _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
      currentlyScanning = true;
    });
  }

  void stopScan() {
    setState(() {
      _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
      currentlyScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Container(
        child: Row(children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    children: [
                      Expanded(
                        /*1*/
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*2*/
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '$_barcodeString',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '$_barcodeSymbology',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            Text(
                              '$_scanTime',
                              style: TextStyle(
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(30.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (currentlyScanning) {
                        stopScan();
                      }
                      else {
                        startScan();
                      }
                    },
                    textColor: Colors.white,
                    color: Colors.blue,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text(
                          'SCAN',
                          style: TextStyle(fontSize: 20)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ])
      ),
    );
  }
}