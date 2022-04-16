import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  late User _user;
  File? image;
  String? imageURL;

  FirebaseStorage storage = FirebaseStorage.instance;
  final descriptionController = TextEditingController();
  final animalController = TextEditingController();
  final locationController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    descriptionController.dispose();
    animalController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future uploadFile() async {
    //if (image == null) return;
    final fileName = basename(image!.path);
    final destination = 'files/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination).child('file/');
      UploadTask task1 = ref.putFile(image!);

      String imgUrl = await (await task1).ref.getDownloadURL();

      return imgUrl;
    } catch (e) {
      print('error occured');
    }
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      return imageTemp;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          color: Color.fromARGB(255, 4, 50, 88),
          padding: EdgeInsets.all(3),
          child: Flexible(
            flex: 1,
            child: IconButton(
              tooltip: 'Go back',
              icon: const Icon(Icons.arrow_back_ios),
              alignment: Alignment.center,
              iconSize: 20,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                            user: _user,
                          )),
                );
              },
            ),
          ),
        ), //Container,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text(
          'User Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Text('Drawer Header'),
          ),
        ]),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: animalController,
              decoration: const InputDecoration(
                icon: const Icon(Icons.pets),
                hintText: 'Enter Species of Animal',
                labelText: 'Animal',
              ),
            ),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                icon: const Icon(Icons.my_location),
                hintText: 'Enter location of Animal',
                labelText: 'Location',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                icon: const Icon(Icons.report_sharp),
                hintText: 'Give description of the Animal',
                labelText: 'Description',
              ),
            ),
            Center(
              child: Column(
                children: [
                  MaterialButton(
                      color: Color.fromARGB(255, 4, 50, 88),
                      child: const Text("Pick Image from Camera",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        pickImageC();
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  new Container(
                      child: new RaisedButton(
                    child: const Text('Submit Image'),
                    onPressed: () {
                      if (image != null) {
                        uploadFile().then((value) {
                          this.imageURL = value;
                          print(this.imageURL);
                        });
                      }
                    },
                  )),
                  // image != null
                  //     ? Image.file(image!)
                  //     : Text("No image selected"),
                ],
              ),
            ),
            new Container(
                padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                child: new RaisedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    FirebaseFirestore.instance.collection('Request').add({
                      'Description': descriptionController.text,
                      'UserID': _user.uid,
                      'Location': locationController.text,
                      'ImageURL': this.imageURL,
                      'Animal': animalController.text,
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class RequestFormSubmitted extends StatefulWidget {
  const RequestFormSubmitted({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _RequestFormSubmittedState createState() => _RequestFormSubmittedState();
}

class _RequestFormSubmittedState extends State<RequestFormSubmitted> {
  late User _user;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(),
            Text(
              "Request Submitted Succesfully!",
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 4, 50, 88),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              onPressed: () {
                if (_user != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        user: _user,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Go Home',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}
