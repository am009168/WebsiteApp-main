import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/providers/module_provider.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:flutter_app/taskInfo.dart';
import 'package:flutter_app/screens/LessonPage.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nice_button/nice_button.dart';

class responses extends StatefulWidget {
  responses({Key key, this.learner}) : super(key: key);
  // always marked "final".
  final String learner;

  //final String courseId;

  @override
  _response createState() => _response();
}

class _response extends State<responses> {
  TextEditingController imageEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var getterPath = infoPath.doc(widget.learner);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.learner + " Response",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'refresh courses',
              onPressed: () {
                setState(() {}) ;
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'add course',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CreateTask()));
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
            new Text('Current Task ID: '),
            StreamBuilder<QuerySnapshot>(
              stream: infoPath.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(document.data()['taskid']),
                    );
                  }).toList(),
                );
              },
            ),
            new Text('Current Task Type:'),
            StreamBuilder<QuerySnapshot>(
              stream: infoPath.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(document.data()['tasktype']),
                    );
                  }).toList(),
                );
              },
            ),
            new Text('Number of User Attempts:'),
            StreamBuilder<QuerySnapshot>(
              stream: infoPath.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(document.data()['attemptcount'].toString()),
                    );
                  }).toList(),
                );
              },
            ),
            new Text('Responses from Learner'),
            StreamBuilder<QuerySnapshot>(
              stream: infoPath.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(document.data()['learnerresponses'].toString()),

                    );
                  }).toList(),
                );
              },
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: imageEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Give Feedback',
                ),
              ),
            ),
            NiceButton(
              width: 500,
              elevation: 1.0,
              radius: 52.0,
              text: " Submit",
              background: Colors.black,
              onPressed: () {
                getterPath.updateData({'designerfeedback': imageEditingController.text.trim()});
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Success!'),
                      content: Text('Feedback to user has been submitted'),
                    )
                );
                finPath.updateData({'hasfeedback': FieldValue.arrayUnion([widget.learner])});
              },
            ),
          ],
        ),
      ),
    );
  }
}
