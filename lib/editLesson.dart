import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

var infoGetter;
String stuff ;
class editLesson extends StatefulWidget {
  editLesson({Key key, this.lessonName}) : super(key: key);
  // always marked "final".
  final String lessonName;

  //final String courseId;

  @override
  _editState createState() => _editState();
}

class _editState extends State<editLesson> {
  TextEditingController nameEditingController = new TextEditingController();
  DateTime selectedDateOpen = DateTime.now();
  DateTime selectedDateClose = DateTime.now();
  bool value = false;

  Future<Null> _selectDateOpen(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateOpen,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateOpen)
      setState(() {
        selectedDateOpen = picked;
      });
  }

  Future<Null> _selectDateClose(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateClose,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateClose)
      setState(() {
        selectedDateClose = picked;
      });
  }
  @override

  Widget build(BuildContext context) {
    infoGetter = userPath.collection('Courses').doc(modName).collection('Modules').doc(lessonName).collection('Lessons').doc(widget.lessonName);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.lessonName + " Lesson",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit_outlined),
              tooltip: 'Edit Lesson',
              onPressed: () {
                setState(() {}) ;
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print("Stupid Debug Flag.");
              },
            ),
          ]),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Date open: " + "${selectedDateOpen.toLocal()}".split(' ')[0]),
            SizedBox(height: 20.0,),
            RaisedButton(
              onPressed: () => _selectDateOpen(context),
              child: Text('Select Open Date'),
            ),
            SizedBox(height: 50.0,),
            Text("Date close: " + "${selectedDateClose.toLocal()}".split(' ')[0]),
            SizedBox(height: 20.0,),
            RaisedButton(
              onPressed: () => _selectDateClose(context),
              child: Text('Select Close Date'),
            ),

            SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Make the Lesson open to users: ',
                  style: TextStyle(fontSize: 17.0),
                ),
                SizedBox(width: 10),
                Checkbox(
                  value: this.value,
                  onChanged: (bool value) {
                    setState(() {
                      this.value = value;
                    });
                    print(value);
                  },
                ),
              ],
            ),

            SizedBox(height: 20.0,),
            Container(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                    child: Text("Save Info"),
                    onPressed: () async{
                      infoGetter.updateData(
                          {
                            'isopen': value,
                            'dateopen': selectedDateOpen.toString(),
                            'dateclose': selectedDateClose.toString()
                          });
                      Navigator.pop(context, nameEditingController.text);
                    }),
              ),
            ),
             //Text
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}



