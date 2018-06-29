import 'dart:convert';

import "package:flutter/material.dart";
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
//import 'package:location/location.dart';
import 'package:geolocation/geolocation.dart';

import 'main.dart'; //for currentuser
import 'profile_page.dart'; //for the user class

class EditProfilePage extends StatelessWidget {
  TextEditingController nameController = new TextEditingController();
  TextEditingController bioController = new TextEditingController();

  changeProfilePhoto(BuildContext Context) {
    return showDialog(
      context: Context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Change Photo'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(
                    'Changing your profile photo has not been implemented yet'),
              ],
            ),
          ),
        );
      },
    );
  }

  requestLocationPermission() async {
    final GeolocationResult result = await Geolocation.requestLocationPermission(const LocationPermission(
      android: LocationPermissionAndroid.fine,
      ios: LocationPermissionIOS.always,
    ));

    return result;
  }

  getCurrentLocation() async {
//    var currentLocation = <String, double>{};
//    var location = new Location();
//    currentLocation = await location.getLocation;

    var currentLocation = <String, double>{};


//    if(result.isSuccessful) {
    // location permission is granted (or was already granted before making the request)
    // best option for most cases
//     Geolocation.currentLocation(accuracy: LocationAccuracy.best).listen((result) {
//        if(result.isSuccessful) {
//          double latitude = result.location.latitude;
//          double longitude = result.location.longitude;
//          // todo with result
//          currentLocation["latitude"] = latitude;
//          currentLocation["longitude"] = longitude;
//
//          print('Geolocation request granted. Result:' + latitude.toString());
//        }
//      });
    LocationResult result = await Geolocation.currentLocation(accuracy: LocationAccuracy.best).single;
//    } else {
    // location permission is not granted
    // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog
//      print('Geolocation request denied.');
//    }
    return {
      "latitude":  result.location.latitude,
      "longitude": result.location.longitude
    };
  }

  applyChanges() async {
    GeolocationResult result = await requestLocationPermission();
    var mapLocation;
    if (result.isSuccessful) {
      mapLocation = await getCurrentLocation();
      print('11111Geolocation request. Result before apply:' +
          mapLocation["latitude"].toString());
    } else {
      print('Geolocation request denied');
    }

    FirebaseDatabase.instance
        .reference().child('twopoints_userInfos')
        .child(currentUserModel.id)
        .update({
      "displayName": nameController.text,
      "bio": bioController.text,
      "locations": JSON.encode(mapLocation),                // can have multiple locations
    });

  }

  Widget buildTextField({String name, TextEditingController controller}) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            name,
            style: new TextStyle(color: Colors.grey),
          ),
        ),
        new TextField(
          controller: controller,
          decoration: new InputDecoration(
            hintText: name,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: FirebaseDatabase.instance
            .reference().child('users')
            .child(currentUserModel.id)
            .once(),          // once return Futute<DataSnapshot>
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                child: new CircularProgressIndicator());

          User user = new User.fromDataSnapshot(snapshot.data);

          nameController.text = user.displayName;
          bioController.text = user.bio;

          return new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: new CircleAvatar(
                  backgroundImage: NetworkImage(currentUserModel.photoUrl),
                  radius: 50.0,
                ),
              ),
              new FlatButton(
                  onPressed: () {
                    changeProfilePhoto(context);
                  },
                  child: new Text(
                    "Change Photo",
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  )),
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                  children: <Widget>[
                    buildTextField(name: "Name", controller: nameController),
                    buildTextField(name: "Bio", controller: bioController),
                  ],
                ),
              )
            ],
          );
        });
  }

}

