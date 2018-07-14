import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main.dart';
import 'profile_page.dart';

class RequestPost extends StatefulWidget {
  final String customerName;
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
  
  const RequestPost(
      {
        this.customerName,
        this.fromLocation,
        this.toLocation,
        this.fromAddress,
        this.toAddress,
        this.notes,
        this.requestId,
        this.price,
        this.deliveryDateStart,
        this.deliveryDateEnd,
        this.userId});

  factory RequestPost.fromJSON(Map<String, dynamic> data) {
    return new RequestPost(
      customerName: data['customerName'],
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
        customerName: this.customerName,
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
      );
}

class _RequestPost extends State<RequestPost> {
  final String customerName;
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

  bool showHeart = false;

  TextStyle boldStyle = new TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = FirebaseDatabase.instance.reference().child(
      'twopoints_requests');

  _RequestPost({
    this.customerName,
    this.fromLocation,
    this.toLocation,
    this.fromAddress,
    this.toAddress,
    this.notes,
    this.requestId,
    this.price,
    this.deliveryDateStart,
    this.deliveryDateEnd,
    this.userId});

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: new Center(child: new CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
//            buildLikeIcon(),
            new Padding(padding: const EdgeInsets.only(right: 20.0)),
            new GestureDetector(
                child: new Column(
                    children: [
                    new Text(fromAddress),
                    const Icon(
                  FontAwesomeIcons.mapPin,
                  color: Colors.green,
                  size: 25.0,
                )]),
                onTap: () {
                  goToRequestDetail(
                      context: context,
                      requestId: requestId,
                      userId: userId
                      );
                }),
          ],
        ),
        new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: new Text(
                  "$customerName ",
                  style: boldStyle,
                )),
            new Expanded(child: new Text(notes)),
          ],
        ),
        new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: new Text(
                  "$price",
                  style: boldStyle,
                )),
            new Expanded(child: new Text(notes)),
          ],
        ),
//        new Divider(height: 10.0, color: Colors.blue),
      ],
    ),
    );
  }

  /**
  void _likePost(String requestId2) {
    var userId = googleSignIn.currentUser.id;
    bool _liked = likes[userId] == true;

    if (_liked) {
      print('removing like');
      reference.child(requestId).update({
        'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        likeCount = likeCount - 1;
        liked = false;
        likes[userId] = false;
      });

      removeActivityFeedItem();
    }

    if (!_liked) {
      print('liking');
      reference.child(requestId).update({'likes.$userId': true});

      addActivityFeedItem();

      setState(() {
        likeCount = likeCount + 1;
        liked = true;
        likes[userId] = true;
        showHeart = true;
      });
      new Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }
  */

//class RequestPostFromId extends StatelessWidget {
//  final String id;
//
//  const RequestPostFromId({this.id});
//
//  getRequestPost() async {
////    var document =
////        await FirebaseDatabase.instance.reference().child('twopoints_requests').child(id).get();
////    return new RequestPost.fromDatabaseSnapshot(document);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new FutureBuilder(
//        future: getRequestPost(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData)
//            return new Container(
//                alignment: FractionalOffset.center,
//                padding: const EdgeInsets.only(top: 10.0),
//                child: new CircularProgressIndicator());
//          return snapshot.data;
//        });
//  }
//}

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

