import 'package:flutter/material.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/main.dart';
import 'dart:html' as html;


var path;
String modName;
class ModulePage extends StatefulWidget {
  ModulePage({Key key, this.courseName}) : super(key: key);
  // always marked "final".
  final String courseName;

  //final String courseId;

  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  @override
  Widget build(BuildContext context) {
    var coursePath = userPath1.collection('Courses').doc(widget.courseName);
    modName = widget.courseName;
    path = coursePath;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(icon: new Icon (Icons.arrow_back),
          onPressed:()
          {
            html.window.location.reload();
          },),
        title:Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Smart-Talk Course Page'),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new CreateModule()));
                  },
                  child: Text(
                    'Create Module',
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
              left:MediaQuery.of(context).size.width * 0.36,
              top: MediaQuery.of(context).size.height * 0.42,
              child: Card(
                elevation: 8.0,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                    margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    child: Text('Your Modules',style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  Image(image: AssetImage('assets/mod.png'),height:350 ,width: 750,),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.32,),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2)
                    ),
                    margin: const EdgeInsets.all(10.0),
                    width: 1500.0,
                    height: 500.0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: coursePath.collection('Modules').snapshots(),
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
                                        title: new Text(document.data()['name'], style: TextStyle(color: Colors.white),),
                                        trailing: IconButton(
                                          icon: Icon(Icons.info),
                                          tooltip: 'Get Course Information',
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => Lessons(
                                                LessonName: document.data()["name"],),
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateModule extends StatefulWidget {
  @override
  _CreateModuleState createState() => _CreateModuleState();
}

class _CreateModuleState extends State<CreateModule> {
  List<Widget> course;

  TextEditingController nameEditingController = new TextEditingController();

  DateTime selectedDateOpen = DateTime.now();

  DateTime selectedDateClose = DateTime.now();

  bool value = false;
  bool open = false;

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
                  Text('Create Module Page'),
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
                left:MediaQuery.of(context).size.width * 0.35,
                top: MediaQuery.of(context).size.height * 0.42,
                child: Card(
                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      child: Text("Create Module",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    Image(image: AssetImage('assets/mod.png'),height:350 ,width: 750,),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
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
                                  labelText: "Module Name",
                                  prefixIcon: Icon(Icons.edit),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Set Open Date and Close Date: ',
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
                            (value)
                                ?Container(
                              child: Column(
                                children: [
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
                                ],
                              ),
                            ):Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Initialize Lesson With Open: ',
                                  style: TextStyle(fontSize: 17.0),
                                ),
                                SizedBox(width: 10),
                                Checkbox(
                                  value: this.open,
                                  onChanged: (bool value) {
                                    setState(() {
                                      this.open = value;
                                    });
                                    print(value);
                                  },
                                ),
                              ],
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: RaisedButton(
                                    child: Text("Create Module"),
                                    onPressed: () {
                                      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                                      String date = dateFormat.format(DateTime.now());

                                      if (value) {
                                        path.collection('Modules').doc(nameEditingController.text.trim()).set(
                                            {
                                              "dateopen": selectedDateOpen.toString(),
                                              "dateclose": selectedDateClose.toString(),
                                              "designerid": firebaseUser1.uid,
                                              "isopen": this.open,
                                              "id": nameEditingController.text.trim(),
                                              "name": nameEditingController.text.trim(),
                                            }
                                        );
                                      }
                                      else{
                                        path.collection('Modules').doc(nameEditingController.text.trim()).set(
                                            {
                                              "dateopen" : "1999-01-21 15:00:00.000",
                                              "dateclose" : "3021-01-21 15:00:00.000",
                                              "designerid": firebaseUser1.uid,
                                              "isopen": this.open,
                                              "id": nameEditingController.text.trim(),
                                              "name": nameEditingController.text.trim(),
                                            }
                                        );
                                      }

                                      Navigator.pop(context, nameEditingController.text);
                                    }),
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
        ));
  }
}
