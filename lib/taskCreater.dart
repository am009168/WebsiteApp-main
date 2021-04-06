import 'dart:html';
import 'package:universal_html/html.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nice_button/nice_button.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:intl/intl.dart';


// completed learner ids
// turn all courses to open
var taskPath = pathPasser;
List<String>imageArr = <String>[];
List <String>audioArr = <String>[];
String name;
String imageUrl;
String mediaUrl;
String audioUrl ;
class taskCreater extends StatefulWidget {
  taskCreater({Key key}) : super(key: key);

  //final String courseId;

  @override
  _creatorState createState() => _creatorState();
}

class _creatorState extends State<taskCreater> {
  var firstColor = Color(0xff5b86e5), secondColor = Color(0xff36d1dc);
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
                Text('Task Type Selector'),
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
                    child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: [
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
                        children: <Widget>[
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            elevation: 1.0,
                            radius: 0,
                            text: " Instruction Task",
                            background: Colors.black,
                            gradientColors: [secondColor, firstColor],
                            icon: Icons.new_releases_outlined,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new Instruction()));
                            },
                          ),
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            radius: 0,
                            padding: const EdgeInsets.all(15),
                            text: "Multiple Choice Task",
                            gradientColors: [secondColor, firstColor],
                            icon: Icons.art_track,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new multipleChoice()));
                            },
                          ),
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            radius: 0,
                            padding: const EdgeInsets.all(15),
                            text: "Free Text Perception Task",
                            gradientColors: [secondColor, firstColor],
                            icon: Icons.keyboard,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new freeText()));
                            },
                          ),
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            radius: 0,
                            padding: const EdgeInsets.all(15),
                            text: "Video Perception Task",
                            gradientColors: [secondColor, firstColor],
                            icon: Icons.video_collection_rounded,
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new videoPerception()));
                            },
                          ),
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            radius: 0,
                            padding: const EdgeInsets.all(15),
                            text: "Constrained Production Task",
                            icon: Icons.speaker_phone,
                            gradientColors: [secondColor, firstColor],
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new constrainedProd()));
                            },
                          ),
                          Text("\n"),
                          NiceButton(
                            width: 450,
                            radius: 0,
                            padding: const EdgeInsets.all(15),
                            icon: Icons.speaker_phone,
                            text: "Unconstrained Production Task",
                            gradientColors: [secondColor, firstColor],
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new unconstrainedProd()));
                            },
                          ),

                          SizedBox(height: 100),
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

class Instruction extends StatefulWidget {
  @override
  _Instruction createState() => _Instruction();
}

class _Instruction extends State<Instruction> {
  String _fileName;
  List<PlatformFile> _paths;
  String _directoryPath;
  String _extension;
  String imageUrl;
  String videoUrl;
  String audioUrl;
  firebase_storage.Reference imageRef, audioRef;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController wordEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  TextEditingController mediaEditingController = new TextEditingController();
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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                child: Column(
                  children: [
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
                          children: <Widget>[
                            Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                controller: promptEditingController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Question Prompt',
                                ),
                              ),
                            ),


                            NiceButton(
                              width: 500,
                              elevation: 1.0,
                              radius: 52.0,
                              text: " Next Screen",
                              background: Colors.black,
                              onPressed: () {
                                pathPasser.updateData(
                                    {
                                      "tasktype" : "instruction",
                                      "prompt" : promptEditingController.text.trim()
                                    }
                                );
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => new instructionAdder()));
                              },
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

class instructionAdder extends StatefulWidget {
  @override
  _instructionAdderState createState() => _instructionAdderState();
}

class _instructionAdderState extends State<instructionAdder> {

  firebase_storage.Reference imageRef,  audioRef;
  String imageUrl;
  String videoUrl;
  String audioUrl;
  bool _loadingPath = false;
  bool value = false;

  TextEditingController wordEditingController = new TextEditingController();

  TextEditingController imageEditingController = new TextEditingController();

  TextEditingController mediaEditingController = new TextEditingController();

  @override
  void initState()
  {
    super.initState();
  }

