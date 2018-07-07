import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'dart:async';
import 'profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePost extends StatefulWidget {
  const ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId,
      this.ownerId});

  factory ImagePost.fromDataSnapshot(DataSnapshot snap) {
    return new ImagePost(
      username: snap.value['username'],
      location: snap.value['location'],
      mediaUrl: snap.value['mediaUrl'],
      likes: snap.value['likes'],
      description: snap.value['description'],
      postId: snap.value['childID'],
      ownerId: snap.value['ownerId'],
    );
  }

  factory ImagePost.fromJSON(Map data) {
    return new ImagePost(
      username: data['username'],
      location: data['location'],
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      description: data['description'],
      ownerId: data['ownerId'],
      postId: data['postId'],
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

  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final likes;
  final String postId;
  final String ownerId;

  _ImagePost createState() => new _ImagePost(
        mediaUrl: this.mediaUrl,
        username: this.username,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
      );
}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  Map likes;
  int likeCount;
  final String postId;
  bool liked;
  final String ownerId;

  bool showHeart = false;

  TextStyle boldStyle = new TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = FirebaseDatabase.instance.reference().child(
      'twopoints_requests');

  _ImagePost({this.mediaUrl,
    this.username,
    this.location,
    this.description,
    this.likes,
    this.postId,
    this.likeCount,
    this.ownerId});

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
          _likePost(postId);
        });
  }

  GestureDetector buildLikeableImage() {
    return new GestureDetector(
      onDoubleTap: () => _likePost(postId),
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

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return new Text("owner error");
    }

    return new FutureBuilder(
        future: FirebaseDatabase.instance.reference()
            .child('users')
            .child(ownerId)
            .once(),
//            .get(),
        builder: (context, snapshot) {
          String imageUrl = " ";
          String username = "  ";

          if (snapshot.data != null) {
            imageUrl = snapshot.data.data['photoUrl'];
            username = snapshot.data.data['username'];
          }

          return new ListTile(
            leading: new CircleAvatar(
              backgroundImage: new CachedNetworkImageProvider(imageUrl),
              backgroundColor: Colors.grey,
            ),
            title: new GestureDetector(
              child: new Text(username, style: boldStyle),
              onTap: () {
                openProfile(context, ownerId);
              },
            ),
            subtitle: new Text(this.location),
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
    liked = (likes[googleSignIn.currentUser.id.toString()] == true);

    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(ownerId: ownerId),
        buildLikeableImage(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            buildLikeIcon(),
            new Padding(padding: const EdgeInsets.only(right: 20.0)),
            new GestureDetector(
                child: const Icon(
                  FontAwesomeIcons.commentO,
                  size: 25.0,
                ),
                onTap: () {
                  goToComments(
                      context: context,
                      postId: postId,
                      ownerId: ownerId,
                      mediaUrl: mediaUrl);
                }),
          ],
        ),
        new Row(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: new Text(
                "$likeCount likes",
                style: boldStyle,
              ),
            )
          ],
        ),
        new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: new Text(
                  "$username ",
                  style: boldStyle,
                )),
            new Expanded(child: new Text(description)),
          ],
        )
      ],
    );
  }

  void _likePost(String postId2) {
    var userId = googleSignIn.currentUser.id;
    bool _liked = likes[userId] == true;

    if (_liked) {
      print('removing like');
      reference.child(postId).update({
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
      reference.child(postId).update({'likes.$userId': true});

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

  void addActivityFeedItem() {
//    FirebaseDatabase.instance.reference()
//        .child("twopoints_a_feed")
//        .child(ownerId)
//        .getCollection("items")
//        .child(postId)
//        .setData({
//      "username": currentUserModel.username,
//      "userId": currentUserModel.id,
//      "type": "like",
//      "userProfileImg": currentUserModel.photoUrl,
//      "mediaUrl": mediaUrl,
//      "timestamp": new DateTime.now().toString(),
//      "postId": postId,
//    });
  }

  void removeActivityFeedItem() {
//    FirebaseDatabase.instance.reference()
//        .child("twopoints_a_feed")
//        .child(ownerId)
//        .getCollection("items")
//        .child(postId)
//        .delete();
//  }
  }
}

//class ImagePostFromId extends StatelessWidget {
//  final String id;
//
//  const ImagePostFromId({this.id});
//
//  getImagePost() async {
////    var document =
////        await FirebaseDatabase.instance.reference().child('twopoints_requests').child(id).get();
////    return new ImagePost.fromDatabaseSnapshot(document);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new FutureBuilder(
//        future: getImagePost(),
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
    {BuildContext context, String postId, String ownerId, String mediaUrl}) {
//  Navigator
//      .of(context)
//      .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
//    return new CommentScreen(
//      postId: postId,
//      postOwner: ownerId,
//      postMediaUrl: mediaUrl,
//    );
//  }));
}

