//NOTE: Create your website code and widgets here in website.dart.
import 'dart:io';

import 'package:flutter/material.dart';

//Joe: Change this to a Stateful widget so we can add new courses and display them.
//Use the setState() method to reflect UI changes.
//TODO: Look up how to format and use stateful widgets, try and get them working by Tuesday
//TODO: Try and add new course widgets to first screen, that way we can test on
//Tuesday.

//This widget is a very basic class that does not need much code in it.
//It creates an instance of _FirstScreenState, where most of the UI and
//Logic for the FirstScreen is.

void main() {
  runApp(MaterialApp(title: "Different pages test", home: new FirstScreen()));
}

class FirstScreen extends StatefulWidget {
  FirstScreen({Key key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  List<Widget> courses = new List();
  String coursename;

  void initState() {
    super.initState();
  }

  @override
  _navigateToCreatCourse(BuildContext context) async {
    final course = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateCourse(course: courses)));
    coursename = course;
    if (coursename != null) {
      courses.add(ListTile(
        title: Text(coursename),
        trailing: IconButton(
          icon: Icon(Icons.subdirectory_arrow_right),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => new ModuleScreen()));
          },
        ),
      ));
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          tooltip: 'refresh courses',
          onPressed: () {
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'add course',
          onPressed: () {
            _navigateToCreatCourse(context);
          },
        ),
      ]),
      body: Center(
        child: Column(
          children: <Widget>[
            Column(
              children: courses.toList(),
            ),
            /*
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new dbStuff()));
              },
              child: Text("Click here to do things "),
            )
            */
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

class CreateCourse extends StatelessWidget {
  List<Widget> course;
  CreateCourse({Key key, @required this.course}) : super(key: key);
  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('CreateCourse')),
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
                maxLength: 10,
                maxLengthEnforced: true,
                controller: textEditingController,
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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                    child: Text("Create Course"),
                    onPressed: () {
                      Navigator.pop(context, textEditingController.text);
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
        appBar: AppBar(title: Text('CreateCourse')),
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
                maxLength: 10,
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

class CreateLesson extends StatelessWidget {
  List<Item> lesson;
  CreateLesson({Key key, @required this.lesson}) : super(key: key);
  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('CreateLesson')),
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
                maxLength: 10,
                maxLengthEnforced: true,
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText: "Lesson Name",
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
                    child: Text("Create Lesson"),
                    onPressed: () {
                      Navigator.pop(context, textEditingController.text);
                    }),
              ),
            ),
          ],
        )));
  }
}

class LessonsScreen extends StatefulWidget {
  LessonsScreen({Key key}) : super(key: key);

  @override
  _LessonsScreen createState() => _LessonsScreen();
}

class _LessonsScreen extends State<LessonsScreen> {
  List<Item> lessons = new List();
  String lessonname;
  int index = 0;

  void initState() {
    super.initState();
  }

  @override
  _navigateToCreateLesson(BuildContext context) async {
    final lesson = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateLesson(lesson: lessons)));
    lessonname = lesson;
    if (lessonname != null) {
      print(lessonname);
      lessons[index] = generateItems(lessonname);
      index++;
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ENG400-Module1'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'add lesson',
              onPressed: () {
                _navigateToCreateLesson(context);
              },
            )
          ],
        ),
        body: Center(child: ExpansionPanelPage(lessons: lessons)));
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

Item generateItems(String LessonName) {
  return Item(
    headerValue: LessonName,
    expandedValue: 'This is lesson $LessonName',
  );
}

class ExpansionPanelPage extends StatefulWidget {
  List<Item> lessons = new List();

  ExpansionPanelPage({Key key, @required this.lessons}) : super(key: key);
  @override
  _ExpansionPanelPageState createState() =>
      _ExpansionPanelPageState(lessons: lessons);
}

class _ExpansionPanelPageState extends State<ExpansionPanelPage> {
  List<Item> lessons = new List();
  _ExpansionPanelPageState({@required this.lessons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ENG400'),
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
          lessons[index].isExpanded = !isExpanded;
        });
      },
      children: lessons.map<ExpansionPanel>((Item item) {
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
                  lessons.removeWhere((currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

/*
class dbStuff extends StatelessWidget {
  final TextEditingController dataController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Database Example')),
        body: Center(
            child: Column(
          children: <Widget>[
            TextField(
              controller: dataController,
              decoration: InputDecoration(
                labelText: "Enter Text",
              ),
            ),
            RaisedButton(
              onPressed: () {
                firestoreInstance
                    .collection("Users")
                    .doc(firebaseUser.uid)
                    .set({
                  "name": dataController.text.trim(),
                }).then((_) {
                  print("sent?");
                });
              },
              child: Text("Send to Database"),
            )
          ],
        )));
  }
}
*/
