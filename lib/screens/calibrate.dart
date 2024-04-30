import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'wifi_list_popup.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Calibration extends StatefulWidget {
  const Calibration({super.key});

  @override
  State<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  Offset markerPosition = Offset(120, 620);
  int n = 0;
  List<Map<String, dynamic>> mapCalibrations = [];
  double angle = 0;
  List<WiFiAccessPoint> wifiResults = [];
  String indoorMap = 'assets/maps/sumanadasa_second_floor.png';
  double markerX = 120;
  double markerY = 620;


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

  Future<void> findMyLocation() async {
    if (Platform.isAndroid) {
      if (await requestLocationPermission()) {
        // Clear the previous results before scanning for new access points
        wifiResults.clear();

        // Perform a new Wi-Fi scan
        List<WiFiAccessPoint> scannedResults = await WiFiScan.instance.getScannedResults();

        // Filter the results for the desired SSID
        wifiResults = scannedResults.where((wifi) => wifi.ssid == 'UoM_Wireless').toList();

        if(wifiResults.isNotEmpty){
          print("Yayyy!!! non-empty wifi list\n");
          for (var wifi in wifiResults) {
            print("SSID: ${wifi.ssid}");
            print("BSSID: ${wifi.bssid}"); // MAC address
            print("Level: ${wifi.level}");
            print("markerX: $markerX");
            print("markerY: $markerY");
            print("-------------------------");
          }

          await sendFingerprintData(
            projectId: '0',
            posX: markerX, // Replace with the actual X coordinate
            posY: markerY, // Replace with the actual Y coordinate
            receivedSignals: wifiResults.map((signal) => {
              'bssid': signal.bssid,
              'ssid': signal.ssid,
              'rssi': signal.level,
            }).toList(),
          );

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

  Future<void> getWifiAccessPoints() async {
    if (Platform.isAndroid) {
      if (await requestLocationPermission()) {
        // Clear the previous results before scanning for new access points
        wifiResults.clear();

        // Perform a new Wi-Fi scan
        List<WiFiAccessPoint> scannedResults = await WiFiScan.instance.getScannedResults();

        // Filter the results for the desired SSID
        wifiResults = scannedResults.where((wifi) => wifi.ssid == 'UoM_Wireless').toList();

        if (wifiResults.isNotEmpty) {
          // Show the WiFi list popup
          showDialog(
            context: context,
            builder: (context) => WifiListPopup(wifiResults: wifiResults),
          );
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

  Future<void> sendFingerprintData({
    required String projectId,
    required double posX,
    required double posY,
    required List<Map<String, dynamic>> receivedSignals,
  }) async {
    final url = Uri.parse('https://indoor-explorer-server.onrender.com/fingerprint/create');
    final body = {
      'projectId': projectId,
      'pos_x': posX,
      'pos_y': posY,
      'received_signals': receivedSignals.map((signal) => {
        'bssid': signal['bssid'],
        'ssid': signal['ssid'],
        'rssi': signal['rssi'],
      }).toList(),
    };
    print(body);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Data sent successfully
        print('Data sent successfully');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Calibration points sent successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Error sending data
        print('Error sending data: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Error sending calibration points. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Error occurred
      print('Error occurred: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Calibrate", style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFF8D95FF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: (){
              Navigator.of(context).pushNamed('/home');
            },
          ),
        ),
        body: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              markerPosition = details.localPosition;
              markerX = markerPosition.dx; // Update markerX
              markerY = markerPosition.dy;
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
                  onPressed: findMyLocation,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  backgroundColor: Color(0xFF8D95FF),
                ),
              ),
              Positioned(
                top: 100,
                right: 10,
                child: FloatingActionButton(
                  onPressed: getWifiAccessPoints,
                  child: Icon(
                    Icons.wifi_find_sharp,
                    color: Colors.white,
                  ),
                  backgroundColor: Color(0xFF8D95FF),
                ),
              ),
              // Positioned(
              //   top: 20,
              //   left: 10,
              //   child: Text("X : ${markerPosition.dx}\nY : ${markerPosition.dy}")
              // ),
            ],
          ),
        ),
      ),
    );
  }
}