import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  Offset markerPosition = Offset(120, 620);
  int n = 0;
  List<Map<String, dynamic>> mapCalibrations = [];
  double angle = 0;
  List<dynamic> wifiList = [];
  String indoorMap = 'assets/maps/sumanadasa_second_floor.png';

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    mapCalibrations.add({
      'projectId': 0,
      'CalibrationPointId': n,
      'received_signals': [],
      'position': {'x': 120, 'y': 300}
    });
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      print("Location Permission Granted");
      return true;
    } else {
      print("Location Permission Denied");
      return false;
    }
  }

  Future<void> getWifiAccessPoints() async {
    if (Platform.isAndroid) {
      if (await requestLocationPermission()) {
        var wifiResults = await WiFiScan.instance.getScannedResults();
        if(wifiResults.isNotEmpty){
          print("Yayyy!!! non-empty wifi list\n");
          for (var wifi in wifiResults) {
            print("SSID: ${wifi.ssid}");
            print("BSSID: ${wifi.bssid}"); // MAC address
            print("Signal Strength (dBm): ${wifi.level}");
            print("-------------------------");
          }
        } else {
          print("empty wifi list");
        }
      } else {
        print("Permission denied");
      }
    } else {
      print("Permission denied for ios");
    }
  }

  // void handleDownload() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/mapCalibrations.txt');
  //   await file.writeAsString('Data to be written');
  //   print('File written at ${file.path}');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            markerPosition = details.localPosition;
          });
        },
        child: Stack(
          children: <Widget>[
            Image.asset(
              indoorMap,
              fit: BoxFit.fitHeight,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              left: markerPosition.dx,
              top: markerPosition.dy,
              child: Transform.rotate(
                angle: angle,
                child: Icon(
                  FontAwesomeIcons.mapPin,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: FloatingActionButton(
                onPressed: getWifiAccessPoints,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black,
              ),
            ),
            // Positioned(
            //   top: 80,
            //   right: 10,
            //   child: FloatingActionButton(
            //     onPressed: handleDownload,
            //     child: Icon(
            //       Icons.download,
            //       color: Colors.white,
            //     ),
            //     backgroundColor: Colors.black,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}