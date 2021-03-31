import 'package:flutter/material.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/responses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:universal_html/html.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
var infoPath;
class taskInfo extends StatefulWidget {
  taskInfo({Key key, this.taskName, this.taskType, this.mediaLink}) : super(key: key);
  // always marked "final".
  final String taskName;
  final String taskType;
  final String mediaLink;

  //final String courseId;

  @override
  _infoState createState() => _infoState();
}
List<dynamic> row = List<dynamic>();
class _infoState extends State<taskInfo> {

  void createData() async{
    List<List<dynamic>> rows = List<List<dynamic>>();
    String name;
    String response;
    String taskID;
    rows.add(["Name","Answers","Task Type"]);
    List<dynamic> row = List<dynamic>();
    firestoreInstance.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser.uid)
        .collection('Courses').doc(modName)
        .collection('Modules').doc(lessonName)
        .collection('Lessons').doc(namePasser)
        .collection('Tasks').doc(widget.taskName).collection("TaskResponses").snapshots().forEach((element) async{

      name = element.docs[0]["firstname"];
      response = element.docs[0]["learnerresponses"].toString().replaceAll('[', '').replaceAll(']', '');
      taskID = element.docs[0]["taskid"];
      row.add(name);
      row.add(response);
      row.add(taskID);
      print(row);
      rows.add(row);
    });
    //Now lets add 5 data rows
    String csv = const ListToCsvConverter().convert(rows);//this csv variable holds entire csv data
    final bytes = utf8.encode(csv);//NOTE THAT HERE WE USED HTML PACKAGE
    final blob = html.Blob([bytes]);//It will create downloadable object
    final url = html.Url.createObjectUrlFromBlob(blob);//It will create anchor to download the file
    final anchor = html.document.createElement('a')  as    html.AnchorElement..href = url..style.display = 'none'         ..download = 'yourcsvname.csv';       //finally add the csv anchor to body
    html.document.body.children.add(anchor);// Cause download by calling this function
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  void generateCSV()
  {

  }

  @override
  Widget build(BuildContext context) {
    var pather = finPath.collection('Tasks').doc(widget.taskName);
    infoPath = pather.collection('TaskResponses');
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.taskName + " Learner Responses",
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
              icon: Icon(Icons.file_copy),
              tooltip: ' Get CSV',
              onPressed: () async{
                createData();
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print("Stupid Debug Flag.");
              },
            ),
          ]),
      //
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: pather.collection('TaskResponses').snapshots(),
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
                      title: new Text(document.data()['firstname'] + ' ' +document.data()['lastname']),
                      trailing: IconButton(
                          icon: Icon(Icons.info),
                          tooltip: 'Get Learner Information',
                          onPressed: () {
                            setState(() {
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => responses(
                                learner: document.data()['learnerid'],
                                name: document.data()['firstname'] + ' ' +document.data()['lastname'],
                                mediaLink: widget.mediaLink,
                                answer: document.data()["learnerresponses"],
                                asr: document.data()["asrfeedback"],
                                type: widget.taskType
                                ),
                            )
                            );}
                      ),
                      leading: IconButton(
                          icon: Icon(Icons.file_copy),
                          tooltip: 'Generate CSV',
                          onPressed: () {
                            setState(() {
                            });
                          }
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
