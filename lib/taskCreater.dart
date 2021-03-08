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
String name;
class taskCreater extends StatefulWidget {
  taskCreater({Key key}) : super(key: key);

  //final String courseId;

  @override
  _creatorState createState() => _creatorState();
}

class _creatorState extends State<taskCreater> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Choose a Task Type",
            style: TextStyle(fontSize: 18),
          ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 1.0,
              radius: 52.0,
              text: " Instruction Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new Instruction()));
              },
            ),
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 1.0,
              radius: 52.0,
              text: "Multiple Choice Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new multipleChoice()));
              },
            ),
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 1.0,
              radius: 52.0,
              text: "Free Text Perception Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new freeText()));
              },
            ),
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 8.0,
              radius: 52.0,
              text: "Video Perception Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new videoPerception()));
              },
            ),
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 8.0,
              radius: 52.0,
              text: "Constrained Perception Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new constrainedProd()));
              },
            ),
            Text("\n"),
            NiceButton(
              width: 500,
              elevation: 8.0,
              radius: 52.0,
              text: "Unconstrained Perception Task",
              background: Colors.black,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new unconstrainedProd()));
              },
            ),

            SizedBox(height: 100),
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
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController wordEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  TextEditingController mediaEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Instruction Task')),
        body: ListView(
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
                    onPressed: () => _openFileExplorer(),
                    child: const Text("Open file picker"),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectFolder(),
                    child: const Text("Pick folder"),
                  ),
                  ElevatedButton(
                    onPressed: () => _clearCachedFiles(),
                    child: const Text("Clear temporary files"),
                  ),
                ],
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
                      "orderid" : 1,
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
    );
  }
}

class instructionAdder extends StatelessWidget {
  TextEditingController wordEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  TextEditingController mediaEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Information')),
      body: ListView(
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

          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: mediaEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Media Link',
              ),
            ),
          ),



          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: imageEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image Link (Optional)',
              ),
            ),
          ),

          Row(
            children: [
              NiceButton(
                width: 500,
                elevation: 1.0,
                radius: 52.0,
                text: " Submit",
                background: Colors.black,
                onPressed: () {
                  pathPasser.updateData({'instructionwords': FieldValue.arrayUnion([wordEditingController.text.trim()])});
                  pathPasser.updateData({'instructionmedias': FieldValue.arrayUnion([mediaEditingController.text.trim()])});
                  pathPasser.updateData({'instructionimages': FieldValue.arrayUnion([imageEditingController.text.trim()])});
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
                text: " Add More",
                background: Colors.black,
                onPressed: () {
                  pathPasser.updateData({'instructionwords': FieldValue.arrayUnion([wordEditingController.text.trim()])});
                  pathPasser.updateData({'instructionmedias': FieldValue.arrayUnion([mediaEditingController.text.trim()])});
                  pathPasser.updateData({'instructionimages': FieldValue.arrayUnion([imageEditingController.text.trim()])});

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => new instructionAdder()));
                },
              ),

            ],
          ),
        ],
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
  String _fileName;
  List<PlatformFile> _paths;
  String _directoryPath;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    FilePickerResult result;
    var url;
    try{
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
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
        final ref = firebase_storage.FirebaseStorage.instance.ref("taskimages/" + fileName);
        ref.putData(uploadfile);
        url = await ref.getDownloadURL();
      }catch(e) {
        print(e);
      }
      return url;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Multiple Choice Task')),
        body: Center(
            child: ListView(
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
                    controller: mediaEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Media Link',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _openFileExplorer(),
                        child: const Text("Open file picker"),
                      ),
                    ],
                  ),
                ),

                Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: const CircularProgressIndicator(),
                  )
                      : _directoryPath != null
                      ? ListTile(
                    title: const Text('Directory path'),
                    subtitle: Text(_directoryPath),
                  )
                      : _paths != null
                      ? Container(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    height:
                    MediaQuery.of(context).size.height * 0.50,
                    child: Scrollbar(
                        child: ListView.separated(
                          itemCount:
                          _paths != null && _paths.isNotEmpty
                              ? _paths.length
                              : 1,
                          itemBuilder:
                              (BuildContext context, int index) {
                            final bool isMultiPath =
                                _paths != null && _paths.isNotEmpty;
                            final String name = 'File $index: ' +
                                (isMultiPath
                                    ? _paths
                                    .map((e) => e.name)
                                    .toList()[index]
                                    : _fileName ?? '...');
                            final path = _paths
                                .map((e) => e.path)
                                .toList()[index]
                                .toString();

                            return ListTile(
                              title: Text(
                                name,
                              ),
                              subtitle: Text(path),
                            );
                          },
                          separatorBuilder:
                              (BuildContext context, int index) =>
                          const Divider(),
                        )),
                  )
                      : const SizedBox(),
                ),

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

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: imageEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Image Link (Optional)',
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
                    pathPasser.updateData(
                        {
                          "retryflag": "NONE",
                          "orderid" : 2,
                          "medialink" : mediaEditingController.text.trim(),
                          "tasktype" : "multiplechoice",
                          "multichoices": [correctEditingController.text.trim(), answer2EditingController.text.trim(),
                            answer3EditingController.text.trim(), answer4EditingController.text.trim()],
                          "correctchoice": correctEditingController.text.trim(),
                          "imagelink" : imageEditingController.text.trim(),
                          "prompt" : promptEditingController.text.trim()
                        }
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                        taskName: namePasser),
                    )
                    );
                  },
                ),
              ],
            )
        )
    );
  }
}

