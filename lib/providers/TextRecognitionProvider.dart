import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:excel/excel.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire/modules/scannedObject.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TextRecognitionProvider {
  var bicExcel;
  var isoExcel;

  final Map<String, int> numericalValues = {
    'A': 10,
    'B': 12,
    'C': 13,
    'D': 14,
    'E': 15,
    'F': 16,
    'G': 17,
    'H': 18,
    'I': 19,
    'J': 20,
    'K': 21,
    'L': 23,
    'M': 24,
    'N': 25,
    'O': 26,
    'P': 27,
    'Q': 28,
    'R': 29,
    'S': 30,
    'T': 31,
    'U': 32,
    'V': 34,
    'W': 35,
    'X': 36,
    'Y': 37,
    'Z': 38,
  };

  TextRecognitionProvider() {
    _loadBICExcelSheet();
    _loadISOExcelSheet();
  }

  Future<String> initializeTextVision(String path) async {
    String recognizedText = "Loading ...";
    final File imageFile = File(path);

    final FirebaseVisionImage visionImage =
    FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
    FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
    await textRecognizer.processImage(visionImage);

    recognizedText = visionText.text;
    _writeToFile(imageFile, recognizedText);

    return recognizedText;

    // for (TextBlock block in visionText.blocks) {
    //   print('Block: ${block.text}');
    //   for (TextLine line in block.lines) {
    //     print('Line: ${line.text}');
    //   }
    // }
  }

  Future<String> initializeContainerVision(String path) async {
    String recognizedText = "Loading ...";
    String containerText = '';
    final File imageFile = File(path);

    final FirebaseVisionImage visionImage =
    FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
    FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
    await textRecognizer.processImage(visionImage);

    String result = visionText.text;

    Map<String, dynamic> containerMap = {
      'Owner prefix': 'Unknown',
      'Serial number': 'Unknown',
      'Check digit': 'Unknown',
      'Size type': 'Unknown',
      'Confidence': 0,
    };
    String ownerPrefix = 'Unknown';
    String serialNumber = 'Unknown';
    String checkDigit = 'Unknown';
    String isoCode = 'Unknown';

    final containerRegex = RegExp(r'([A-Z]{3}U)[ \n]*([0-9]{3} ?[0-9]{3})[ \n]*([0-9]{1})');
    Iterable containers = containerRegex.allMatches(result);

    // Owner prefix + Equipment identifier + Container Serial Number + Check Digit
    containers.forEach((container) {
      String foundOwnerPrefix = container.group(1);
      String foundSerialNumber = container.group(2).replaceAll(new RegExp(r"\s+"), "");
      int foundCheckDigit = int.parse(container.group(3));
      String ownerPrefixSerialNumber = foundOwnerPrefix + foundSerialNumber;

      int calculatedDigit = _calculateContainerDigit(ownerPrefixSerialNumber);

      ownerPrefix = foundOwnerPrefix;
      serialNumber = foundSerialNumber;
      checkDigit = foundCheckDigit.toString();
      containerMap['Owner prefix'] = ownerPrefix;
      containerMap['Serial number'] = serialNumber;
      containerMap['Check digit'] = checkDigit;
      containerMap['Confidence'] += 75;

      if (calculatedDigit != foundCheckDigit) {
        containerMap['Confidence'] -= 25;
        containerText += "Calculated and found check digit do not match\n\n";
      }
    });

    // Switch to manual finding
    if (containerMap['Confidence'] == 0) {
      double maxConfidencePerCategory = 50 / 3;

      // Owner prefix + Equipment identifier
      final containerCodeRegex = RegExp(r'[A-Z]{3}U');
      Iterable containerCodes = containerCodeRegex.allMatches(visionText.text);
      int foundPrefixes = 0;

      containerCodes.forEach((match) {
        String text = visionText.text.substring(match.start, match.end);
        var table = bicExcel.tables['Sheet1'];
        var rows = table.rows;

        rows.forEach((row) {
          if (row.contains(text)) {
            foundPrefixes++;
            ownerPrefix = text;
            containerMap['Owner prefix'] = text;
          }
        });
      });

      if (ownerPrefix != 'Unknown') {
        containerMap['Confidence'] += (maxConfidencePerCategory / foundPrefixes);
      }

      // Container Serial Number merged with Check Digit
      final containerSerialCheckDigitMergedRegex = RegExp(r'(?! +\d+)[0-9 ]{7}([0-9]{1})|(?! +\d+)[0-9]{7}');
      Iterable containerSerialCheckDigitMerged = containerSerialCheckDigitMergedRegex.allMatches(result);

      containerSerialCheckDigitMerged.forEach((mixed) {
        result = StringUtils.addCharAtPosition(result, ' ', mixed.end - 1);
      });

      // Container Serial Number + Check Digit
      // final containerSerialNumberRegex = RegExp(r'(?! +\d+)[0-9 ]{6}([0-9]{1})?');
      final containerSerialNumberRegex = RegExp(r'([0-9]{3} ?[0-9]{3})');
      final checkDigitRegex = RegExp(r'(?<!\S)\d(?!\S)');
      Iterable containerSerialNumbers = containerSerialNumberRegex.allMatches(result);
      Iterable checkDigits = checkDigitRegex.allMatches(result);

      if (containerSerialNumbers.length > 0) {
        containerMap['Confidence'] += (maxConfidencePerCategory + 15);
      }
      containerSerialNumbers.forEach((serial) {
        String foundSerialNumber = serial.group(0).replaceAll(new RegExp(r"\s+"), "");
        String ownerPrefixSerialNumber = ownerPrefix + foundSerialNumber;
        serialNumber = foundSerialNumber;
        containerMap['Serial number'] = serialNumber;

        int calculatedDigit = _calculateContainerDigit(ownerPrefixSerialNumber);

        checkDigits.forEach((digit) {
          int foundCheckDigit = int.parse(result.substring(digit.start, digit.end));

          if (calculatedDigit == foundCheckDigit) {
            serialNumber = foundSerialNumber;
            checkDigit = foundCheckDigit.toString();
            containerMap['Serial number'] = serialNumber;
            containerMap['Check digit'] = checkDigit;
            containerMap['Confidence'] += maxConfidencePerCategory;
          }

          if (calculatedDigit != foundCheckDigit) {
            containerMap['Confidence'] -= 25;
            containerText += "Calculated and found check digit do not match\n\n";
          }
        });
      });
    }

    // ISO Code
    final isoCodeRegex = RegExp(r'(?<![A-Z\d])(?!1\d{4}(?![A-Z\d]))[A-Z\d]{4}(?![A-Z\d])');
    Iterable isoCodes = isoCodeRegex.allMatches(result);
    int foundIsoCodes = 0;

    isoCodes.forEach((iso) {
      String foundIsoCode = result.substring(iso.start, iso.end);
      var table = isoExcel.tables['Sheet1'];
      var rows = table.rows;

      rows.forEach((row) {
        if (row.toString().replaceAll(new RegExp(r"\s+"), "").contains(foundIsoCode)) {
          foundIsoCodes++;
          isoCode = foundIsoCode;
          containerMap['Size type'] = foundIsoCode;
        }
      });
    });

    if (isoCode != 'Unknown') {
      containerMap['Confidence'] += (25 / foundIsoCodes);
    }

    // Result
    containerMap.forEach((key, value) {
      if (key == 'Confidence') {
        containerText += "$key: ${value.toStringAsFixed(2)}%\n";
      }
      else {
        containerText += "$key: $value\n";
      }
    });
    containerText += "\n$ownerPrefix $serialNumber $checkDigit $isoCode";

    recognizedText = containerText;
    _writeToFile(imageFile, recognizedText);

    return recognizedText;
  }

  void _loadBICExcelSheet() async {
    ByteData data = await rootBundle.load('assets/container_bic_codelist.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    bicExcel = Excel.decodeBytes(bytes);
  }

  void _loadISOExcelSheet() async {
    ByteData data = await rootBundle.load('assets/sizetype_iso_codes.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    isoExcel = Excel.decodeBytes(bytes);
  }

  void _writeToFile(File _imageFile, String _recognizedText) async {
    final Directory appDocDir = await getExternalStorageDirectory();
    final String historyPath = '${appDocDir.path}/history.json';
    File historyFile;
    ScannedObject scannedObject = new ScannedObject(_imageFile.path, _recognizedText);

    if (FileSystemEntity.typeSync(historyPath) == FileSystemEntityType.notFound) {
      new File(historyPath).create().then((File file) {
        historyFile = file;

        var history = [scannedObject];
        historyFile.writeAsString(jsonEncode(history), mode: FileMode.writeOnly);
      });
    }
    else {
      File historyFile = File(historyPath);
      List history = jsonDecode(historyFile.readAsStringSync());

      history.add(scannedObject);
      historyFile.writeAsString(jsonEncode(history), mode: FileMode.writeOnly);
    }
  }

  bool _isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  int _calculateContainerDigit(String ownerPrefixSerialNumber) {
    try {
      int multiplier = 1;
      int total = 0;

      ownerPrefixSerialNumber.split('').forEach((element) {
        int value;

        if (!_isNumeric(element)) {
          value = numericalValues[element];
        }
        else {
          value = int.parse(element);
        }

        total += (value * multiplier);
        multiplier *= 2;
      });

      int dividedByEleven = (total / 11).round();
      int multipliedByEleven = dividedByEleven * 11;
      int difference = total - multipliedByEleven;
      return difference;
    } catch(e) {
      return -1;
    }
  }

  Widget createImage(String path) {
    return new Image(
      image: FileImage(
          File(path)
      ),
      fit: BoxFit.fill,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }
}