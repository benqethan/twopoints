import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main.dart';
import 'request_post.dart';
import 'dart:async';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId});

  final String userId;

  _ProfilePage createState() => new _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage> {
  final String profileId;
  String currentUserId = googleSignIn.currentUser.id;
  String view = "grid"; // default view
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  _ProfilePage(this.profileId);

  editProfile() {
    EditProfilePage editPage = new EditProfilePage();

    Navigator
        .of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              leading: new IconButton(
                icon: new Icon(Icons.close),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              title: new Text('Edit Profile',
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              actions: <Widget>[
                new IconButton(
                    icon: new Icon(
                      Icons.check,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      editPage.applyChanges();
                      Navigator.maybePop(context);
                    })
              ],
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                  child: editPage,
                ),
              ],
            )),
      );
    }));
  }

  followUser() {
    print('following user');
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    FirebaseDatabase.instance.reference().child("users/$profileId").update({
      'followers.$currentUserId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    FirebaseDatabase.instance.reference().child("users/$currentUserId").update({
      'following.$profileId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    //updates activity feed
    FirebaseDatabase.instance.reference()
        .child("twopoints_a_feed")
        .child(profileId)
        .child("items")
        .child(currentUserId)
        .set({
//      "userId": profileId,
      "username": currentUserModel.username,
      "userId": currentUserId,
      "type": "follow",
      "userProfileImg": currentUserModel.photoUrl,
      "timestamp": new DateTime.now().toString()
    });
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    FirebaseDatabase.instance.reference().child("users/$profileId").update({
      'followers.$currentUserId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    FirebaseDatabase.instance.reference().child("users/$currentUserId").update({
      'following.$profileId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    FirebaseDatabase.instance.reference()
        .child("twopoints_a_feed")
        .child(profileId)
        .child("items")
        .child(currentUserId)
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    Column buildStatColumn(String label, int number) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            number.toString(),
            style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text(
                label,
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ))
        ],
      );
    }

    Container buildFollowButton(
        {String text,
        Color backgroundcolor,
        Color textColor,
        Color borderColor,
        Function function}) {
      return new Container(
        padding: const EdgeInsets.only(top: 2.0),
        child: new FlatButton(
            onPressed: function,
            child: new Container(
              decoration: new BoxDecoration(
                  color: backgroundcolor,
                  border: new Border.all(color: borderColor),
                  borderRadius: new BorderRadius.circular(5.0)),
              alignment: Alignment.center,
              child: new Text(text,
                  style: new TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
              width: 250.0,
              height: 27.0,
            )),
      );
    }

    Container buildProfileFollowButton(User user) {
      // viewing your own profile - should show edit button
      if (currentUserId == profileId) {
        return buildFollowButton(
          text: "Edit Profile",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: editProfile,
        );
      }

      // already following user - should show unfollow button
      if (isFollowing) {
        return buildFollowButton(
          text: "Unfollow",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: unfollowUser,
        );
      }

      // does not follow user - should show follow button
      if (!isFollowing) {
        return buildFollowButton(
          text: "Follow",
          backgroundcolor: Colors.blue,
          textColor: Colors.white,
          borderColor: Colors.blue,
          function: followUser,
        );
      }

      return buildFollowButton(
          text: "loading...",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey);
    }

    Row buildImageViewButtonBar() {
      Color isActiveButtonColor(String viewName) {
        if (view == viewName) {
          return Colors.blueAccent;
        } else {
          return Colors.black26;
        }
      }

      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.grid_on, color: isActiveButtonColor("grid")),
            onPressed: () {
              changeView("grid");
            },
          ),
          new IconButton(
            icon: new Icon(Icons.list, color: isActiveButtonColor("feed")),
            onPressed: () {
              changeView("feed");
            },
          ),
        ],
      );
    }

    Container buildUserPosts() {
      Future<List<RequestPost>> getPosts() async {
        List<RequestPost> posts = [];
        var snap = await FirebaseDatabase.instance.reference()
            .child('twopoints_requests')
            .orderByChild('userId').equalTo(profileId)
//            .where('userId', isEqualTo: profileId)
            .orderByChild("requestTimeStamp")
            .once();
        for (var json in snap.value) {
          posts.add(new RequestPost.fromJSON(json));
        }
//        setState(() {
//          postCount = snap.childs.length;
//        });

        return posts.reversed.toList();
      }

      return new Container(
          child: new FutureBuilder<List<RequestPost>>(
        future: getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: new CircularProgressIndicator());
          else if (view == "grid") {
            return new Container();
            /**
            // build the grid
            return new GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
//                    padding: const EdgeInsets.all(0.5),
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data.map((RequestPost imagePost) {
                  return new GridTile(child: new ImageTile(imagePost));
                }).toList());
                */
          } else if (view == "feed") {
            return new Column(
                children: snapshot.data.map((RequestPost imagePost) {
              return imagePost;
            }).toList());
          }
        },
      ));
    }

    return new StreamBuilder(
        /*
        _messagesSubscription =
            _messagesRef.limitToLast(10).onChildAdded.listen((Event event) {
              print('Child added: ${event.snapshot.value}');
            }, onError: (Object o) {
              final DatabaseError error = o;
              print('Error: ${error.code} ${error.message}');
            });
        */
        stream: FirebaseDatabase.instance.reference()
            .child('twopoints_userInfos')
            .child(profileId)
            .once().asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                child: new CircularProgressIndicator());

          Map<dynamic, dynamic> map = snapshot.data.value;
          User user = new User.fromJSON(map);

