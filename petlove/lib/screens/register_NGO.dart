import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:petlove/widgets/firebase_upload.dart';
import 'package:petlove/widgets/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:petlove/screens/NGO_home_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class getdocs {
  static Future<List<DocumentSnapshot>> existsngo(String? uid) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    NGOModel dataNGO = NGOModel();
    int exists = 0;
    // writing all the values

    final List<DocumentSnapshot> docs;
    QuerySnapshot result = await firebaseFirestore
        .collection('NGOs')
        .where('uid', isEqualTo: uid)
        .get();
    docs = result.docs;

    return docs;
  }
}

class NGOregistration extends StatefulWidget {
  const NGOregistration({Key? key, required String? uid})
      : _uid = uid,
        super(key: key);

  final String? _uid;

  @override
  State<NGOregistration> createState() => _NGOregistrationState();
}

class _NGOregistrationState extends State<NGOregistration> {
  late String? _uid;

  @override
  void initState() {
    _uid = widget._uid;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text('Switch Accounts'),
        centerTitle: true,
      ),
      body: new Container(
          padding: const EdgeInsets.only(left: 150.0, top: 40.0),
          child: new RaisedButton(
            child: const Text('Switch'),
            onPressed: () async {
              List<DocumentSnapshot> exists = await getdocs.existsngo(_uid);
              if (exists.isEmpty) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => registration(
                      uid: _uid,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NGOHomePage(
                      uid: _uid,
                    ),
                  ),
                );
              }
            },
          )),
    );
  }
}

class home_NGO extends StatefulWidget {
  const home_NGO({Key? key, required String? uid})
      : _uid = uid,
        super(key: key);

  final String? _uid;
  @override
  State<home_NGO> createState() => _home_NGOState();
}

class _home_NGOState extends State<home_NGO> {
  late String? _uid;
  @override
  void initState() {
    _uid = widget._uid;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        "This is NGO home page and user id is ${_uid}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class registration extends StatefulWidget {
  const registration({Key? key, required String? uid})
      : _uid = uid,
        super(key: key);

  final String? _uid;

  @override
  _registrationState createState() => _registrationState();
}

class _registrationState extends State<registration> {
  late String? _uid;
  UploadTask? task;
  UploadTask? imagetask;
  File? file;
  File? image;
  String? fileURL;
  String? dpURL;
  FirebaseStorage storage = FirebaseStorage.instance;
  var uploadstat = 0;
  var imageuploadstat = 0;
  late LatLng location;
  late GeoFirePoint geopoint;
  Geoflutterfire geo = Geoflutterfire();


  @override
  void initState() {
    _uid = widget._uid;

    super.initState();
  }

  final _auth = FirebaseAuth.instance;

  CollectionReference NGOs = FirebaseFirestore.instance.collection('NGOs');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  int role = 1;

  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final OrganizationEditingController = new TextEditingController();
  final phoneNumberEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => setCurrentLocation(
            uid: _uid,
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
    final fileName =
        file != null ? Path.basename(file!.path) : 'No File Selected';
    final imageName =
        image != null ? Path.basename(image!.path) : 'No Image Selected';
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.green;
      }
      return Colors.pink;
    }

