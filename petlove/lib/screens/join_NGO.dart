import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlove/screens/join_NGO_form.dart';

class NGOsDisplay extends StatefulWidget {
  const NGOsDisplay({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  State<NGOsDisplay> createState() => _NGOsDisplayState();
}

class _NGOsDisplayState extends State<NGOsDisplay> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var joinstat = 0;
  late UserModel _user;

  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('NGOs');
  late final Stream<QuerySnapshot> _requestStream =
      _requestReference.snapshots();

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ), //Container,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text(
          'Available NGOs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _requestStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic>? data =
                    document.data()! as Map<String, dynamic>?;

                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NGODetail(
                                  document: data,
                                )),
                      );
                    }, // Image tapped
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                data!['dpURL'],
                              ),
                            ),
                            title: Text(
                              data['Organization'],
                              style: TextStyle(
                                color: Color.fromARGB(255, 4, 50, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: const Text(
                                  'View',
                                  style: TextStyle(fontSize: 15),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NGODetail(
                                              document: data,
                                            )),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: ElevatedButton(
                                  child: const Text(
                                    'Join',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  onPressed: () async {
                                    if (_user.ngo_uid != null) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "You are already a member of a NGO");
                                    } else {
                                      print(data['uid']);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => JoinForm(
                                                  user: _user,
                                                  ngo_uid: data['uid'],
                                                )),
                                      );

                                      // await FirebaseFirestore.instance
                                      //     .collection('users')
                                      //     .doc(_user.uid)
                                      //     .update({
                                      //       'ngo_uid': data!['uid'],
                                      //     })
                                      //     .then((value) => print("success"))
                                      //     .catchError((error) =>
                                      //         print('Failed: $error'));
                                      // Fluttertoast.showToast(
                                      //     msg: "Request sent Successfully!");
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    ));
  }
}

class NGODetail extends StatelessWidget {
  const NGODetail({required Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: Container(
                color: Color.fromARGB(255, 4, 50, 88),
                padding: EdgeInsets.all(3),
                child: Flexible(
                  flex: 1,
                  child: IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(Icons.arrow_back),
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
                'NGO Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 4, 50, 88),
                        Color.fromARGB(255, 66, 152, 173)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.5, 0.9],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          if (data!['dpURL'] != null) ...{
                            CircleAvatar(
                              backgroundColor: Colors.white70,
                              minRadius: 60.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    CachedNetworkImageProvider(data!['dpURL']),
                                radius: 50,
                              ),
                            ),
                          } else ...{
                            CircleAvatar(
                                backgroundColor: Colors.white70,
                                minRadius: 60.0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.group,
                                    size: 50,
                                    color: Colors.blueGrey,
                                  ),
                                  radius: 50,
                                ))
                          }
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Name',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data!['Organization'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Email',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data!['email'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                        onPressed: () {},
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            'Join',
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
                  ),
                ),
              ],
            )));
  }
}
