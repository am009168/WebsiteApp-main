import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/utils/utils.dart';
import '../main.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:async';
import 'LessonPage.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

//Widget defining the constrained speech audio demo.
class ConstrainedProduction extends StatefulWidget {
  ConstrainedProduction({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _ConstrainedProductionState createState() => _ConstrainedProductionState();
}

//Credit for this widget goes to the flutter_audio_recorder team.
class _ConstrainedProductionState extends State<ConstrainedProduction> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  //Audio recorder variables
  FirestoreService firestoreService = FirestoreService();
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);
  String _alert;
  String _instruction =
      "Please pronounce the word listed below. Only record youself saying the presented word. Click Play to review the recording and moveon to the next exercise to submit.";
  String imagePath; //= "assets/images/apple.png";

  //Task variables
  String prompt;
  String recordingUrl;
  Task currentTask;
  int taskNumber;

  //Variables for response
  Response learnerResponse;
  List<String> learnerAnswers;
  double attemptCount;

  @override
  void initState() {
    super.initState();
    //Task init
    //Get the current task before we increment to the next one for the following task.
    currentTask =
        widget.userSession.currentTasks.elementAt(widget.userSession.taskIndex);
    print(currentTask.toString());
    print("Current TASK ID: " + currentTask.id.toString());
    print("Current TASK TYPE: " + currentTask.taskType.toString());
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    taskNumber = widget.userSession.taskIndex;
    prompt = currentTask.prompt;
    //Response init
    attemptCount = 0;
    learnerAnswers = <String>[];
    //Prepare recorder
    Future.microtask(() {
      _prepare();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text("Task " + taskNumber.toString() + ": ConstProduction Task"),
          leading: Container(),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    child: Text(_instruction),
                    color: Colors.green,
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                  ),
                ),
                (currentTask.imageLink != null)
                    ? Expanded(
                        flex: 4,
                        child: Image.network(currentTask.imageLink,
                            height: 100, width: 100),
                      )
                    : Container()
              ]),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prompt,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              //Text(
              //  '${_recording?.path ?? "-"}',
              //  style: Theme.of(context).textTheme.bodyText2,
              //),
              SizedBox(
                height: 20,
              ),
              //Text(
              //  'Duration',
              //  style: Theme.of(context).textTheme.headline6,
              //),
              SizedBox(
                height: 5,
              ),
              //Text(
              //  '${_recording?.duration ?? "-"}',
              //  style: Theme.of(context).textTheme.bodyText2,
              //),
              SizedBox(
                height: 20,
              ),
              //Could be used for future metrics!
              //Text(
              //'Metering Level - Average Power',
              //style: Theme.of(context).textTheme.headline6,
              //),
              SizedBox(
                height: 5,
              ),
              //Text(
              //  '${_recording?.metering?.averagePower ?? "--"}',
              //  style: Theme.of(context).textTheme.bodyText2,
              //),
              SizedBox(
                height: 20,
              ),
              //Text(
              // 'Status',
              //style: Theme.of(context).textTheme.headline6,
              // ),
              SizedBox(
                height: 5,
              ),
              //Useful for debugging later
              // Text(
              //  '${_recording?.status ?? "-"}',
              // style: Theme.of(context).textTheme.bodyText2,
              //),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: RaisedButton(
                      child: Text('Play'),
                      disabledTextColor: Colors.white,
                      disabledColor: Colors.grey.withOpacity(0.5),
                      //If the recording status is stopped, run play, otherwise
                      //Do nothing.
                      onPressed: _recording?.status == RecordingStatus.Stopped
                          ? _play
                          : null,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: RaisedButton(
                      onPressed: _opt,
                      child: _buttonIcon,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 70,
              ),
              // Text(
              //   '${_alert ?? ""}',
              //   style: Theme.of(context)
              //       .textTheme
              //       .headline6
              //       .copyWith(color: Colors.red),
              // ),
              RaisedButton(
                onPressed: () {
                  //For now, return to the homepage after we complete the lesson.
                  if (_recording?.status == RecordingStatus.Stopped) {
                    //Create our response object
                    learnerResponse = new Response(
                        taskId: currentTask.id,
                        learnerResponses: learnerAnswers,
                        learnerId: firebaseUser.uid,
                        attemptCount: attemptCount,
                        taskType: currentTask.taskType);
                    //Push it to the session object.
                    widget.userSession.currentResponses.add(learnerResponse);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              getNextTask(widget.userSession)),
                    );
                  }
                },
                child: Text('Next Exercise.'),
              ),
            ],
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  //Used to control the recording button programmatically.
  void _opt() async {
    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          break;
        }
      case RecordingStatus.Stopped:
        {
          await _prepare();
          break;
        }

      default:
        break;
    }

    // 刷新按钮 (Refresh Button)
    setState(() {
      _buttonIcon = _playerIcon(_recording.status);
    });
  }

  Future _init() async {
    //This grabs the default directory for either IOS or Android
    String customPath = '/flutter_audio_recorder_';
    io.Directory appDocDirectory;

    //We have an iOS device
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    }
    //Grab the default directory of the android device.
    else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".wav";

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    //This updates the timer for some reason, not too sure, doesnt increment duration during recording if removed.
    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
    //Upload our recording straight to Firebase Cloud storage on each attempt
    recordingUrl = await firestoreService.uploadFile(_recording.path);
    //Push the recordingUrl as our response
    print("RECORDING URL RETURNED FROM UPLOAD: " + recordingUrl);
    learnerAnswers.add(recordingUrl);
    //Increment the attempt counter
    attemptCount++;
  }

  void _play() {
    AudioPlayer player = AudioPlayer();
    player.play(_recording.path, isLocal: true);
    print(_recording.path);
    print("File name" + _recording.path.split("/").last);
  }

