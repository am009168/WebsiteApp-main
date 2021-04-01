
import 'package:flutter/material.dart';
import 'package:flutter_app/courseInfo.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_app/authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var firebaseUser = FirebaseAuth.instance.currentUser;
final firestoreInstance = FirebaseFirestore.instance;
var userPath = firestoreInstance.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser.uid);
var coursePath = userPath.collection('Courses');
var courseList  = [];
//Joe: Change this to a Stateful widget so we can add new courses and display them.
//Use the setState() method to reflect UI changes.
//TODO: Look up how to format and use stateful widgets, try and get them working by Tuesday
//TODO: Try and add new course widgets to first screen, that way we can test on
//Tuesday.

class ExpenseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
        stream: coursePath.snapshots()  ,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text("There is no expense");
          return new ListView(children: getExpenseItems(snapshot));
        });
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => new ListTile(title: new Text(doc.data()["name"]), subtitle: new Text(doc.data()["prefix"])))
        .toList();
  }
}

class FirstScreen extends StatefulWidget {
  FirstScreen({Key key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  List<Widget> courses;
  String coursename;
  void initState() {
    super.initState();
  }

  @override
  _navigateToCreatCourse(BuildContext context) async {
    final course = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateCourse(course: courses)));
  }

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
                Text('Smart-Talk Course Page'),
                InkWell(
                  onTap: () {
                    _navigateToCreatCourse(context);
                  },
                  child: Text(
                    'Add Course',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
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
              left:MediaQuery.of(context).size.width * 0.43,
              top: MediaQuery.of(context).size.height * 0.42,
              child: Card(
                elevation: 8.0,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                    margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    child: Text('Welcome!',style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50,),
                  Image(image: AssetImage('assets/banner.png'),height:500 ,width: 750,),
                  SizedBox(height: 175,),
                  Text("Current Course List ",style: TextStyle(fontSize:25 )),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2)
                    ),
                    margin: const EdgeInsets.all(10.0),
                    width: 1500.0,
                    height: 500.0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                            stream: coursePath.snapshots(),
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
                                        subtitle: Row(
                                          children: [
                                            Icon(Icons.linear_scale, color: Colors.white),
                                            Text('  '),
                                            new Text(document.data()['prefix'], style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                        leading:  Container(
                                          decoration: new BoxDecoration(
                                              border: new Border(
                                                  right: new BorderSide(width: 1.0, color: Colors.white24))),
                                          child: IconButton(
                                              icon: Icon(Icons.info, color: Colors.white,),
                                              tooltip: 'Get Lesson Information',
                                              onPressed: () {
                                                setState(() {
                                                });
                                                Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (context) => courseInfo(
                                                    courseName: document.data()["name"],),
                                                )
                                                );}
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.arrow_right, color: Colors.white,),
                                          tooltip: 'Get Course Information',
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => ModulePage(
                                                courseName: document.data()["name"],
                                                courseID: document.data()['id'],),
                                            )
                                            );},
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          SizedBox(height: 10),
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



class ModuleScreen extends StatefulWidget {
  ModuleScreen({Key key}) : super(key: key);

  @override
  _ModuleScreenState createState() => new _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  List<Widget> modules = new List();
  String modulename;

  void initState() {
    super.initState();
  }

  @override
  _navigateToCreatModule(BuildContext context) async {
    final module = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateModule(module: modules)));
    modulename = module;
    if (modulename != null) {
      modules.add(ListTile(
        title: Text(modulename),
        trailing: IconButton(
          icon: Icon(Icons.subdirectory_arrow_right),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => new LessonsScreen()));
          },
        ),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modules'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'add module',
          onPressed: () {
            _navigateToCreatModule(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            print("Stupid debug flag.");
          },
        ),
      ]),
      body: Center(
        child: Column(children: <Widget>[
          Column(
            children: modules.toList(),
          )
        ]),
      ),
    );
  }
}

class CreateCourse extends StatefulWidget {
  List<Widget> course;
  CreateCourse({Key key, @required this.course}) : super(key: key);

  @override
  _CreateCourseState createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  TextEditingController nameEditingController = new TextEditingController();
  TextEditingController prefixEditingController = new TextEditingController();
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
    return Scaffold(
        appBar: AppBar(title: Text('Create Course')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Column(
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
                      labelText: "Course Name",
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
                  child: TextField(
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    autofocus: false,
                    cursorColor: Colors.blue,
                    maxLength: 8,
                    maxLengthEnforced: true,
                    controller: prefixEditingController,
                    decoration: InputDecoration(
                      labelText: "Prefix for Course",
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
              ],
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

            Container(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                    child: Text("Create Course"),
                    onPressed: () {
                      if (value)
                      {
                        userPath.collection('Courses').doc(nameEditingController.text.trim()).set(
                          {
                            "dateopen" : selectedDateOpen.toString(),
                            "dateclose": selectedDateClose.toString(),
                            "designerid" : firebaseUser.uid,
                            "isopen" : true,
                            "learnerids": [],
                            "id" : nameEditingController.text.trim(),
                            "name" : nameEditingController.text.trim(),
                            "prefix" : prefixEditingController.text.trim()
                          }
                        );
                      }
                      else {
                        userPath.collection('Courses').doc(nameEditingController.text.trim()).set(
                        {
                          "dateopen" : "1999-01-21 15:00:00.000",
                          "dateclose" : "3021-01-21 15:00:00.000",
                          "designerid" : firebaseUser.uid,
                          "isopen" : true,
                          "learnerids": [],
                          "id" : nameEditingController.text.trim(),
                          "name" : nameEditingController.text.trim(),
                          "prefix" : prefixEditingController.text.trim()
                        }
                       );
                      }
                      Navigator.pop(context, nameEditingController.text);
                    }),
              ),
            ),
          ],
        )));
  }
}

class CreateModule extends StatelessWidget {
  List<Widget> module;
  CreateModule({Key key, @required this.module}) : super(key: key);
  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Module')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Container(
              child: TextField(
                keyboardType: TextInputType.text,
                maxLines: 1,
                autofocus: false,
                cursorColor: Colors.blue,
                maxLengthEnforced: true,
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText: "Module Name",
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
                    child: Text("Create Module"),
                    onPressed: () {
                      Navigator.pop(context, textEditingController.text);
                    }),
              ),
            ),
          ],
        )));
  }
}

class LessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sample Module Structure')),
        body: Center(child: ExpansionPanelPage()));
  }
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });
  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Lesson $index',
      expandedValue: 'This is learner task 1',
    );
  });
}

class ExpansionPanelPage extends StatefulWidget {
  ExpansionPanelPage({Key key}) : super(key: key);
  @override
  _ExpansionPanelPageState createState() => _ExpansionPanelPageState();
}

class _ExpansionPanelPageState extends State<ExpansionPanelPage> {
  List<Item> _data = generateItems(8);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Lesson List'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
              title: Text(item.expandedValue),
              subtitle: Text('To delete this panel, tap the trash can icon'),
              trailing: Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _data.removeWhere((currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}