class freeText extends StatelessWidget {
  List<Widget> course;
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  TextEditingController mediaEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Free Text Perception')),
        body: Center(
            child: ListView(
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
                    controller: mediaEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Media Link',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: imageEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Image Link (Optional)',
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
                    pathPasser.updateData(
                        {
                          "medialink" : mediaEditingController.text.trim(),
                          "tasktype" : "freetext",
                          "imagelink" : imageEditingController.text.trim(),
                          "prompt" : promptEditingController.text.trim()
                        }
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                          taskName: namePasser),
                    )
                    );
                  },
                ),
              ],
            )
        ));
  }
}

class videoPerception extends StatefulWidget {
  _videoPerception createState()=> _videoPerception();
}

class _videoPerception extends State<videoPerception> {
  List<Widget> course;
  String dropdownValue = "Free Text";
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Video Perception')),
        body: Center(
            child: ListView(
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
                Visibility(
                  child: Column(
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
                      ]
                  ),
                  visible: _visible,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: mediaEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Media Link',
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
                    if(_visible)
                    {
                      pathPasser.updateData(
                          {

                            "medialink" : mediaEditingController.text.trim(),
                            "tasktype" : "video",
                            "multichoices": [correctEditingController.text.trim(), answer2EditingController.text.trim(),
                              answer3EditingController.text.trim(), answer4EditingController.text.trim()],
                            "correctchoice": correctEditingController.text.trim(),
                            "prompt" : promptEditingController.text.trim()
                          }
                      );
                    }

                    else {
                      pathPasser.updateData(
                          {
                            "medialink" : mediaEditingController.text.trim(),
                            "tasktype" : "video",
                            "prompt" : promptEditingController.text.trim()
                          }
                      );
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                          taskName: namePasser),
                    )
                    );
                  },
                ),
              ],
            )
        ));
  }
}

class constrainedProd extends StatelessWidget {
  List<Widget> course;
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController correctEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Constrained Production Task')),
        body: Center(
            child: ListView(
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

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: imageEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Image Link (Optional)',
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
                    pathPasser.updateData(
                        {
                          "tasktype" : "constproduction",
                          "correctchoice" : correctEditingController.text.trim(),
                          "imagelink" : imageEditingController.text.trim(),
                          "prompt" : promptEditingController.text.trim()
                        }
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                          taskName: namePasser),
                    )
                    );
                  },
                ),
              ],
            )
        ));
  }
}

class unconstrainedProd extends StatelessWidget {
  List<Widget> course;
  TextEditingController promptEditingController = new TextEditingController();
  TextEditingController imageEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Unconstrained Production Task')),
        body: Center(
            child: ListView(
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
                    controller: imageEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Image Link (Optional)',
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
                    pathPasser.updateData(
                        {
                          "tasktype" : "unconstproduction",
                          "imagelink" : imageEditingController.text.trim(),
                          "prompt" : promptEditingController.text.trim()
                        }
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Tasks(
                          taskName: namePasser),
                    )
                    );
                  },
                ),
              ],
            )
        ));
  }
}


