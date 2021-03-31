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

  void generateCSV(){
    List<String> rowHeader = ["Name","Address","Phone"];
    List<List<dynamic>> rows = [];
    rows.add(rowHeader); //Now lets add 5 data rows
    for(int i=0;i<5;i++){ //everytime loop executes we need to add new row
      List<dynamic> dataRow=[];
      dataRow.add("NAME :$i");
      dataRow.add("ADDRESS :$i");
      dataRow.add("PHONE:$i");
      rows.add(dataRow);
    }//now convert our 2d array into the csvlist using the plugin of csv
    String csv = const ListToCsvConverter().convert(rows);//this csv variable holds entire csv data
    final bytes = utf8.encode(csv);//NOTE THAT HERE WE USED HTML PACKAGE
    final blob = html.Blob([bytes]);//It will create downloadable object
    final url = html.Url.createObjectUrlFromBlob(blob);//It will create anchor to download the file
    final anchor = html.document.createElement('a')  as    html.AnchorElement..href = url..style.display = 'none'         ..download = 'yourcsvname.csv';       //finally add the csv anchor to body
    html.document.body.children.add(anchor);// Cause download by calling this function
    anchor.click();
    html.Url.revokeObjectUrl(url);
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
            "Response from " +widget.name,
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
            IconButton(
              icon: Icon(Icons.file_copy),
              onPressed: () {
                print("Exporting.");

              },
            )
          ]),
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
    );
  }
}