  Future<String> _openFileImage() async {
    String _imageUrl;
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/images/" + fileName);
        imageRef = ref;
        try {
          imageUrl = await ref.getDownloadURL();
        }catch(e){
          await ref.putData(uploadfile);
          imageUrl = await ref.getDownloadURL();

          print("file not found");
        }

      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  Future<String> _openFileAudio() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/media/" + fileName);
        audioRef = ref;
        try {
            audioUrl = await ref.getDownloadURL();
        }catch(e){
          await ref.putData(uploadfile);
          audioUrl = await ref.getDownloadURL();
        }
        print(audioUrl);
      }catch(e) {
        print("catch");
        print(e);
      }
      return url;
    }
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
                    child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
              ),
            ),
            Center(
              child: Column(
                children: [
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
                        children: <Widget>[
                          Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: wordEditingController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Word ',
                              ),
                            ),
                          ),



                          Padding(
                            padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                            child: Column(
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () async => await _openFileAudio(),
                                  child: const Text("Open Audio Picker"),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Include uploaded image: ',
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
                              ?Padding(
                            padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                            child: Column(
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () async => imageUrl = await _openFileImage(),
                                  child: const Text("Open Image Picker"),
                                ),
                              ],
                            ),
                          ):Container(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async{
                                  if(value)
                                  {
                                    imageArr.add(await imageRef.getDownloadURL());
                                  }

                                  else
                                    imageArr.add("NONE");

                                  audioArr.add(await audioRef.getDownloadURL());
                                  pathPasser.updateData({'instructionwords': FieldValue.arrayUnion([wordEditingController.text.trim()])});
                                  pathPasser.update(
                                      {

                                        "instructionmedias": audioArr,
                                        "instructionimages" : imageArr,
                                      }

                                  );
                                  audioArr.clear();
                                  imageArr.clear();
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Tasks(
                                        taskName: namePasser),
                                  )
                                  );
                                },
                              ),

                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: "Add More",
                                background: Colors.black,
                                onPressed: () async{
                                  if(value)
                                  {
                                    imageArr.add(await imageRef.getDownloadURL());
                                  }
                                  else
                                    imageArr.add("NONE");

                                  audioArr.add(await audioRef.getDownloadURL());
                                  print(imageArr);
                                  pathPasser.updateData({'instructionwords': FieldValue.arrayUnion([wordEditingController.text.trim()])});
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => new instructionAdder()));
                                },
                              ),

                            ],
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

class multipleChoice extends StatefulWidget {
  @override
  _multipleChoice createState() => _multipleChoice();
}

class _multipleChoice extends State<multipleChoice> {
  List<Widget> course;
  TextEditingController mediaEditingController = new TextEditingController();
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController correctEditingController = new TextEditingController();
  TextEditingController answer2EditingController = new TextEditingController();
  TextEditingController answer3EditingController = new TextEditingController();
  TextEditingController answer4EditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  String imageUrl;
  String mediaUrl;
  String audioUrl ;
  String retryFlag = "NONE";
  String _fileName;
  firebase_storage.Reference imageRef, audioRef;
  List<PlatformFile> _paths;
  String _directoryPath;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();
  bool canContinue;
  bool value = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  Future<String> _openFileImage() async {
    String _imageUrl;
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/images/" + fileName);
        imageRef = ref;
        try {
          imageUrl = await ref.getDownloadURL();
        }catch(e){
          await ref.putData(uploadfile);
          imageUrl = await ref.getDownloadURL();

          print("file not found");
        }

      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  Future<String> _openFileAudio() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/media/" + fileName);
        audioRef = ref;
        try {
            audioUrl = await ref.getDownloadURL();

        }catch(e){
          await ref.putData(uploadfile);
          audioUrl = await ref.getDownloadURL();
        }
        print(audioUrl);
      }catch(e) {
        print("catch");
        print(e);
      }
      return url;
    }
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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: [
                      Image(image: AssetImage('assets/banner.png'),height:350 ,width: 750,),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.32,),
                      Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: promptEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Question Prompt',
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => audioUrl = await _openFileAudio(),
                                      child: const Text("Open Audio Picker"),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Include uploaded image: ',
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
                              ?Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => imageUrl = await _openFileImage(),
                                      child: const Text("Open Image Picker"),
                                    ),
                                  ],
                                ),
                              ):Container(),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: correctEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Correct Answer',
                                  ),
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: answer2EditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Multiple Choice Answer 2',
                                  ),
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: answer3EditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Multi Choice Answer 3',
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: answer4EditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Multi Choice Answer 4',
                                  ),
                                ),
                              ),

                              DropdownButton<String>(
                                value: retryFlag,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.black,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    retryFlag = newValue;
                                  });
                                },
                                items: <String>['NONE', 'SUGGEST', 'REQUIRE']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),

                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async{
                                  try{
                                    List pass = [
                                      correctEditingController.text.trim(),
                                      answer2EditingController.text.trim(),
                                      answer3EditingController.text.trim(),
                                      answer4EditingController.text.trim()
                                    ];
                                    pass.shuffle();
                                  pathPasser.updateData(
                                      {
                                        "retryflag": "none",
                                        "medialink" : await audioRef.getDownloadURL(),
                                        "tasktype" : "multiplechoice",
                                        "multichoices": pass,
                                        "correctchoice": correctEditingController.text.trim(),
                                        "retryflag": retryFlag,
                                        "prompt" : promptEditingController.text.trim()
                                      }
                                  );
                                  if (value) {
                                    pathPasser.updateData(
                                        {
                                          "imagelink": await imageRef.getDownloadURL(),
                                        }
                                    );
                                  }
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Tasks(
                                      taskName: namePasser),
                                  )
                                  );
                                  }
                                  catch(e){
                                    print(e);
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Wait!'),
                                          content: Text('Please wait while we upload your file(s)'),
                                        )
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
}

