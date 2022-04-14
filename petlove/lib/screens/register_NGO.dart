import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlove/screens/home_page.dart';

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

  @override
  Widget build(BuildContext context) {
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
      //   if (value!.isEmpty) {
      //     return ("Second Name cannot be Empty");
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
                    signUpButton,
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String? uid) async {
    if (_formKey.currentState!.validate()) {
      postDetailsToFirestore(uid);
    }
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

    await firebaseFirestore.collection("NGOs").doc(uid).set(dataNGO.toMap());
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => registration(uid: _uid)),
        (route) => false);
  }
}
