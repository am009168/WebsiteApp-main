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
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
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
  responses({Key key, this.learner, this.name, this.type, this.asr, this.answer, this.mediaLink}) : super(key: key);
  // always marked "final".
  final String learner;
  final String name;
  final String mediaLink;
  final List answer;
  final List asr;
  final String type;

  //final String courseId;

  @override
  _response createState() => _response();
}

class _response extends State<responses> {
  TextEditingController imageEditingController = new TextEditingController();
  AudioPlayer audioPlayer;
  int index= 0;

  bool _visibleAudio = false;
  bool _visibleASR = false;
  void _toggle() {
    print(widget.type);
    if (widget.type == "constproduction" || widget.type == "unconstproduction" )
    {
      setState(() {
        _visibleAudio = true;
      });

      if (widget.type == "constproduction")
      {
        setState(() {
          _visibleASR = true;
        });
      }
    }

    else {
      setState(() {
        _visibleAudio = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  void playRemote(String audioLink) async {
    //Play the audio in the link stored in the currentTask object.
    await audioPlayer.play(audioLink);
  }

  @override
  Widget build(BuildContext context) {
    var getterPath = infoPath.doc(widget.learner);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    _toggle();
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Response from " +widget.learner,
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
            (widget.mediaLink != null)
            ?Column(
              children: [
                new Text("Prompt"),
                new SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () => playRemote(
                          widget.mediaLink),
                      child: Icon(Icons.play_arrow),
                    ),
                    RaisedButton(
                      onPressed: () => audioPlayer.pause(),
                      child: Icon(Icons.pause),
                    ),
                    RaisedButton(
                      onPressed: () => audioPlayer.stop(),
                      child: Icon(Icons.stop),
                    ),
                  ],
                ),
                new SizedBox(height: 30),
              ],
            ):Container(),
            new Text('Responses from Learner'),
            Visibility(
              child: Column(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: screenWidth, maxHeight: screenHeight - 300),
                        child: ListView.separated(
                          padding: EdgeInsets.all(10),
                          itemCount: widget.answer.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(
                            //color: Colors.blue[300],
                            color: Colors.black12,
                            height: 20,
                            thickness: 2,
                            // indent: 180,
                            //endIndent: 180,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 10),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Attempt " + index.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                fontSize: 20,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            RaisedButton(
                                              onPressed: () => playRemote(
                                                  widget.answer[index]),
                                              child: Icon(Icons.play_arrow),
                                            ),
                                            RaisedButton(
                                              onPressed: () => audioPlayer.pause(),
                                              child: Icon(Icons.pause),
                                            ),
                                            RaisedButton(
                                              onPressed: () => audioPlayer.stop(),
                                              child: Icon(Icons.stop),
                                            ),
                                          ],
                                        ),
                                      ]),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  (_visibleASR)
                                  ? Visibility(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "ASR Feedback: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                fontSize: 20,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.asr[index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    visible: _visibleASR,
                                  )
                                  :Container(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                          onPressed: () => playRemote(widget.answer[0]),
                          child: Icon(Icons.play_arrow),
                        ),
                        RaisedButton(
                          onPressed: () => audioPlayer.pause(),
                          child: Icon(Icons.pause),
                        ),
                        RaisedButton(
                          onPressed: () => print(widget.answer[0]),
                          child: Icon(Icons.stop),
                        ),
                      ],
                    ),*/
                  ]
              ),
              visible: _visibleAudio,
            ),

            Visibility(
              child: Column(
                  children: <Widget>[
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
                  ]
              ),
              visible: !_visibleAudio,
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
