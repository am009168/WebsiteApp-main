import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/taskInfo.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var finPath;
int counter = 0;
var pathPasser;
var nameOfTask;
var idOfTask;
String namePasser;
class Tasks extends StatefulWidget {
  Tasks({Key key, this.taskName}) : super(key: key);
  // always marked "final".
  final String taskName;
  //final String courseId;

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    var lessonPath = userPath1.collection('Courses').doc(modName).collection('Modules').doc(lessonName).collection('Lessons').doc(widget.taskName);
    finPath = lessonPath;
    List<dynamic> tasks = List<dynamic>();


    namePasser = widget.taskName;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(icon: new Icon (Icons.arrow_back),
          onPressed:()
          {
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (ctxt) => new Lessons(LessonName: lessonName)),
            );
          },),
        title:Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Smart-Talk Task Page'),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new CreateTask()));
                  },
                  child: Text(
                    'Create Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container( // image below the top bar
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/bgM.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left:MediaQuery.of(context).size.width * 0.37,
              top: MediaQuery.of(context).size.height * 0.42,
              child: Card(
                elevation: 8.0,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                    margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    child: Text('Your Tasks',style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50,),
                  Image(image: AssetImage('assets/bulb.png'),height:350 ,width: 750,),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.32,),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2)
                    ),
                    margin: const EdgeInsets.all(10.0),
                    width: 1500.0,
                    height: 500.0,
                    child: SingleChildScrollView(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: lessonPath.collection('Tasks').snapshots(),
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
                              counter = 0;
                              counter = snapshot.data.docs.length;
                              print('break');
                              tasks.clear();
                              snapshot.data.docs.forEach((element) {

                                tasks.add(element.data()['orderid']);
                              });
                              tasks.sort();
                              print(tasks.toString());
                              return Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                                  child: new ListTile(
                                    title: new Text(document.data()['name'], style: TextStyle(color: Colors.white),),
                                    trailing: IconButton(
                                      icon: Icon(Icons.info, color: Colors.white,),
                                      tooltip: 'Task Page',
                                        onPressed: () {
                                          setState(() {
                                          });
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => taskInfo(
                                              taskName: document.data()["name"],
                                              taskType: document.data()['tasktype'],
                                              mediaLink:document.data()["medialink"] ,),
                                          )
                                          );}
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
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class CreateTask extends StatelessWidget {
  List<Widget> course;
  TextEditingController nameEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
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
                  Text('Create Task Page'),
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
                    'assets/bgM.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left:MediaQuery.of(context).size.width * 0.35,
                top: MediaQuery.of(context).size.height * 0.42,
                child: Card(
                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: <Widget>[
                      Image(image: AssetImage('assets/bulb.png'),height:350 ,width: 750,),
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
                            children: [
                              Container(
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  autofocus: false,
                                  cursorColor: Colors.blue,
                                  maxLengthEnforced: true,
                                  controller: nameEditingController,
                                  decoration: InputDecoration(
                                    labelText: "Task Name",
                                    prefixIcon: Icon(Icons.folder),
                                    //Unfocus Text is grey
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    //Focued Text is blue
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: RaisedButton(
                                      child: Text("Create Task"),
                                      onPressed: () {
                                        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                                        String date = dateFormat.format(DateTime.now());
                                        finPath.collection('Tasks').doc(nameEditingController.text.trim()).set(
                                            {
                                              'orderid' : counter,
                                              "dateopen" : date,
                                              "designerid" : firebaseUser1.uid,
                                              "isopen" : true,
                                              "id": nameEditingController.text.trim(),
                                              "name" : nameEditingController.text.trim(),
                                            }
                                        );
                                        pathPasser = finPath.collection('Tasks').doc(nameEditingController.text.trim());
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => new taskCreater()));
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
