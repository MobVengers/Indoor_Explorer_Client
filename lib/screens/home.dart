import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF8D95FF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: (){
              Navigator.of(context).pushNamed('/get_started_screen');
              //Navigator.pop(context, GetStartedScreen());
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center( // Wrap the Column with a Center widget
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Ensure children are centered horizontally
              children: <Widget>[
                const SizedBox(height: 20),
                Image.asset(
                  "assets/stickers/home_image_1.png",
                  height: 300,
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/find_my_location');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF8D95FF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,  // Ensure the Row only takes as much space as needed
                      children: [
                        Icon(Icons.my_location_outlined, color: Colors.white),  // Search icon with white color
                        SizedBox(width: 15),  // Space between icon and text
                        Text(
                          'Find My Location',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/navigate');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF8D95FF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,  // Ensure the Row only takes as much space as needed
                      children: [
                        Icon(Icons.navigation_outlined, color: Colors.white),  // Search icon with white color
                        SizedBox(width: 15),  // Space between icon and text
                        Text(
                          'Navigate',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}