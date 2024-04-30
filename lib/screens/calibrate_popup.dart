import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CalibratePopup extends StatefulWidget {
  @override
  _CalibratePopupState createState() => _CalibratePopupState();
}

class _CalibratePopupState extends State<CalibratePopup> {
  final TextEditingController _keyController = TextEditingController();
  late String validationMsg;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<String> _validateAdminKey(String enteredKey) async {
    final url = Uri.parse('https://indoor-explorer-server.onrender.com/auth');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'adminKey': enteredKey});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        if (message == 'true') {
          return 'true';
        } else {
          return 'false';
        }
      } else {
        throw Exception('Failed to validate admin key');
      }
    } catch (e) {
      throw Exception('Error occurred while validating admin key: $e');
    }
  }

  // String _encryptKey(String plainText) {
  //   final bytes = utf8.encode(plainText);
  //   final digest = sha256.convert(bytes);
  //   print("Encrypted Key: ${digest.toString()}");
  //   return digest.toString();
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin Key'),
      content: TextField(
        controller: _keyController,
        decoration: const InputDecoration(
          hintText: 'Enter your admin key',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the popup
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Navigator.of(context).pushNamed('/calibrate');  // comment this code after backend implementation
            String enteredKey = _keyController.text.trim();
            print("entered key : $enteredKey");
            try {
              String response = await _validateAdminKey(enteredKey);
              if (response == 'true') {
                Navigator.of(context).pushNamed('/calibrate');
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Wrong Key'),
                    content: const Text('The entered key is incorrect. Please try again.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('An error occurred: $e'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}