    //first name field
    final OrganizationField = TextFormField(
      style: TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: OrganizationEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Name cannot be Empty");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid name(Min. 3 Character)");
        }
        return null;
      },
      onSaved: (value) {
        OrganizationEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 4, 50, 88)),
          borderRadius: BorderRadius.circular(5.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 50, 88),
          ),
        ),
        prefixIcon: Icon(
          Icons.group_add_sharp,
          color: Color.fromARGB(255, 4, 50, 88),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: "Name of the Organization",
        labelStyle: TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );

    //second name field
    final phoneNumberField = TextFormField(
      style: TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: phoneNumberEditingController,
      keyboardType: TextInputType.name,
      // validator: (value) {
      //   RegExp regex = new RegExp(
      //       "/(\+\d{1,3}\s?)?((\(\d{3}\)\s?)|(\d{3})(\s|-?))(\d{3}(\s|-?))(\d{4})(\s?(([E|e]xt[:|.|]?)|x|X)(\s?\d+))?/g");
      //   if (value!.isEmpty) {
      //     return ("Contact cannot be Empty");
      //   }
      //   if (!regex.hasMatch(value)) {
      //     return ("Enter Valid Contact Number)");
      //   }
      //   return null;
      // },
      onSaved: (value) {
        phoneNumberEditingController.text = value!;
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 4, 50, 88)),
          borderRadius: BorderRadius.circular(5.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 50, 88),
          ),
        ),
        prefixIcon: Icon(
          Icons.contact_phone,
          color: Color.fromARGB(255, 4, 50, 88),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: "Contact",
        labelStyle: TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );

    //email field
    final emailField = TextFormField(
      style: TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 4, 50, 88)),
          borderRadius: BorderRadius.circular(5.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 4, 50, 88),
          ),
        ),
        prefixIcon: Icon(
          Icons.email,
          color: Color.fromARGB(255, 4, 50, 88),
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: "Email",
        labelStyle: TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );

    //password field

    //signup button
    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(3),
      color: Color.fromARGB(255, 4, 50, 88),
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signUp(_uid);
          },
          child: Text(
            "Register",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(
                    //     height: 180,
                    //     child: Image.asset(
                    //       "assets/logo.png",
                    //       fit: BoxFit.contain,
                    //     )),
                    // SizedBox(height: 45),
                    OrganizationField,
                    SizedBox(height: 20),
                    emailField,
                    SizedBox(height: 20),
                    phoneNumberField,
                    SizedBox(height: 20),
                    // choose location button
                    MaterialButton(
                  color: Color.fromARGB(255, 4, 50, 88),
                  child: const Text("Choose NGO location",
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

                    //upload logo button
                    ButtonWidget(
                      text: 'Upload logo',
                      icon: Icons.cloud_upload_outlined,
                      onClicked: uploadImage,
                    ),
                    SizedBox(height: 8),
                    Text(
                      imageName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    imagetask != null
                        ? buildUploadStatus(imagetask!)
                        : Container(),
                    // upload file button
                    ButtonWidget(
                      text: 'Upload File',
                      icon: Icons.cloud_upload_outlined,
                      onClicked: uploadFile,
                    ),
                    SizedBox(height: 8),
                    Text(
                      fileName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    task != null ? buildUploadStatus(task!) : Container(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                    if (uploadstat == 1 && imageuploadstat == 1) ...[
                      SizedBox(
                        height: 20,
                      ),
                      signUpButton,
                      SizedBox(height: 15),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  postDetailsToFirestore(String? uid) async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    NGOModel dataNGO = NGOModel();

    // writing all the values
    dataNGO.email = emailEditingController.text;
    dataNGO.uid = uid;
    dataNGO.Organization = OrganizationEditingController.text;
    dataNGO.phoneNumber = phoneNumberEditingController.text;
    dataNGO.verified = role;
    dataNGO.certificate = fileURL;
    dataNGO.dpURL = dpURL;
    dataNGO.location = geopoint.geoPoint;

    await firebaseFirestore.collection("NGOs").doc(uid).set(dataNGO.toMap());
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NGOHomePage(uid: _uid)),
        (route) => false);
  }

  void signUp(String? uid) async {
    if (_formKey.currentState!.validate()) {
      postDetailsToFirestore(uid);
    }
  }

  Future uploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    final path = result.files.single.path!;

    setState(() => file = File(path));

    if (file == null) return;

    final fileName = Path.basename(file!.path);
    final destination = 'files/$fileName';

    setState(() {
      task = FirebaseApi.uploadFile(destination, file!);
    });

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    setState(() {
      fileURL = urlDownload;
    });

    print('Download-Link: $urlDownload');
    setState(() {
      uploadstat = 1;
    });

    return urlDownload;
  }

  Future uploadImage() async {
    //if (image == null) return;
    try {
      final image_file =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image_file == null) return;

      final imageTemp = File(image_file.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    final fileName = Path.basename(image!.path);
    final destination = 'files/$fileName';
    setState(() {
      imagetask = FirebaseApi.uploadFile(destination, image!);
    });

    if (imagetask == null) return;

    try {
      final ref = FirebaseStorage.instance.ref(destination).child('file/');
      UploadTask task1 = ref.putFile(image!);
      String imgUrl = await (await task1).ref.getDownloadURL();
      setState(() {
        dpURL = imgUrl;
      });
      setState(() {
        imageuploadstat = 1;
      });
      print(imageuploadstat);
      print(imgUrl);
      return imgUrl;
    } catch (e) {
      print('error occured');
    }
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}

class setCurrentLocation extends StatefulWidget {
  const setCurrentLocation({Key? key, required String? uid})
      : uid = uid,
        super(key: key);
  final String? uid;
  @override
  State<setCurrentLocation> createState() => _setCurrentLocationState();
}

class _setCurrentLocationState extends State<setCurrentLocation> {
  late String? uid;
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
