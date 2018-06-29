import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;

class Uploader extends StatefulWidget {
  _Uploader createState() => new _Uploader();
}

class _Uploader extends State<Uploader> {
  File file;
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();

  bool uploading = false;
  bool promted = false;

  @override
  initState() {
    if (file == null && promted == false && pageController.page == 2) {
      _selectImage();
      setState(() {
        promted = true;
      });
    }

    super.initState();
  }

  Widget build(BuildContext context) {
    return file == null
        ? new IconButton(
            icon: new Icon(Icons.file_upload), onPressed: _selectImage)
        : new Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: new AppBar(
              backgroundColor: Colors.white70,
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: clearImage),
              title: const Text(
                'Post to',
                style: const TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: postImage,
                    child: new Text(
                      "Post",
                      style: new TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: new ListView(
              children: <Widget>[
                new PostForm(
                  imageFile: file,
                  descriptionController: descriptionController,
                  locationController: locationController,
                  loading: uploading,
                ),
              ],
            ));
  }

  _selectImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            new SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  setState(() {
                    file = imageFile;
                  });
                }),
            new SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = imageFile;
                  });
                }),
            new SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void compressImage() async {
    print('startin');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);

    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    Im.copyResize(image, 500);

//    image.format = Im.Image.RGBA;
//    Im.Image newim = Im.remapColors(image, alpha: Im.LUMINANCE);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      file = newim2;
    });
    print('done');
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  void postImage() {
    setState(() {
      uploading = true;
    });
    compressImage();
    Future<String> upload = uploadImage(file).then((String data) {
      postToFirebase(mediaUrl: data, description: descriptionController.text, location: locationController.text);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }
}

class PostForm extends StatelessWidget {
  final imageFile;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;
  PostForm({this.imageFile, this.descriptionController, this.loading, this.locationController});

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        loading
            ? new LinearProgressIndicator()
            : new Padding(padding: new EdgeInsets.only(top: 0.0)),
        new Divider(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new CircleAvatar(
              backgroundImage: new NetworkImage(currentUserModel.photoUrl),
            ),
            new Container(
              width: 250.0,
              child: new TextField(
                controller: descriptionController,
                decoration: new InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            new Container(
              height: 45.0,
              width: 45.0,
              child: new AspectRatio(
                aspectRatio: 487 / 451,
                child: new Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.topCenter,
                    image: new FileImage(imageFile),
                  )),
                ),
              ),
            ),
          ],
        ),
        new Divider(),

        new ListTile(
          leading: new Icon(Icons.pin_drop),
          title: new Container(
            width: 250.0,
            child: new TextField(
              controller: locationController,
              decoration: new InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}

Future<String> uploadImage(var imageFile) async {
  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.put(imageFile);
  Uri downloadUrl = (await uploadTask.future).downloadUrl;
  return downloadUrl.toString();
}

void postToFirebase(
    {String mediaUrl, String location, String description}) async {
  var reference = FirebaseDatabase.instance.reference().child('twopoints_posts');

  reference.push().set({
    "username": currentUserModel.username,
    "location": location,
    "likes": {},
    "mediaUrl": mediaUrl,
    "description": description,
    "ownerId": googleSignIn.currentUser.id,
    "timestamp": new DateTime.now().toString(),
  }); // .then((DocumentReference doc) {
//    String docId = doc.childID;
//    reference.child(docId).update({"postId": docId});
//  });
}