class freeText extends StatefulWidget {
  @override
  _freeTextState createState() => _freeTextState();
}

class _freeTextState extends State<freeText> {
  List<Widget> course;
  String imageUrl;
  String videoUrl;
  String audioUrl;
  bool value = false;
  firebase_storage.Reference imageRef, audioRef;
  Future<String> _openFileImage() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/images/" + fileName);
        imageRef = ref;
        try {
          audioUrl = await ref.getDownloadURL();
        }catch(e){
          final newRef = firebase_storage.FirebaseStorage.instance.ref("taskmedia/");
          await ref.putData(uploadfile);

          print("file not found");
        }
        imageUrl = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  Future<String> _openFileAudio() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/media/" + fileName);
        audioRef = ref;
        try {
          audioUrl = await ref.getDownloadURL();
        }catch(e){
          await ref.putData(uploadfile);

          print("file not found");
        }
        audioUrl = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  bool _loadingPath = false;
  TextEditingController promptEditingController = new TextEditingController();

  TextEditingController imageEditingController = new TextEditingController();

  TextEditingController mediaEditingController = new TextEditingController();


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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: [
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
                            children: <Widget>[
                              Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: promptEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Question Prompt',
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => audioUrl = await _openFileAudio(),
                                      child: const Text("Open Audio Picker"),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Include uploaded image: ',
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
                                  ?Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => imageUrl = await _openFileImage(),
                                      child: const Text("Open Image Picker"),
                                    ),
                                  ],
                                ),
                              ):Container(),
                              SizedBox(height: 25,),
                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async {
                                  try {
                                      pathPasser.updateData({
                                          "medialink": await audioRef.getDownloadURL(),
                                          "tasktype": "freetext",
                                          "prompt": promptEditingController.text.trim()
                                      }
                                    );
                                      if (value) {
                                        pathPasser.updateData({
                                          "imagelink": await imageRef.getDownloadURL(),
                                        }
                                        );
                                      }
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>
                                            Tasks(taskName: namePasser),
                                        )
                                      );
                                  }
                                  catch(e){
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Wait!'),
                                          content: Text('Please wait while we upload your file(s)'),
                                        )
                                    );
                                  }
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ));
  }
}

class videoPerception extends StatefulWidget {
  _videoPerception createState()=> _videoPerception();
}

class _videoPerception extends State<videoPerception> {
  List<Widget> course;
  String dropdownValue = "Free Text";
  String videoType = "YouTube Link";
  String retryFlag = "NONE";
  bool isyoutube = true;
  String imageUrl;
  firebase_storage.Reference videoRef;
  String videoUrl;
  bool _loadingPath;

