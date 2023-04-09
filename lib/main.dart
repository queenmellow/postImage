import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  File _image = File('file.txt');
  final picker = ImagePicker();
  final storage = FirebaseStorage.instance;
  final List<String> imageUrls = [];
  final List<String> imageDates = [];

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Text("No image was selected"),
              );
            });
      }
    });
  }

  Future uploadImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = storage.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    if (downloadUrl != null) {
      setState(() {
        imageUrls.insert(0, downloadUrl);
        imageDates.insert(
            0, DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Firebase Storage'),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 50.0),
            // Center(
            //   child: _image == null
            //       ? Text('No image selected.')
            //       : Image.file(_image),
            // ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: Text('Select Image'),
                  onPressed: pickImage,
                ),
                ElevatedButton(
                  child: Text('Upload Image'),
                  onPressed: uploadImage,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Image.network(imageUrls[index]),
                        SizedBox(height: 10.0),
                        Text(imageDates[index]),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
