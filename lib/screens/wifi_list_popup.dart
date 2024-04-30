import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiListPopup extends StatefulWidget {
  const WifiListPopup({Key? key, required this.wifiResults}) : super(key: key);

  final List<WiFiAccessPoint> wifiResults;

  @override
  _WifiListPopupState createState() => _WifiListPopupState();
}

class _WifiListPopupState extends State<WifiListPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nearby WiFi Access Points'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.wifiResults.length,
          itemBuilder: (context, index) {
            final wifi = widget.wifiResults[index];
            return ListTile(
              title: Text(wifi.ssid.isNotEmpty ? wifi.ssid : 'Unknown SSID'),
              subtitle: Text('BSSID: ${wifi.bssid}, Level: ${wifi.level}'),
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}