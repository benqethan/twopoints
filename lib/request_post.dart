import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'main.dart';
import 'profile_page.dart';

class RequestPost extends StatefulWidget {
  String userName;
  dynamic fromLocation;
  dynamic toLocation;
  String fromAddress;
  String toAddress;
  String notes;
  String requestId;
  double price;
  String deliveryDateStart;
  String deliveryDateEnd;
  String userId;
  String phone;
  String weight;
  String item;
  
  RequestPost(
      {
        this.userName,
        this.fromLocation,
        this.toLocation,
        this.fromAddress,
        this.toAddress,
        this.notes,
        this.requestId,
        this.price,
        this.deliveryDateStart,
        this.deliveryDateEnd,
        this.userId,
        this.phone,
        this.weight,
        this.item});

  factory RequestPost.fromJSON(Map<String, dynamic> data) {
    return new RequestPost(
      userName: data['userName'],
      fromLocation: data['fromLocation'],
      toLocation: data['toLocation'],
      fromAddress: data['fromAddress'],
      toAddress: data['toAddress'],
      notes: data['notes'],
      userId: data['userId'],
      requestId: data['requestId'],
      price: double.tryParse(data['price'].toString()), // convert the int to double, will keep the doulbe as double
      deliveryDateStart: data['deliveryDateStart'],
      deliveryDateEnd: data['deliveryDateEnd'],
      phone: data['phone'],
      weight: data['weight'],
      item: data['item'],
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }
  

  _RequestPost createState() => new _RequestPost(
        userName: this.userName,
        fromLocation: this.fromLocation,
        toLocation: this.toLocation,
        fromAddress: this.fromAddress,
        toAddress: this.toAddress,
        notes: this.notes,
        userId: this.userId,
        requestId: this.requestId,
        price: this.price,
        deliveryDateStart: this.deliveryDateStart,
        deliveryDateEnd: this.deliveryDateEnd,
        phone: this.phone,
        weight: this.weight,
        item: this.item,
      );
}

class _RequestPost extends State<RequestPost> {
  final String userName;
  final dynamic fromLocation;
  final dynamic toLocation;
  final String fromAddress;
  final String toAddress;
  final String notes;
  final String requestId;
  final double price;
  final String deliveryDateStart;
  final String deliveryDateEnd;
  final String userId;
  final String phone;
  final String weight;
  final String item;

  TextStyle boldStyle = new TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = FirebaseDatabase.instance.reference().child(
      'twopoints_requests');

  _RequestPost({
    this.userName,
    this.fromLocation,
    this.toLocation,
    this.fromAddress,
    this.toAddress,
    this.notes,
    this.requestId,
    this.price,
    this.deliveryDateStart,
    this.deliveryDateEnd,
    this.userId,
    this.phone,
  this.weight,
  this.item});

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: new Center(child: new CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Card(
        color: Colors.lightBlue,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextField(
              textAlign: TextAlign.left,
              maxLines: 1,
              enabled: false,
              decoration: const InputDecoration(
                icon: const Icon(Icons.time_to_leave),
                labelText: 'From:',
              ),
              controller: new TextEditingController(text: "$fromAddress"),
            ),
            new TextField(
              textAlign: TextAlign.left,
              maxLines: 1,
              enabled: false,
              decoration: const InputDecoration(
                icon: const Icon(Icons.assistant_photo),
                labelText: 'To:',
              ),
              controller: new TextEditingController(text: "$toAddress"),
            ),
            new TextField(
              textAlign: TextAlign.left,
              maxLines: 1,
              enabled: false,
              decoration: const InputDecoration(
                icon: const Icon(Icons.attach_money),
                labelText: 'Price:',
              ),
              controller: new TextEditingController(text: "$price"),
            ),
            new TextField(
              textAlign: TextAlign.left,
              maxLines: 1,
              enabled: false,
              decoration: const InputDecoration(
                icon: const Icon(Icons.note),
                labelText: 'Notes:',
              ),
              controller: new TextEditingController(text: "$notes"),
            ),
          ],
        ),
      ),
      onTap: () {
        goToRequestDetail(
            context: context,
            requestId: requestId,
            userId: userId
        );
      },
    );
  }

  void openProfile(BuildContext context, String userId) {
    Navigator
        .of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new ProfilePage(userId: userId);
    }));
  }

  void goToRequestDetail(
      {BuildContext context, String requestId, String userId, String mediaUrl}) {
    print('goToRequestDetail...');
//  Navigator
//      .of(context)
//      .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
//    return new CommentScreen(
//      requestId: requestId,
//      postOwner: userId,
//      postMediaUrl: mediaUrl,
//    );
//  }));
  }

}