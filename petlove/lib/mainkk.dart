import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/screens/home_page.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key, required User user})
//       : _user = user,
//         super(key: key);

//   final User _user;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: const ImageUpload(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class AnimalDetails extends StatefulWidget {
  const AnimalDetails({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _AnimalDetailsState createState() => _AnimalDetailsState();
}

class _AnimalDetailsState extends State<AnimalDetails> {
  late User _user;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Enter Animal Details';
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 4, 50, 88),
          title: Center(child: Text(appTitle)),
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
              ),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.pets),
                  hintText: 'Enter Species of Animal',
                  labelText: 'Animal',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.my_location),
                  hintText: 'Enter location of Animal',
                  labelText: 'Location',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.report_sharp),
                  hintText: 'Give description of the Animal',
                  labelText: 'Description',
                ),
              ),
              new Container(
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                  child: new RaisedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      if (_user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ImageUpload(
                              user: _user,
                            ),
                          ),
                        );
                      }
                    },
                  )),
            ],
          ),
        ));
  }
}

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
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.pets),
              hintText: 'Enter Species of Animal',
              labelText: 'Animal',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.my_location),
              hintText: 'Enter location of Animal',
              labelText: 'Location',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.report_sharp),
              hintText: 'Give description of the Animal',
              labelText: 'Description',
            ),
          ),
          new Container(
              padding: const EdgeInsets.only(left: 150.0, top: 40.0),
              child: new RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ImageUpload(
                          user: _user,
                        ),
                      ),
                    );
                  }
                },
              )),
        ],
      ),
    );
  }
}

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  late User _user;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  File? image;

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
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Upload image of Animal"),
          backgroundColor: Color.fromARGB(255, 4, 50, 88),
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
                  if (_user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AnimalDetails(
                          user: _user,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                  color: Color.fromARGB(255, 4, 50, 88),
                  child: const Text("Pick Image from Gallery",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    pickImage();
                  }),
              MaterialButton(
                  color: Color.fromARGB(255, 4, 50, 88),
                  child: const Text("Pick Image from Camera",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    pickImageC();
                  }),
              SizedBox(
                height: 20,
              ),
              new Container(
                  child: new RaisedButton(
                child: const Text('Submit Image'),
                onPressed: () {
                  if (_user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RequestFormSubmitted(
                          user: _user,
                        ),
                      ),
                    );
                  }
                },
              )),
              image != null ? Image.file(image!) : Text("No image selected"),
            ],
          ),
        ));
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
          children: [
            Text("Request Submitted Succesfully!"),
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