  Future<String> _openFileMedia() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/media/" + fileName);
        videoRef = ref;
        try {
          videoUrl = await ref.getDownloadURL();
        }catch(e){
          await ref.putData(uploadfile);
          print("file not found");
        }
        var holder = ref.child(fileName);
        if (holder == null)
        {
          await ref.putData(uploadfile);
          print("file not found");
        }
        url = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  TextEditingController mediaEditingController = new TextEditingController();
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController correctEditingController = new TextEditingController();
  TextEditingController answer2EditingController = new TextEditingController();
  TextEditingController answer3EditingController = new TextEditingController();
  TextEditingController answer4EditingController = new TextEditingController();
  bool _visible = false;
  void _toggle() {
    if (dropdownValue == "Multiple Choice")
    {
      setState(() {
        _visible = true;
      });
    }

    else {
      setState(() {
        _visible = false;
      });
    }

    if (videoType == "YouTube Link")
    {
      setState(() {
        isyoutube = true;
      });
    }

    else {
      setState(() {
        isyoutube = false;
      });
    }
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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: [
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
                            children: <Widget>[
                              Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: promptEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Question Prompt',
                                  ),
                                ),
                              ),
                              (isyoutube)
                              ?Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: mediaEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Youtube Video Link',
                                  ),
                                ),
                              ):Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => videoUrl = await _openFileMedia(),
                                      child: const Text("Open Image Picker"),
                                    ),
                                  ],
                                ),
                              ),

                              DropdownButton<String>(
                                value: videoType,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.black,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    videoType = newValue;
                                  });
                                  _toggle();
                                },
                                items: <String>['YouTube Link', 'Upload Video']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              DropdownButton<String>(
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.black,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValue = newValue;
                                  });
                                  _toggle();
                                },
                                items: <String>['Free Text', 'Multiple Choice']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              (_visible)
                              ?Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextField(
                                          controller: correctEditingController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Correct Answer',
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextField(
                                          controller: answer2EditingController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Multiple Choice Answer 2',
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextField(
                                          controller: answer3EditingController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Multi Choice Answer 3',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: TextField(
                                          controller: answer4EditingController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Multi Choice Answer 4',
                                          ),
                                        ),
                                      ),

                                      DropdownButton<String>(
                                        value: retryFlag,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.black,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            retryFlag = newValue;
                                          });
                                          _toggle();
                                        },
                                        items: <String>['NONE', 'SUGGEST', 'REQUIRE']
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),

                                    ]
                                ):Container(),

                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async{
                                  try {
                                    if (isyoutube) {
                                      if (_visible) {
                                        List pass = [
                                          correctEditingController.text.trim(),
                                          answer2EditingController.text.trim(),
                                          answer3EditingController.text.trim(),
                                          answer4EditingController.text.trim()
                                        ];
                                        pass.shuffle();
                                        pathPasser.updateData(
                                            {

                                              "medialink": mediaEditingController.text.trim(),
                                              "tasktype": "video",
                                              "isyoutube": isyoutube,
                                              "multichoices": pass,
                                              "correctchoice": correctEditingController.text.trim(),
                                              "retryflag": retryFlag,
                                              "prompt": promptEditingController.text.trim()
                                            }
                                        );
                                      }

                                      else {
                                        pathPasser.updateData(
                                            {
                                              "isyoutube": isyoutube,
                                              "medialink": mediaEditingController.text.trim(),
                                              "tasktype": "video",
                                              "prompt": promptEditingController.text.trim()
                                            }
                                        );
                                      }
                                    }

                                    else {
                                      List pass = [
                                        correctEditingController.text.trim(),
                                        answer2EditingController.text.trim(),
                                        answer3EditingController.text.trim(),
                                        answer4EditingController.text.trim()
                                      ];
                                      pass.shuffle();
                                      if (_visible) {
                                        pathPasser.updateData(
                                            {

                                              "medialink": await videoRef.getDownloadURL(),
                                              "tasktype": "video",
                                              "isyoutube": isyoutube,
                                              "multichoices": pass,
                                              "correctchoice": correctEditingController.text.trim(),
                                              "retryflag": retryFlag,
                                              "prompt": promptEditingController.text.trim()
                                            }
                                        );
                                      }

                                      else {
                                        pathPasser.updateData(
                                            {
                                              "isyoutube": isyoutube,
                                              "medialink": await videoRef.getDownloadURL(),
                                              "tasktype": "video",
                                              "prompt": promptEditingController.text.trim()
                                            }
                                        );
                                      }
                                    }
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          Tasks(
                                              taskName: namePasser),
                                    )
                                    );
                                  }
                                  catch(e){
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Wait!'),
                                          content: Text('Please wait while we upload your file(s)'),
                                        )
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ));
  }
}

