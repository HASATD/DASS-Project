// ignore_for_file: avoid_unnecessary_containers, deprecated_member_use, unnecessary_new

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  Geoflutterfire geo = Geoflutterfire();
  final _formKey = GlobalKey<FormState>();
  late UserModel _user;
  //late User _user;
  File? image;
  String? imageURL;
  bool uploadingDone = false;
  late LatLng location;
  late GeoFirePoint geopoint;

  int uploadStatus = 0;

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

  uploadImage() async {
    if (image != null) {
      String response = await uploadFile();
      setState(() {
        imageURL = response;
        uploadStatus = 2;
      });
    }
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
      final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      return imageTemp;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => setCurrentLocation(
            user: _user,
          ),
        ));

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      location = result;
      geopoint =
          geo.point(latitude: location.latitude, longitude: location.longitude);
    });
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
                Navigator.pop(context);
              },
            ),
          ),
        ), //Container,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text(
          'New Request',
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
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                controller: animalController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.pets),
                  hintText: 'Enter Species of Animal',
                  labelText: 'Animal',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.report_sharp),
                  hintText: 'Give description of the Animal',
                  labelText: 'Description',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: MaterialButton(
                  color: Color.fromARGB(255, 4, 50, 88),
                  child: const Text("Choose current location",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _awaitReturnValueFromSecondScreen(context);
                    // final location = await Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) => setCurrentLocation(
                    //         user: _user,
                    //       ),
                    //     ),
                    //   );
                  }),
            ),
            const SizedBox(
              height: 10,
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
                  image != null
                      ? Container(
                          height: 300,
                          width: 300,
                          child: Image.file(
                            image!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  if (uploadStatus == 0) ...[
                    new Container(
                      child: new MaterialButton(
                          color: Color.fromARGB(255, 4, 50, 88),
                          child: const Text('Submit Image'),
                          onPressed: () {
                            uploadImage();
                            setState(() {
                              uploadStatus = 1;
                            });
                          }),
                    ),
                  ] else if (uploadStatus == 1) ...[
                    //Center(child: Text('Uploading')),
                    CircularProgressIndicator(),
                  ] else if (uploadStatus == 2) ...[
                    Center(
                      child: new Container(
                          child: new RaisedButton(
                        child: const Text('Submit'),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('Request').add({
                            'Description': descriptionController.text,
                            'UserID': _user.uid,
                            'Location': geopoint.data,
                            'ImageURL': this.imageURL,
                            'Animal': animalController.text,
                          }).then((value) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RequestFormSubmitted(
                                          user: _user,
                                        )),
                              ));
                        },
                      )),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestFormSubmitted extends StatefulWidget {
  const RequestFormSubmitted({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _RequestFormSubmittedState createState() => _RequestFormSubmittedState();
}

class _RequestFormSubmittedState extends State<RequestFormSubmitted> {
  late UserModel _user;

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

class setCurrentLocation extends StatefulWidget {
  const setCurrentLocation({Key? key, required UserModel user})
      : _user = user,
        super(key: key);
  final UserModel _user;
  @override
  State<setCurrentLocation> createState() => _setCurrentLocationState();
}

class _setCurrentLocationState extends State<setCurrentLocation> {
  late UserModel _user;
  late GoogleMapController _googleMapController;
  late Marker _currentPositionMarker;
  late Position currentPosition;
  var locationSetFlag = false;
  var newLatitude = 0.0;
  var newLongitude = 0.0;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _sendDataBack(BuildContext context) {
    if (!locationSetFlag) {
      newLatitude = currentPosition.latitude;
      newLongitude = currentPosition.longitude;
    }
    LatLng latLngToSendBack = LatLng(newLatitude, newLongitude);
    Navigator.pop(context, latLngToSendBack);
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
                Navigator.pop(context);
              },
            ),
          ),
        ), //Container,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text(
          'Set Current Location',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _determinePosition(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData) {
            return Stack(alignment: Alignment.center, children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 15,
                ),
                onMapCreated: (controller) => _googleMapController = controller,
                markers: Set<Marker>.of(
                  <Marker>{
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: locationSetFlag
                          ? LatLng(newLatitude, newLongitude)
                          : LatLng(snapshot.data!.latitude,
                              snapshot.data!.longitude),
                      infoWindow: InfoWindow(
                        title: 'Your Current Location',
                      ),
                    )
                  },
                ),
                onTap: (LatLng position) {
                  setState(() {
                    locationSetFlag = true;
                    newLatitude = position.latitude;
                    newLongitude = position.longitude;
                  });
                },
              ),
              Positioned(
                bottom: 15,
                child: MaterialButton(
                    padding:
                        EdgeInsets.only(right: 12, left: 12, top: 8, bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 10,
                    color: Color.fromARGB(255, 4, 50, 88),
                    child: const Text("Submit current location",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    onPressed: () {
                      _sendDataBack(context);
                    }),
              )
            ]);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
