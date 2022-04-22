import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';


class NGORequestsDisplay extends StatefulWidget {
  const NGORequestsDisplay({Key? key, required String? uid})
      : _uid = uid,
        super(key: key);

  final String? _uid;

  @override
  State<NGORequestsDisplay> createState() => _NGORequestsDisplayState();
}

class _NGORequestsDisplayState extends State<NGORequestsDisplay> {
  late GeoPoint NGOGeopoint;
  bool NGOGeopointInitFlag = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String? _uid;
  @override
  void initState() {
    _uid = widget._uid;
    super.initState();
  }
  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('Request');
  late final Stream<QuerySnapshot> _requestStream =
      _requestReference.snapshots();


  void getGeopoint() async{
    var collection = FirebaseFirestore.instance.collection('NGOs');
    var docSnapshot = await collection.doc(_uid).get();
    Map<String, dynamic>? data = docSnapshot.data();
    NGOGeopoint = data?['location'];
    setState(() {
      NGOGeopointInitFlag = true;
    });
    // print(NGOGeopoint); // <-- The value you want to retrieve. 
      // Call setState if needed.
  }
  
  // getGeopoint();

  @override
  Widget build(BuildContext context) {
    if (!NGOGeopointInitFlag) {
      getGeopoint();
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
          'Current Requests',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(child: CircularProgressIndicator()),),);
    }
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
          'Current Requests',
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

            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  Map map = data['Location'];
                  GeoPoint requestGeopoint = map['geopoint'];
                  // getGeopoint();
                  var distance = Geolocator.distanceBetween(
                      NGOGeopoint.latitude, NGOGeopoint.longitude,
                      requestGeopoint.latitude, requestGeopoint.longitude);
                  print(distance);
                  if(distance < 30000){
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RequestDetail(
                                      document: data,
                                    )),
                          );
                        }, // Image tapped
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: CachedNetworkImageProvider(
                                    data['ImageURL'],
                                  ),
                                ),
                                title: Text(
                                  data['Animal'],
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
                                      'REFUSE',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: () {/* ... */},
                                  ),
                                  const SizedBox(width: 16),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: ElevatedButton(
                                      child: const Text(
                                        'ACCEPT',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      onPressed: () async {},
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
                  }
                  else{
                    return Container();
                  }
                }).toList(),
              );
            } else {
              return const Center(
                child: Text("No Requests to display"),
              );
            }
          }),
    ));
  }
}

class RequestDetail extends StatelessWidget {
  const RequestDetail({required Map<String, dynamic>? document, Key? key})
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
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Color.fromARGB(255, 255, 253, 208),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: Image.network(
                          data!['ImageURL'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        'Animal : ' + data!['Animal'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Description : ' + data!['Description'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))));
  }
}

class RequestInfo extends StatefulWidget {
  const RequestInfo({Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  late Map<String, dynamic>? data;

  @override
  void initState() {
    data = widget.data;

    super.initState();
  }

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
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
              child: Container(
                child: Column(children: <Widget>[
                  Text('Animal : ' + data!['Animal']),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Description : ' + data!['Description']),
                  SizedBox(
                    height: 10,
                  ),
                ]),
              ),
            )));
  }
}
