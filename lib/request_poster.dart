import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;

class RequestPoster extends StatefulWidget {
  _RequestPoster createState() => new _RequestPoster();
}

class _RequestPoster extends State<RequestPoster> {
  File file;
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();

  bool uploading = false;
  bool promted = false;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  static const String DROP_OFF_BY_SENDER = 'Drop off by sender';
  static const String PICK_UP_BY_COURIER = 'Pick up by courier';
  static const String NEGOTABLE = 'Negotiable';
  static const String PICK_UP_BY_RECIPIENT = 'Pick up by Recipient';
  static const String DROP_OFF_BY_COURIER = 'Drop off by courier';

  Map<String, String>_dictionary = {
    DROP_OFF_BY_SENDER: 'SD',
    PICK_UP_BY_COURIER: 'SP',
    NEGOTABLE: 'NG',
    PICK_UP_BY_RECIPIENT: 'DP',
    DROP_OFF_BY_COURIER: 'DD',
  };

  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  List<String> _sourceHandlingTypes = <String>[
    DROP_OFF_BY_SENDER,
    PICK_UP_BY_COURIER,
    NEGOTABLE,
  ];
  List<String> _destHandlingTypes = <String>[
    PICK_UP_BY_RECIPIENT,
    DROP_OFF_BY_COURIER,
    NEGOTABLE,
  ];

  String _color = '';
  String _sourceHandlingType = 'SD';
  String _destHandlingType = 'DP';

  DateTime _fromDate = new DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 12, minute: 30);
  DateTime _toDate = new DateTime.now().add(new Duration(days: 1));
  TimeOfDay _toTime = const TimeOfDay(hour: 19, minute: 30);

  @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Post Delivery Request'),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.phone),
                      hintText: 'Enter sender phone#',
                      labelText: 'Phone',
                    ),
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.location_city),
                      hintText: 'Enter recipient address',
                      labelText: 'Address',
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.explore),
                      hintText: 'Enter estimated package weight',
                      labelText: 'Package Weight',
                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.payment),
                      hintText: 'Enter the price',
                      labelText: 'Offer',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  new _DateTimePicker(
                    labelText: 'Delivery date range start',
                    selectedDate: _fromDate,
                    selectedTime: _fromTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _fromDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _fromTime = time;
                      });
                    },
                  ),
                  new _DateTimePicker(
                    labelText: 'Delivery date range end',
                    selectedDate: _toDate,
                    selectedTime: _toTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _toDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _toTime = time;
                      });
                    },
                  ),
                  new InputDecorator(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.color_lens),
                      hintText: 'Select the type of handling at the source',
                      labelText: 'Source',
                    ),
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: _sourceHandlingType,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _sourceHandlingType = newValue;
                          });
                        },
                        items: _sourceHandlingTypes.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: _dictionary[value],
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  new InputDecorator(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.color_lens),
                      hintText: 'Select the type of handling at the destination',
                      labelText: 'Destination',
                    ),
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: _destHandlingType,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _destHandlingType = newValue;
                          });
                        },
                        items: _destHandlingTypes.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: _dictionary[value],
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: new RaisedButton(
                        child: const Text('Submit'),
                        onPressed: null,
                      )),
                ],
              ))),
    );
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

void postToFirebase(
    {String mediaUrl, String location, String description}) async {
  var reference = FirebaseDatabase.instance.reference().child('twopoints_requests');

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

// from https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/date_and_time_picker_demo.dart
class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectedTime,
    this.selectDate,
    this.selectTime
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101)
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime
    );
    if (picked != null && picked != selectedTime)
      selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
        const SizedBox(width: 12.0),
        new Expanded(
          flex: 3,
          child: new _InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () { _selectTime(context); },
          ),
        ),
      ],
    );
  }
}
