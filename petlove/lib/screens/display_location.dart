import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class displayCurrentLocation extends StatefulWidget {
  const displayCurrentLocation({Key? key, required GeoPoint pos})
      : _pos = pos,
        super(key: key);
  // final UserModel _user;
  final GeoPoint _pos;
  @override
  State<displayCurrentLocation> createState() => displayCurrentLocationState();
}

class displayCurrentLocationState extends State<displayCurrentLocation> {
  // late UserModel _user;
  late GoogleMapController _googleMapController;
  //late GeoPoint _pos;
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

  @override
  void init() {
    //_pos = widget._pos;
  }

  @override
  Widget build(BuildContext context) {
    // print(_pos);
    if (widget._pos != null) {
      return Scaffold(
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
            'Location',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget._pos.latitude, widget._pos.longitude),
            zoom: 15,
          ),
          onMapCreated: (controller) => _googleMapController = controller,
          markers: Set<Marker>.of(
            <Marker>{
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(widget._pos.latitude, widget._pos.longitude),
                infoWindow: InfoWindow(
                  title: 'Request Location',
                ),
              )
            },
          ),
        ),
      );
    } else
      return CircularProgressIndicator();
  }
}
