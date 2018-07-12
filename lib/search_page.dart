import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import "profile_page.dart"; // needed to import for User Class
import "request_post.dart"; // needed to import for openProfile function

class SearchPage extends StatefulWidget {
  _SearchPage createState() => new _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  Future<DataSnapshot> userSnapshots;

  buildSearchField() {
    return new AppBar(
      backgroundColor: Colors.white,
      title: new Form(
        child: new TextFormField(
          decoration: new InputDecoration(labelText: 'Search for a user...'),
          onFieldSubmitted: submit,
        ),
      ),
    );
  }

  // JC: RDB's query return another snapshot vs Firestore return List<DocumentSnapshot>
//  ListView buildSearchResults(List<DataSnapshot> snapshots) {
  ListView buildSearchResults(DataSnapshot snapshot) {
    List<UserSearchItem> userSearchItems = [];

//    https://github.com/flutter/flutter/issues/18459
    for (var value in snapshot.value.values) {
      userSearchItems.add(new UserSearchItem(new User(id: value['id'],
          displayName: value['displayName'],
          email: value['email'],
          photoUrl: value['photoUrl'],
          followers: value['followers'],
          following: value['following'],
          bio: value['bio'])));
    }

//    snapshot.value.va((DataSnapshot snapshot) {
//      User user = new User.fromDataSnapshot(snapshot);
//      UserSearchItem searchItem = new UserSearchItem(user);
//      userSearchItems.add(searchItem);
//    });

    return new ListView(
      children: userSearchItems,
    );
  }

  void submit(String searchValue) async {
    Future<DataSnapshot> users = FirebaseDatabase.instance.reference()
        .child("users")
        .orderByChild('displayName')
        .equalTo(searchValue)
//        .where('displayName', isGreaterThanOrEqualTo: searchValue)
        .once();

    setState(() {
      userSnapshots = users;
    });
  }

  // TODO: https://github.com/flutter/plugins/blob/master/packages/firebase_database/example/lib/main.dart
  // query firebase database and show it: https://stackoverflow.com/questions/50870652/flutter-firebase-database-search-solved
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: buildSearchField(),
      body: userSnapshots == null
          ? new Text("")
          : new FutureBuilder<DataSnapshot>(
              future: userSnapshots,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildSearchResults(snapshot.data);
                } else {
                  return new Container(
                      alignment: FractionalOffset.center,
                      child: new CircularProgressIndicator());
                }
              }),
    );
  }
}


class UserSearchItem extends StatelessWidget {
  final User user;

  const UserSearchItem(this.user);

  // https://stackoverflow.com/questions/45442641/variable-cant-be-used-as-setter-because-it-is-final-enum

  @override
  Widget build(BuildContext context) {
    TextStyle boldStyle = new TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return new GestureDetector(
        child: new ListTile(
          leading: new CircleAvatar(
            backgroundImage: new NetworkImage(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: new Text(user.username, style: boldStyle),
          subtitle: new Text(user.displayName),
        ),
        onTap: () {
          openProfile(context, user.id);
        });
  }
}
