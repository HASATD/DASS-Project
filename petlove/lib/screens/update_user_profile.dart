import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petlove/models/User_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';
import 'package:petlove/widgets/button_widget.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:petlove/widgets/firebase_upload.dart';

class updateProfile extends StatefulWidget {
  const updateProfile({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _updateProfileState createState() => _updateProfileState();
}

class _updateProfileState extends State<updateProfile> {
  late UserModel _user;
  UploadTask? imagetask;
  File? image;
  String? dpURL;
  FirebaseStorage storage = FirebaseStorage.instance;
  var imageuploadstat = 0;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  final _auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  int role = 1;

  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final nameEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
    final nameField = TextFormField(
      style: TextStyle(color: Color.fromARGB(255, 4, 50, 88), fontSize: 18),
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      // initialValue: _user.displayName,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("New name cannot be Empty");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid name(Min. 3 Character)");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value!;
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
        labelText: "New display name",
        labelStyle: TextStyle(color: Color.fromARGB(255, 4, 50, 88)),
      ),
    );

    //second name field

    //email field

    //password field

    //Update button
    final UpdateButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(3),
      color: Color.fromARGB(255, 4, 50, 88),
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            Update(_user);
          },
          child: Text(
            "Save Changes",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Update Profile'),
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
                      nameField,
                      SizedBox(height: 20),
                      // choose location button

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

                      SizedBox(
                        height: 20,
                      ),
                      UpdateButton,
                      SizedBox(height: 15),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateDetails(UserModel user) async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    // writing all the values

    user.displayName = nameEditingController.text;

    if (dpURL != null) {
      user.photoURL = dpURL;
    }

    await firebaseFirestore.collection("users").doc(user.uid).update({
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    });
    Fluttertoast.showToast(msg: "Details Updated Successfully :) ");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
        (route) => false);
  }

  void Update(UserModel user) async {
    if (_formKey.currentState!.validate()) {
      updateDetails(user);
    }
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