class constrainedProd extends StatefulWidget {
  @override
  _constrainedProdState createState() => _constrainedProdState();
}

class _constrainedProdState extends State<constrainedProd> {
  List<Widget> course;
  String imageUrl;
  firebase_storage.Reference imageRef;
  String videoUrl;
  String audioUrl;
  bool _loadingPath;
  bool value = false;
  Future<String> _openFileImage() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/images/" + fileName);
        imageRef = ref;
        try {
          audioUrl = await ref.getDownloadURL();
        }catch(e){
          final newRef = firebase_storage.FirebaseStorage.instance.ref("taskmedia/");
          await ref.putData(uploadfile);

          print("file not found");
        }
        imageUrl = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  TextEditingController promptEditingController = new TextEditingController();

  TextEditingController correctEditingController = new TextEditingController();

  TextEditingController imageEditingController = new TextEditingController();

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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: [
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
                            children: <Widget>[
                              Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: promptEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Question Prompt',
                                  ),
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: correctEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Correct Choice',
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Include uploaded image: ',
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
                                  ?Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => imageUrl = await _openFileImage(),
                                      child: const Text("Open Image Picker"),
                                    ),
                                  ],
                                ),
                              ):Container(),

                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async{
                                  try {
                                    pathPasser.updateData(
                                        {
                                          "tasktype": "constproduction",
                                          "correctchoice": correctEditingController.text.trim(),
                                          "prompt": promptEditingController.text.trim()
                                        }
                                    );

                                    if (value)
                                    {
                                      pathPasser.updateData(
                                          {
                                            "imagelink": await imageRef.getDownloadURL(),
                                          }
                                      );
                                    }
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          Tasks(
                                              taskName: namePasser),
                                    )
                                    );
                                  }

                                  catch(e){
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Wait!'),
                                          content: Text('Please wait while we upload your file(s)'),
                                        )
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ));
  }
}

class unconstrainedProd extends StatefulWidget {
  @override
  _unconstrainedProdState createState() => _unconstrainedProdState();
}

class _unconstrainedProdState extends State<unconstrainedProd> {
  List<Widget> course;
  String imageUrl;
  String videoUrl;
  String audioUrl;
  bool value = false;
  firebase_storage.Reference imageRef;
  bool _loadingPath;
  Future<String> _openFileImage() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
    } catch(e)
    { print(e);
    }
    if(result != null) {
      try{
        print(result.files.single.name);
        print(result.files.single.size);
        print(result.files.single.extension);
        Uint8List uploadfile = result.files.single.bytes;
        String fileName = result.files.single.name;
        final ref = firebase_storage.FirebaseStorage.instance.ref("designers/" + firebaseUser.uid + "/images/" + fileName);
        imageRef = ref;
        try {
          audioUrl = await ref.getDownloadURL();
        }catch(e){
          final newRef = firebase_storage.FirebaseStorage.instance.ref("taskmedia/");
          await ref.putData(uploadfile);

          print("file not found");
        }
        imageUrl = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }

  TextEditingController promptEditingController = new TextEditingController();

  TextEditingController imageEditingController = new TextEditingController();

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
                      child: Text("Create Task",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                  child: Column(
                    children: [
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
                            children: <Widget>[
                              Text("Enter Course Information below",style: TextStyle(fontSize: 20),),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: promptEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Question Prompt',
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Include uploaded image: ',
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
                                  ?Padding(
                                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async => imageUrl = await _openFileImage(),
                                      child: const Text("Open Image Picker"),
                                    ),
                                  ],
                                ),
                              ):Container(),

                              NiceButton(
                                width: 500,
                                elevation: 1.0,
                                radius: 52.0,
                                text: " Submit",
                                background: Colors.black,
                                onPressed: () async{
                                  try {
                                    pathPasser.updateData(
                                        {
                                          "tasktype": "unconstproduction",
                                          "prompt": promptEditingController.text.trim()
                                        }
                                    );

                                    if (value)
                                    {
                                      pathPasser.updateData(
                                        {
                                          "imagelink": await imageRef.getDownloadURL(),
                                        }
                                      );
                                    }
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          Tasks(
                                              taskName: namePasser),
                                    )
                                    );
                                  }

                                  catch(e){
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Wait!'),
                                          content: Text('Please wait while we upload your file(s)'),
                                        )
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ));
  }
}

