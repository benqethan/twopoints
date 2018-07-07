import 'package:flutter/material.dart';
import 'image_post.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Request extends StatefulWidget {
  _Request createState() => new _Request();
}

class _Request extends State<Request> {
  List<ImagePost> requestsData;

  @override
  void initState() {
    super.initState();
    this._loadRequest();
  }

  buildRequest() {
    if (requestsData != null) {
      return new ListView(
        children: requestsData,
      );
    } else {
      return new Container(
          alignment: FractionalOffset.center,
          child: new CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Two Points Courier',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: new RefreshIndicator(
        onRefresh: _refresh,
        child: buildRequest(),
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getRequests();

    setState(() {

    });

    return;
  }

  _loadRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("request");

    if (json != null) {
      List<Map<String, dynamic>> data =
          jsonDecode(json).cast<Map<String, dynamic>>();
      List<ImagePost> listOfRequests = _generateRequests(data);
      setState(() {
        requestsData = listOfRequests;
      });
    } else {
      _getRequests();
    }
  }

  _getRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = googleSignIn.currentUser.id.toString();
    var url = 'https://us-central1-two-points.cloudfunctions.net/getRequests?uid=' + userId;
    var httpClient = new HttpClient();

    List<ImagePost> listOfRequests;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("requests", json);
        List<Map<String, dynamic>> data =
        jsonDecode(json).cast<Map<String, dynamic>>();
        listOfRequests = _generateRequests(data);
      } else {
        result =
            'Error getting a request:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result =
          'Failed invoking the getRequests function. Exception: $exception';
    }
    print(result);

    setState(() {
      requestsData = listOfRequests;
    });
  }

  List<ImagePost> _generateRequests(List<Map<String, dynamic>> requestsData) {
    List<ImagePost> listOfRequests = [];

    for (var postData in requestsData) {
      listOfRequests.add(new ImagePost.fromJSON(postData));
    }

    return listOfRequests;
  }
}
