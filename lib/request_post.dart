import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'dart:async';
import 'profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestPost extends StatefulWidget {
  final String customerName;
  final String fromLocation;
  final String toLocation;
  final String fromAddress;
  final String toAddress;
  final String notes;
  final String requestId;
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
        this.userId});

//  factory RequestPost.fromDataSnapshot(DataSnapshot snap) {
//    return new RequestPost(
//      customerName: snap.value['customerName'],
//      location: snap.value['location'],
//      mediaUrl: snap.value['mediaUrl'],
//      likes: snap.value['likes'],
//      notes: snap.value['notes'],
//      requestId: snap.value['childID'],
//      userId: snap.value['userId'],
//    );
//  }

  factory RequestPost.fromJSON(Map data) {
    return new RequestPost(
      customerName: data['customerName'],
      fromLocation: data['fromLocation'],
      toLocation: data['toLocation'],
      fromAddress: data['fromAddress'],
      toAddress: data['toAddress'],
      notes: data['notes'],
      userId: data['userId'],
      requestId: data['requestId'],
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
      );
}

class _RequestPost extends State<RequestPost> {
  final String customerName;
  final String fromLocation;
  final String toLocation;
  final String fromAddress;
  final String toAddress;
  final String notes;
  final String requestId;
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
    this.userId});

  /**
  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = FontAwesomeIcons.heart;
    } else {
      icon = FontAwesomeIcons.heartO;
    }

    return new GestureDetector(
        child: new Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(requestId);
        });
  }

  GestureDetector buildLikeableImage() {
    return new GestureDetector(
      onDoubleTap: () => _likePost(requestId),
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
//          new FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: mediaUrl),
          new CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.fitWidth,
            placeholder: loadingPlaceHolder,
            errorWidget: new Icon(Icons.error),
          ),
          showHeart
              ? new Positioned(
            child: new Opacity(
                opacity: 0.85,
                child: new Icon(
                  FontAwesomeIcons.heart,
                  size: 80.0,
                  color: Colors.white,
                )),
          )
              : new Container()
        ],
      ),
    );
  }
*/

  buildPostHeader({String userId}) {
    if (userId == null) {
      return new Text("owner error");
    }

    return new FutureBuilder(
        future: FirebaseDatabase.instance.reference()
            .child('twopoints_users')
            .child(userId)
            .once(),
        builder: (context, snapshot) {
          String fromLocation = " ";
          String customerName = "  ";
// https://stackoverflow.com/questions/47784829/flutter-how-to-load-future-data-from-firebase-to-gridview
          if (snapshot.hasData) {
            fromLocation = snapshot.data.snapshot.value['fromLocation'];
            customerName = snapshot.data.snapshot.value['customerName'];
          }

          return new ListTile(
            leading: new CircleAvatar(
              backgroundImage: new CachedNetworkImageProvider(fromLocation),
              backgroundColor: Colors.grey,
            ),
            title: new GestureDetector(
              child: new Text(customerName, style: boldStyle),
              onTap: () {
                openProfile(context, userId);
              },
            ),
            subtitle: new Text(this.fromLocation),
            trailing: const Icon(Icons.more_vert),
          );
        });
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: new Center(child: new CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
//    liked = (likes[googleSignIn.currentUser.id.toString()] == true);

    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(userId: userId),
//        buildLikeableImage(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
//            buildLikeIcon(),
            new Padding(padding: const EdgeInsets.only(right: 20.0)),
            new GestureDetector(
                child: const Icon(
                  FontAwesomeIcons.commentO,
                  size: 25.0,
                ),
                onTap: () {
                  goToComments(
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
        )
      ],
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

  void addActivityFeedItem() {
//    FirebaseDatabase.instance.reference()
//        .child("twopoints_a_feed")
//        .child(userId)
//        .getCollection("items")
//        .child(requestId)
//        .setData({
//      "customerName": currentUserModel.customerName,
//      "userId": currentUserModel.id,
//      "type": "like",
//      "userProfileImg": currentUserModel.photoUrl,
//      "mediaUrl": mediaUrl,
//      "timestamp": new DateTime.now().toString(),
//      "requestId": requestId,
//    });
  }

  void removeActivityFeedItem() {
//    FirebaseDatabase.instance.reference()
//        .child("twopoints_a_feed")
//        .child(userId)
//        .getCollection("items")
//        .child(requestId)
//        .delete();
//  }
  }
}

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

void goToComments(
    {BuildContext context, String requestId, String userId, String mediaUrl}) {
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

