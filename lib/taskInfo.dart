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
class _infoState extends State<taskInfo> {
  List<List<String>> rows = List<List<String>>();
  void rowStuff(List <String> row)
  {
    rows.add(row);
  }
  void createData() async{
    List<List<dynamic>> rows = List<List<dynamic>>();
    rows.add(["Name","Answers","Task Type"]);
    var hi;
    var bye;
    var hello;
    var check;

     await firestoreInstance.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser.uid)
        .collection('Courses').doc(modName)
        .collection('Modules').doc(lessonName)
        .collection('Lessons').doc(namePasser)
        .collection('Tasks').doc(widget.taskName).collection("TaskResponses").get().then((querySnapshot) {
       querySnapshot.docs.forEach((result) {
         List<dynamic> row = List<dynamic>();
         hi = result.data()['firstname'] + " " + result.data()['lastname'];
         bye = result.data()['learnerresponses'];
         hello = result.data()['taskid'];
         row.add(hi);
         row.add(bye);
         row.add(hello);
         rows.add(row);
       });
     });
    print(rows.toString());

    String csv = const ListToCsvConverter().convert(rows);//this csv variable holds entire csv data
    final bytes = utf8.encode(csv);//NOTE THAT HERE WE USED HTML PACKAGE
    final blob = html.Blob([bytes]);//It will create downloadable object
    final url = html.Url.createObjectUrlFromBlob(blob);//It will create anchor to download the file
    final anchor = html.document.createElement('a')  as    html.AnchorElement..href = url..style.display = 'none'         ..download = widget.taskName +'Responses.csv';       //finally add the csv anchor to body
    html.document.body.children.add(anchor);// Cause download by calling this function
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }


  void delete()
  {
    firestoreInstance.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser.uid)
        .collection('Courses').doc(modName)
        .collection('Modules').doc(lessonName)
        .collection('Lessons').doc(namePasser)
        .collection('Tasks').doc(widget.taskName).delete();
  }
  @override
  Widget build(BuildContext context) {
    var pather = finPath.collection('Tasks').doc(widget.taskName);
    infoPath = pather.collection('TaskResponses');
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
                Text('Smart-Talk Task Response Page'),
                InkWell(
                  onTap: () {
                    delete();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                          taskName: namePasser),
                    )
                    );
                  },
                  child: Text(
                    'Delete Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () {
                    createData();
                  },
                  child: Text(
                    'Get CSV',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                left:MediaQuery.of(context).size.width * 0.38,
                top: MediaQuery.of(context).size.height * 0.42,
                child: Card(
                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      child: Text('Task Information',style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50,),
                    Image(image: AssetImage('assets/banner.png'),height:350 ,width: 750,),
                    SizedBox(height: 175,),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)
                      ),
                      margin: const EdgeInsets.all(10.0),
                      width: 1500.0,
                      height: 500.0,
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
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
                                return Card(
                                  elevation: 8.0,
                                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                    child: new ListTile(
                                      title: new Text(document.data()['firstname'] + ' ' +document.data()['lastname'], style: TextStyle(color: Colors.white)),
                                      trailing: IconButton(
                                          icon: Icon(Icons.info, color: Colors.white),
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
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
