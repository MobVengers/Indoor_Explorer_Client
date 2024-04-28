import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class MyLocation extends StatefulWidget {
  const MyLocation({super.key});

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  Offset markerPosition = Offset(0, 0);
  double angle = 0;
  List<WiFiAccessPoint> wifiResults = [];
  String indoorMap = 'assets/maps/sumanadasa_second_floor.png';
  late double myX;
  late double myY;
  bool isLocationDataReceived = false;
  ValueNotifier<bool> isLocationDataReceivedNotifier = ValueNotifier<bool>(false);
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    isLocationDataReceived = false;
    requestLocationPermission();
    getWifiAccessPoints();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      getWifiAccessPoints();
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
        wifiResults = await WiFiScan.instance.getScannedResults();
        if(wifiResults.isNotEmpty){
          print("Yayyy!!! non-empty wifi list\n");
          for (var wifi in wifiResults) {
            print("SSID: ${wifi.ssid}");
            print("BSSID: ${wifi.bssid}");
            print("Level: ${wifi.level}");
            print("-------------------------");
          }

          await sendWifiAccessPoints(
            projectId: '0',
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

  Future<void> sendWifiAccessPoints({
    required String projectId,
    required List<Map<String, dynamic>> receivedSignals,}) async {
    final url = Uri.parse('https://indoor-explorer-server.onrender.com/mylocation');
    final body = {
      'projectId': projectId,
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
        print('Data sent successfully');
        print('Response body: ${response.body}');

        final data = jsonDecode(response.body);
        final message = data['message'];

        if (message != null && message is Map<String, dynamic>) {
          if (message != null) {
            setState(() {
              myX = message['x'];
              myY = message['y'];
              final floor = message['floor'];
              isLocationDataReceived = true;
              markerPosition = Offset(myX, myY);

              print('my X: $myX, my Y: $myY, Floor: $floor');
              print("marker position changed : ${markerPosition.dx} and ${markerPosition.dy}");
              print("Location data received = $isLocationDataReceived");
            });
          } else {
            print('Failed to get location data');
          }

      } else {
        // Error sending data
        print('Error sending data: ${response.statusCode}');
      }
    } } catch (e) {
      // Error occurred
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Find My Location", style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFF8D95FF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
          ),
        ),
        body: Stack(
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
              child: ValueListenableBuilder<bool>(
                valueListenable: isLocationDataReceivedNotifier,
                builder: (context, isLocationDataReceived, child) {
                  return Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: isLocationDataReceived ? Colors.red : Colors.red,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            // Positioned(
            //   top: 20,
            //   right: 10,
            //   child: FloatingActionButton(
            //     onPressed: getWifiAccessPoints,
            //     child: Icon(
            //       Icons.search,
            //       color: Colors.white,
            //     ),
            //     backgroundColor: Color(0xFF8D95FF),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}