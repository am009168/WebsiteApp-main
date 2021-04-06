import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:universal_html/html.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:flutter_app/taskInfo.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
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
  AudioPlayer audioPlayer = AudioPlayer();
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

  void playRemote(String audioLink) async {
    //Play the audio in the link stored in the currentTask object.
    await audioPlayer.play(audioLink);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.answer[0]);
    var getterPath = infoPath.doc(widget.learner);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    _toggle();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title:Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Smart-Talk Course Page'),

              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container( // image below the top bar
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left:MediaQuery.of(context).size.width * 0.25,
              top: MediaQuery.of(context).size.height * 0.42,
              child: Card(
                elevation: 8.0,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                    margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    child: Text("Response from " +widget.name,style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[SizedBox(height: 50,),
                  Image(image: AssetImage('assets/banner.png'),height:350 ,width: 750,),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.32,),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2)
                    ),
                    margin: const EdgeInsets.all(10.0),
                    width: 1500.0,
                    height: 500.0,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text('Current Task ID:\n ' , style: TextStyle(fontWeight: FontWeight.bold),),
                          StreamBuilder<DocumentSnapshot>(
                            stream: infoPath.document(widget.learner).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text("Loading");
                              }

                              if(snapshot.hasData)
                              {
                                Map<String, dynamic> docField = snapshot.data.data();
                                return Text(docField['taskid']);
                              }
                              return Text("error");
                            },
                          ),
                          new Text('\nCurrent Task Type:\n', style: TextStyle(fontWeight: FontWeight.bold)),
                          StreamBuilder<DocumentSnapshot>(
                            stream: infoPath.document(widget.learner).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text("Loading");
                              }

                              if(snapshot.hasData)
                              {
                                Map<String, dynamic> docField = snapshot.data.data();
                                return Text(docField['tasktype']);
                              }
                              return Text("error");
                            },
                          ),
                          new Text('\nNumber of User Attempts:\n', style: TextStyle(fontWeight: FontWeight.bold)),
                          StreamBuilder<DocumentSnapshot>(
                            stream: infoPath.document(widget.learner).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text("Loading");
                              }

                              if(snapshot.hasData)
                              {
                                Map<String, dynamic> docField = snapshot.data.data();
                                return Text(docField['attemptcount'].toString());
                              }
                              return Text("error");
                            },
                          ),
                          (widget.mediaLink != null)
                              ?Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              new Text("Prompt\n", style: TextStyle(fontWeight: FontWeight.bold)),
                              new SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                    onPressed: (){
                                      print(widget.answer[0]);
                                      playRemote(widget.mediaLink);},
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
                          new Text('\nResponses from Learner\n', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            RaisedButton(
                                                              onPressed: () => playRemote(widget.answer[index]),
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
                                ]
                            ),
                            visible: _visibleAudio,
                          ),

                          Visibility(
                            child: Column(
                                children: <Widget>[
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: infoPath.document(widget.learner).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Something went wrong');
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text("Loading");
                                      }

                                      if(snapshot.hasData)
                                      {
                                        Map<String, dynamic> docField = snapshot.data.data();
                                        return Text(docField['learnerresponses'].toString());
                                      }
                                      return Text("error");
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
                          Center(
                            child: NiceButton(
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
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

