import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

Future<String?> getCompanyLogoImagePath() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('company_logo');
}

Future<String?> getCompanyName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('company_name');
}

class SettingsState extends State<Settings> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

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
          "Settings", 
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "Company Logo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder<String?>(
                      future: getCompanyLogoImagePath(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                          return GestureDetector(
                            onTap: () async {
                              await selectImage();
                              setState(() {});
                            },
                            child: Image.file(File(snapshot.data!))
                          );
                        } else {
                          return SizedBox(
                            height: 50,
                            width: 50,
                            child: IconButton(
                              onPressed: () async {
                                await selectImage();
                                setState(() {});
                              },
                              icon: Icon(Icons.add),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), 
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: FutureBuilder<String?>(
                future: getCompanyName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                    _controller.text = snapshot.data!;
                  } else {
                    _controller.text = "";
                  }
                  return TextField(
                    controller: _controller,
                    onSubmitted: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString("company_name", value);
                    },
                    maxLines: 1,
                    maxLength: 50,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.grey.shade100,
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)
                        ),
                      labelStyle: TextStyle(color: Colors.grey.shade300),
                      labelText: "Company Name",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      helperStyle: TextStyle(color: Colors.grey.shade300),
                    ),
                  );
                },
              ),
              
            ),
           
          ],
        ),
      ),

    );
  }

  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = basename(image.path);
      final localImagePath = '${directory.path}/$fileName';
      
      final savedImage = await File(image.path).copy(localImagePath);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("company_logo", savedImage.path);
    }
  }

}