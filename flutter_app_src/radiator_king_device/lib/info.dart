import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return InfoPageState();
  }
}

class InfoPageState extends State<InfoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF051518),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF051518),
        title: Text(
          "About", 
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.all(
                color: Colors.white,
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Condition",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Petrol",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Diesel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                  ]
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Normal",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("0-500 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("0-800 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    ),
                  ]
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Elevated",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("500-2,000 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("800-3,000 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    ),
                  ]
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Confirmed Leak",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(">2,000 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(">3,000 ppm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ]
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Visit ",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: "eblocktest.com ",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,  
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        launchUrlString("https://www.eblocktest.com");
                      }
                    ),
                    TextSpan(
                      text: " for more info ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}