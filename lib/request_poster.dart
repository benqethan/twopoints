import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'request_post.dart';

class RequestPoster extends StatefulWidget {
  _RequestPoster createState() => new _RequestPoster();
}

class _RequestPoster extends State<RequestPoster> {
  RequestPost newRequest = new RequestPost();
  TextEditingController locationController = new TextEditingController();

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

  TextEditingController phoneController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController deliveryitemController = new TextEditingController();
  TextEditingController weightController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController notesController = new TextEditingController();

  @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    // use controller instead of onSaved callback:
    // https://stackoverflow.com/questions/45240734/flutter-form-data-disappears-when-i-scroll/45242235#45242235
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
                    inputFormatters: [
                      new WhitelistingTextInputFormatter(new RegExp(r'^[()\d -]{1,15}$')),
                    ],
                    validator: (value) => isValidPhoneNumber(value) ? null : 'Phone number must be entered as number',
                    controller: phoneController,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.location_city),
                      hintText: 'Enter recipient address',
                      labelText: 'Address',
                    ),
                    keyboardType: TextInputType.multiline,
                    controller: addressController,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.explore),
                      hintText: 'Enter the delivery item',
                      labelText: 'Delivery Item',
                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    controller: deliveryitemController,
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
                    controller: weightController,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.payment),
                      hintText: 'Enter the price',
                      labelText: 'Offer',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => double.tryParse(value) == null ? 'Price must be entered as numeric' : null,
                    controller: priceController,
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
                        onPressed: () {postToFirebase(
//                            fromAddress: addressController.text,
                            toAddress: addressController.text,
                            item: deliveryitemController.text,
                            weight: weightController.text,
                            price: double.parse(priceController.text),
                            deliveryDateStart: '',
                            deliveryDateEnd: '',
                            sourceHandlingType: _sourceHandlingType,
                            destHandlingType: _destHandlingType,
                            notes: notesController.text,
                            phone: phoneController.text);},
                      )),
                ],
              ))),
    );
  }


// TODO: improve the query perforance. https://stackoverflow.com/questions/47494373/optimizing-json-querying-performance-in-javascript
// TODO: consider to use the Firbase Function
  void postToFirebase(
      {String userName, String fromLocation, String toLocation, String fromAddress, String toAddress, String item,
        double price, String deliveryDateStart, String deliveryDateEnd, String notes, String status, String phone,
        String weight, String sourceHandlingType, String destHandlingType}) async {
    var reference = FirebaseDatabase.instance.reference().child('twopoints_requests');

    reference.push().set({
      "requstId": 123456,   // TODO
      "userName": currentUserModel.displayName,     // TODO: use the app userName. But need cost a query or offline cache
      "fromLocation": {"latitude": 123, "longitude": 456.88},   // TODO
      "toLocation": {"latitude": 125, "longitude": 458.88},     // TODO
      "fromAddress": fromAddress,
      "toAddress": toAddress,
      "requestTimeStamp": new DateTime.now().toString(),
      "item":  item,
      "price": price,
      "deliveryDateStart": deliveryDateStart,
      "deliveryDateEnd": deliveryDateEnd,
      "notes": notes,
      "status": "pending",
      "userId": googleSignIn.currentUser.id,
      "phone": phone,
      "weight": weight,
      "sourceHandlingType": sourceHandlingType,
      "destHandlingType": destHandlingType,
    });
  }

  isValidPhoneNumber(String input) {
//    final RegExp regex = new RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
//    return regex.hasMatch(input);
      return true;
  }
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
