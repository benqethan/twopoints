import 'package:flutter/material.dart';
import 'request.dart';
import 'upload_page.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'activity_feed.dart';
import 'create_account.dart';
//import './globalStore.dart' as globalStore;

// Sign in
final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;
GoogleSignInAccount user;

// RDB
DatabaseReference usersDatabaseReference;
DatabaseReference serviceLocationsDatabaseReference;
DatabaseReference requestsDatabaseReference;
final databaseReference = FirebaseDatabase.instance.reference();
//final ref = FirebaseDatabase.instance.child('users');

// Analytics
final analytics = new FirebaseAnalytics();


User currentUserModel;


Future<Null> _silentLogin(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;

  if (user == null) {
    user = await googleSignIn.signInSilently();
  }

  if (await auth.currentUser() == null && user != null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken, accessToken: credentials.accessToken);
    analytics.logLogin();
  }
}

tryCreateUserRecord(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;

//  var x = databaseReference.child('xxxxx');
//  var y = x.child('y');
//  y.set({"value": "y value"});

  print('xxxxxxxxxxxxxxxx: tryCreateUserRecord for user:');
  if (user == null) {
    return null;
  }

  var userRecord = await databaseReference.child('twopoints_userInfos').child(user.id).once();
  if (userRecord.value == null) {
    // no user record exists, time to create

    String userName = await Navigator.push(
      context,
      // We'll create the SelectionScreen in the next step!
      new MaterialPageRoute(
          builder: (context) => new Center(
                child: new Scaffold(
                    appBar: new AppBar(
                      leading: new Container(),
                      title: new Text('Fill out missing data',
                          style: new TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: new ListView(
                      children: <Widget>[
                        new Container(
                          child: new CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0){
    // set user data under its Id

      databaseReference.child('twopoints_userInfos').child(user.id).set({
        "username": userName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "followers": {},
        "following": {},
      });
      usersDatabaseReference = databaseReference.child(user.id);
    }
  }

  // TODO: set model from userRecord. userName is not in user object!
  currentUserModel = new User(
    id: user.id,
    username: user.displayName,
    photoUrl: user.photoUrl,
    email: user.email,
    displayName: user.displayName,
    bio: "",
    followers: {},
    following: {}
  );
}

Future<Null> _ensureLoggedIn(context) async {
  user = googleSignIn.currentUser;
  if (user == null) {
    print('xxxxxxxxxx signInSilently...');
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    print('xxxxxxxxxx signIn...');
    user = await googleSignIn.signIn();

    analytics.logLogin();
    usersDatabaseReference = databaseReference.child('twopoints_userInfos'); // user.id as the node key
    serviceLocationsDatabaseReference =
        databaseReference.child('twopoints_serviceLocation');
    requestsDatabaseReference =
        databaseReference.child('twopoints_requestLocation');
  }

  print('xxxxxxxxxx finished the sign in. user:' + user.displayName);

  // for debug only:
  await auth.signOut();

  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );

    print('xxxxxxxxxx finished auth.signInWithGoogle.');

    tryCreateUserRecord(context);
  }

  usersDatabaseReference = databaseReference.child(user.id);
  serviceLocationsDatabaseReference = databaseReference.child(user.id).child('twopoints_serviceLocation');
  requestsDatabaseReference = databaseReference.child(user.id).child('twopoints_requestLocation');

  print('xxxxxxxxxx finished _ensureLoggedIn.');
}


class TwoPoints extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Two Points Courier',
      theme: new ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: Colors.blue,
          buttonColor: Colors.pink,
          primaryIconTheme: new IconThemeData(color: Colors.black)),
      home: new HomePage(title: 'Two Points Courier'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

PageController pageController;

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool triedSilentLogin = false;

  Scaffold buildLoginPage() {
    return new Scaffold(
      body: new Center(
        child: new Padding(
          padding: const EdgeInsets.only(top: 240.0),
          child: new Column(
            children: <Widget>[
              new Text(
                'Two Points Courier',
                style: new TextStyle(
                    fontSize: 60.0,
                    fontFamily: "Billabong",
                    color: Colors.black),
              ),
              new Padding(padding: const EdgeInsets.only(bottom: 100.0)),
              new GestureDetector(
                onTap: login,
                child: new Image.asset(
                  "assets/images/google_signin_button.png",
                  width: 225.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      silentLogin(context);
    }

    print('xxxxxxxxxxxxxxxxxxxx: main.dart.build');
    return googleSignIn.currentUser == null
        ? buildLoginPage()
        : new Scaffold(
            body: new PageView(
              children: [
                new Container(
                  color: Colors.white,
                  child: new Request(),
                ),
                new Container(color: Colors.white, child: new SearchPage()),
                new Container(
                  color: Colors.white,
                  child: new Uploader(),
                ),
                new Container(
                    color: Colors.white, child: new ActivityFeedPage()),
                new Container(
                    color: Colors.white,
                    child: new ProfilePage(
                      userId: googleSignIn.currentUser.id,
                    )),
              ],
              controller: pageController,
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: new BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.home, color: Colors.grey, size: 30.0),
                    title: new Container(),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.search, color: Colors.grey, size: 30.0),
                    title: new Container(),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.add_call, color: Colors.grey, size: 30.0),
                    title: new Container(),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.explore, color: Colors.grey, size: 30.0),
                    title: new Container(),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.person_outline, color: Colors.grey, size: 30.0),
                    title: new Container(),
                    backgroundColor: Colors.white),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
              type: BottomNavigationBarType.fixed,
            ),
          );
  }

  void login() async {
    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void silentLogin(BuildContext context) async {
    await _silentLogin(context);
//    setState(() {});
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}

void main() => runApp(new TwoPoints());
