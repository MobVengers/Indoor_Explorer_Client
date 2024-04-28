import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  Offset markerPosition = Offset(120, 620);
  double angle = 0;
  String indoorMap = 'assets/maps/sumanadasa_second_floor.png';
  List<String>? dropdownItems;
  late String selectedStartPosition;
  late String selectedDestinationPosition;
  List<List<int>> pathList = [];
  List<List<int>> newPathList = [];
  double markerX = 120;
  double markerY = 620;


  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    //dropdownItems = ["Final Year Lab", "L1 Lab", "IntelliSense Lab", "HPC Lab", "Embedded Lab", "Network Lab", "Insight Hub", "Sysco Lounge", "Codegen Lab", "E Wis Lab", "Seminar Room", "CIT Studio", "Studio", "Old Codegen Lab", "Server Room", "ICE Room", "Systems Lab", "Lunch Room", "Conference Room", "Staff Room 1", "Staff Room 2", "Old Advanced Lab", "FYP Lab", "LSF Lab", "Washroom", "Stairs", "Fabric Lab", "Instructor Room", "CSE Office", "HoD Office"];
    dropdownItems = ["Final_Year_Lab", "L1_Lab", "IntelliSense_Lab", "HPC_Lab", "Embedded_Lab", "Network_Lab", "Insight_Hub", "Sysco_Lounge", "Codegen_Lab", "E_Wis_Lab", "Seminar_Room", "CIT_Studio", "Studio", "Old_Codegen_Lab", "Server_Room", "ICE_Room", "Systems_Lab", "Lunch_Room", "Conference_Room", "Staff_Room_1", "Staff_Room_2", "Old_Advanced_Lab", "FYP_Lab", "LSF_Lab", "Washroom", "Stairs", "Fabric_Lab", "Instructor_Room","CSE_Office", "HoD_Office"];
    selectedStartPosition = dropdownItems![0];
    selectedDestinationPosition = dropdownItems![1];
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

  Future<void> findNavigation() async {
    if (Platform.isAndroid) {
      if (await requestLocationPermission()) {
        await getNavigationRequest(start: selectedStartPosition, goal: selectedDestinationPosition);

      } else {
      print("Permission denied");
      }
    } else {
      print("Permission denied for ios");
    }
  }

  List<List<int>> scaleCoordinates(List<List<int>> coordinates, double scaleFactorX, double scaleFactorY) {
    return coordinates.map((point) {
      final scaledX = (point[0] - scaleFactorX).round();
      final scaledY = (point[1] - scaleFactorY).round();
      return [scaledX, scaledY];
    }).toList();
  }
  List<List<int>> insertNodes(List<List<int>> scaledPath) {
    List<List<int>> newPath = [];
    for (int i = 0; i < scaledPath.length - 1; i++) {
      int x1 = scaledPath[i][0];
      int y1 = scaledPath[i][1];
      int x2 = scaledPath[i + 1][0];
      int y2 = scaledPath[i + 1][1];
      newPath.add([x1, y1]);

      if (x1 == x2) { // y coordinate difference is zero
        int start = y1 < y2 ? y1 : y2;
        int end = y1 > y2 ? y1 : y2;
        for (int y = start + 2; y < end; y += 2) {
          newPath.add([x1, y]);
        }
      } else if (y1 == y2) { // x coordinate difference is zero
        int start = x1 < x2 ? x1 : x2;
        int end = x1 > x2 ? x1 : x2;
        for (int x = start + 2; x < end; x += 2) {
          newPath.add([x, y1]);
        }
      }
    }
    newPath.add(scaledPath.last);
    return newPath;
  }


  Future<dynamic> getNavigationRequest({
    required String start, required String goal,}) async {
    final url = Uri.parse('https://indoor-explorer-server.onrender.com/path');
    final body = {
      'start': start,
      'goal' : goal,
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
        final pathData = data['path'] as List<dynamic>;
        final path = pathData.map((e) => List<int>.from(e)).toList();
        print("Path: $path");

        final scaledPath = scaleCoordinates(path, -10, 0);
        print("Scaled path: $scaledPath");

        newPathList = insertNodes(scaledPath);
        print(newPathList);

        setState(() {
          pathList = newPathList;
        });
      }
    } catch (e) {
      // Error occurred
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Navigate", style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFF8D95FF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  child: DropdownButton<String>(
                    value: selectedStartPosition,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStartPosition = newValue!;
                      });
                    },
                    hint: Text('Start'),
                    items: dropdownItems!
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 12),),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  child: DropdownButton<String>(
                    value: selectedDestinationPosition,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDestinationPosition = newValue!;
                      });
                    },
                    hint: Text('Destination'),
                    items: dropdownItems!
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 12),),
                      );
                    }).toList(),
                  ),
                ),
                FloatingActionButton(
                  onPressed: findNavigation,
                  child: Icon(
                    Icons.navigation,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    indoorMap,
                    fit: BoxFit.contain,
                  ),
                  // Positioned(
                  //   left: markerPosition.dx,
                  //   top: markerPosition.dy,
                  //   child: Transform.rotate(
                  //     angle: angle,
                  //     child: Icon(
                  //       FontAwesomeIcons.mapPin,
                  //       color: Colors.red,
                  //       size: 30,
                  //     ),
                  //   ),
                  // ),
                  // Positioned(
                  //   top: 20,
                  //   left: 10,
                  //   child: Text("X : ${markerPosition.dx}\nY : ${markerPosition.dy}")
                  // ),
                  ...pathList.map((point) => _buildDot(point)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(List<int> point) {
    // Convert point coordinates to Offset
    final offset = Offset(point[0].toDouble(), point[1].toDouble());

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: 5.0,
        height: 5.0,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }


}