//          if (user.followers.containsKey(currentUserId) &&
//              user.followers[currentUserId] &&
//              followButtonClicked == false) {
//            isFollowing = true;
//          }

          return new Scaffold(
              appBar: new AppBar(
                title: new Text(
                  user.username,
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
              body: new ListView(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new Column(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: new NetworkImage(user.photoUrl),
                            ),
                            new Expanded(
                              flex: 1,
                              child: new Column(
                                children: <Widget>[
                                  new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      buildStatColumn("posts", postCount),
                                      buildStatColumn("followers",
                                          _countFollowings(user.followers)),
                                      buildStatColumn("following",
                                          _countFollowings(user.following)),
                                    ],
                                  ),
                                  new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        buildProfileFollowButton(user)
                                      ]),
                                ],
                              ),
                            )
                          ],
                        ),
                        new Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15.0),
                            child: new Text(
                              user.displayName,
                              style: new TextStyle(fontWeight: FontWeight.bold),
                            )),
                        new Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 1.0),
                          child: new Text(user.bio),
                        ),
                      ],
                    ),
                  ),
                  new Divider(),
                  buildImageViewButtonBar(),
                  new Divider(height: 0.0),
                  buildUserPosts(),
                ],
              ));
        });
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }

  int _countFollowings(Map followings) {
    int count = 0;

//    void countValues(key, value) {
//      if (value) {
//        count += 1;
//      }
//    }
//
//    followings.forEach(countValues);

    return count;
  }
}

/**
class ImageTile extends StatelessWidget {
  final RequestPost imagePost;

  ImageTile(this.imagePost);

  clickedImage(BuildContext context) {
    Navigator
        .of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              title: new Text('Photo',
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                  child: imagePost,
                ),
              ],
            )),
      );
    }));
  }

  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () => clickedImage(context),
        child: new Image.network(imagePost.mediaUrl, fit: BoxFit.cover));
  }
}
*/

class User {
  const User(
      {this.username,
      this.id,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following,
      this.phone});

  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following;
  final String phone;

  factory User.fromJSON(Map snapshot) {
    return new User(
      email: snapshot['email'],
      username: snapshot['username'],
      photoUrl: snapshot['photoUrl'],
      displayName: snapshot['displayName'],
      bio: snapshot['bio'],
      phone: snapshot['phone'],
    );
  }
}