//This case statement sets the image of the recording icon based on the current state of the app.
  Widget _playerIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.Initialized:
        {
          //Which is the regular dot recording button
          return Text("Record");
        }
      case RecordingStatus.Recording:
        {
          //Which is the standard stop recording icon
          return Text("Stop Record");
        }
      case RecordingStatus.Stopped:
        {
          //After we stop, show the arrow to replay.
          return Text("Retry?");
        }
      //This is if nothing else works and something really is weird.
      default:
        return Text("Record debug");
    }
  }
}

//Widget defining the constrained speech audio demo.
class UnconstrainedProduction extends StatefulWidget {
  UnconstrainedProduction({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _UnconstrainedProductionState createState() =>
      _UnconstrainedProductionState();
}

//Credit for this widget goes to the flutter_audio_recorder team.
class _UnconstrainedProductionState extends State<UnconstrainedProduction> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);
  String _alert;
  String _instruction =
      '''Please record yourself answering the prompt below. When finished, click stop and review your submission. Move on if you are ready.''';
  //Task variables
  String prompt;
  Task currentTask;
  int taskNumber;

  //Variables for response
  String recordingUrl;
  Response learnerResponse;
  List<String> learnerAnswers;
  double attemptCount;

  @override
  void initState() {
    super.initState();
    //Task init
    //Get the current task before we increment to the next one for the following task.
    currentTask =
        widget.userSession.currentTasks.elementAt(widget.userSession.taskIndex);
    print("CURRENT TASK ID: " + currentTask.id.toString());
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    taskNumber = widget.userSession.taskIndex;
    prompt = currentTask.prompt;
    //Response init
    attemptCount = 0;
    learnerAnswers = <String>[];
    //Prepare recorder
    Future.microtask(() {
      _prepare();
    });
  }

//Used to control the recording button programmatically.
  void _opt() async {
    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          break;
        }
      case RecordingStatus.Stopped:
        {
          await _prepare();
          break;
        }

      default:
        break;
    }

    // 刷新按钮 (Refresh Button)
    setState(() {
      _buttonIcon = _playerIcon(_recording.status);
    });
  }

  Future _init() async {
    //This grabs the default directory for either IOS or Android
    String customPath = '/flutter_audio_recorder_';
    io.Directory appDocDirectory;

    //We have an iOS device
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    }
    //Grab the default directory of the android device.
    else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".wav";

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    //This updates the timer for some reason, not too sure, doesnt increment duration during recording if removed.
    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
    //Upload our recording straight to Firebase Cloud storage on each attempt
    recordingUrl = await firestoreService.uploadFile(_recording.path);
    //Push the recordingUrl as our response
    print("RECORDING URL RETURNED FROM UPLOAD: " + recordingUrl);
    learnerAnswers.add(recordingUrl);
    //Increment the attempt counter
    attemptCount++;
  }

  void _play() {
    AudioPlayer player = AudioPlayer();
    player.play(_recording.path, isLocal: true);
  }

//This case statement sets the image of the recording icon based on the current state of the app.
  Widget _playerIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.Initialized:
        {
          //Which is the regular dot recording button
          return Text("Record");
        }
      case RecordingStatus.Recording:
        {
          //Which is the standard stop recording icon
          return Text("Stop Record");
        }
      case RecordingStatus.Stopped:
        {
          //After we stop, show the arrow to replay.
          return Text("Retry?");
        }
      //This is if nothing else works and something really is weird.
      default:
        return Text("Record debug");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Task " + taskNumber.toString() + ": Unconst Production"),
          leading: Container(),
        ),

        body: Center(
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: Text(_instruction),
                      color: Colors.green,
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Image.network(currentTask.imageLink,
                        height: 100, width: 100),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 50),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        prompt,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: RaisedButton(
                      child: Text('Play'),
                      disabledTextColor: Colors.white,
                      disabledColor: Colors.grey.withOpacity(0.5),
                      //If the recording status is stopped, run play, otherwise
                      //Do nothing.
                      onPressed: _recording?.status == RecordingStatus.Stopped
                          ? _play
                          : null,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: RaisedButton(
                      onPressed: _opt,
                      child: _buttonIcon,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              RaisedButton(
                onPressed: () {
                  //For now, return to the homepage after we complete the lesson.
                  if (_recording?.status == RecordingStatus.Stopped) {
                    //Create our response object
                    learnerResponse = new Response(
                        taskId: currentTask.id,
                        learnerResponses: learnerAnswers,
                        learnerId: firebaseUser.uid,
                        attemptCount: attemptCount,
                        taskType: currentTask.taskType);
                    //Push it to the session object.
                    widget.userSession.currentResponses.add(learnerResponse);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              getNextTask(widget.userSession)),
                    );
                  }
                },
                child: Text('Next Exercise.'),
              ),
            ],
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
