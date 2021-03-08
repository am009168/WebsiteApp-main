import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'ProductionTask.dart';
import '../Main.dart';
import 'LessonPage.dart';

import 'dart:developer';

class MultipleChoice extends StatefulWidget {
  MultipleChoice({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _MultipleChoiceState createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  static AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: audioPlayer);
  bool pressed = false;
  bool buttonsDisabled = false;
  String _instruction =
      "What is the word that is pronounced here? Click play to hear the recording.";
  //Values pulled from session object
  String prompt;
  Task currentTask;
  int taskNumber;

  //Variables for response
  Response learnerResponse;
  List<String> learnerAnswers;
  double attemptCount;

  //Method to play the audio sample. Not currently using the method for local asset playback.
  void play() {
    print("Playing Audio");
    //audioPlayer.play("/test.mp3", isLocal: true);
    audioCache.play('assets/audio/test.mp3');
  }

  void playRemote(String audioLink) async {
    //Play the audio in the link stored in the currentTask object.
    await audioPlayer.play(audioLink);
  }

  void pause() {
    print("Pausing Audio");
    audioPlayer.pause();
  }

  void stop() {
    print("Stopping Audio");
    audioPlayer.stop();
  }

  String checkAnswer(int answerIndex) {
    String currentAnswer = currentTask.multiChoices[answerIndex];
    learnerAnswers.add(currentAnswer);
    attemptCount++;
    if (currentTask.multiChoices[answerIndex] == currentTask.correctChoice) {
      return "Correct!";
    }
    return "Incorrect! :(";
  }

  void disablebuttons() {
    setState(() {
      buttonsDisabled = true;
    });
  }

  @override
  void initState() {
    super.initState();
    //Get the current task before we increment to the next one for the following task.
    currentTask =
        widget.userSession.currentTasks.elementAt(widget.userSession.taskIndex);
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    taskNumber = widget.userSession.taskIndex;
    //Response init
    attemptCount = 0;
    learnerAnswers = <String>[];
  }

  //Builds the UI.
  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    prompt = currentTask.prompt;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: key,
        appBar: AppBar(
          title: Text("Task " + taskNumber.toString() + ": Multiple Choice"),
          backgroundColor: Colors.red,
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
                              top: 20.0,
                              bottom: 20.0,
                              left: 20.0,
                              right: 20.0))),
                  (currentTask.imageLink != null)
                      ? Expanded(
                          flex: 4,
                          child: Image.network(currentTask.imageLink,
                              height: 100, width: 100),
                        )
                      : Container()
                ],
              ),
              SizedBox(height: 100),
              Row(
                children: [
                  RaisedButton(
                    onPressed: () => playRemote(currentTask.mediaLink),
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
              SizedBox(height: 50),
              //Choice 1 and 2
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      highlightColor: Colors.green,
                      color: Colors.blue,
                      onPressed: () {
                        key.currentState.showSnackBar(new SnackBar(
                          content: new Text(checkAnswer(0)),
                        ));
                      },
                      child: Text(currentTask.multiChoices[0]),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: RaisedButton(
                      highlightColor: Colors.red,
                      color: Colors.blue,
                      onPressed: () {
                        key.currentState.showSnackBar(new SnackBar(
                          content: new Text(checkAnswer(1)),
                        ));
                      },
                      child: Text(currentTask.multiChoices[1]),
                    ),
                  ),
                ],
              ),
              //Choice 3 and 4
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      highlightColor: Colors.red,
                      color: Colors.blue,
                      onPressed: () {
                        key.currentState.showSnackBar(new SnackBar(
                          content: new Text(checkAnswer(2)),
                        ));
                      },
                      child: Text(currentTask.multiChoices[2]),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: RaisedButton(
                      highlightColor: Colors.red,
                      color: Colors.blue,
                      onPressed: () {
                        key.currentState.showSnackBar(new SnackBar(
                          content: new Text(checkAnswer(3)),
                        ));
                      },
                      child: Text(currentTask.multiChoices[3]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 150),
              //Navigates to the next page.
              Row(
                children: [
                  RaisedButton(
                    onPressed: () {
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
                    },
                    child: Text('Next Exercise.'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FreeText extends StatefulWidget {
  FreeText({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _FreeTextState createState() => _FreeTextState();
}

class _FreeTextState extends State<FreeText> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  String answer = "";
  final _formKey = GlobalKey<FormState>();
  bool _firstPress = true;
  String prompt;
  Task currentTask;
  int taskNumber;

  //Variables for response
  Response learnerResponse;
  List<String> learnerAnswers;
  double attemptCount;

  //Method to play the audio sample.
  void play() {
    print("Playing Audio");
    //audioPlayer.play("/test.mp3", isLocal: true);
    audioCache.play('apple.m4a');
  }

  void playRemote(String audioLink) async {
    //Play the audio in the link stored in the currentTask object.
    await audioPlayer.play(audioLink);
  }

  void pause() {
    print("Pausing Audio");
    audioPlayer.pause();
  }

  void stop() {
    print("Stopping Audio");
    audioPlayer.stop();
  }

  @override
  void initState() {
    super.initState();
    //Get the current task before we increment to the next one for the following task.
    currentTask =
        widget.userSession.currentTasks.elementAt(widget.userSession.taskIndex);
    print(currentTask.multiChoices.toString());
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    //Make our current task number to display the incremented index.
    taskNumber = widget.userSession.taskIndex;
    //Response init
    attemptCount = 0;
    learnerAnswers = <String>[];
  }

  //Builds the UI.
  @override
  Widget build(
    BuildContext context,
  ) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Task " + taskNumber.toString() + ": Free Text"),
          backgroundColor: Colors.red,
          leading: Container(),
        ),
        body: Builder(
          builder: (context) => Center(
            child: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 4,
                        child: Container(
                            child: Text(
                                "What is the word that is pronounced here? Click play to hear the recording."),
                            color: Colors.green,
                            padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 20.0,
                                left: 20.0,
                                right: 20.0))),
                    (currentTask.imageLink != null)
                        ? Expanded(
                            flex: 4,
                            child: Image.network(currentTask.imageLink,
                                height: 100, width: 100),
                          )
                        : Container()
                  ],
                ),
                SizedBox(height: 100),
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () => playRemote(currentTask.mediaLink),
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
                SizedBox(height: 100),

                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              maxLines: null,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                //If something was submitted, add it to our answer list.
                                learnerAnswers.add(value);
                                //Mark this attempt.
                                attemptCount++;
                                return null;
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: RaisedButton(
                                color: _firstPress ? Colors.blue : Colors.grey,
                                onPressed: () {
                                  // Validate returns true if the form is valid, or false
                                  // otherwise.
                                  //Only do this on the firstPress of the button.
                                  if (_firstPress) {
                                    if (_formKey.currentState.validate()) {
                                      // If the form is valid, display a Snackbar.
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              'Answer submitted, move to the next exercise!')));
                                      //Change the button to disabled
                                      setState(() {
                                        _firstPress = !_firstPress;
                                      });
                                    }
                                  }
                                },
                                child: Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                //Navigates to the next page.
                Row(
                  children: [
                    //Only show the next page button if the user submitted an answer.
                    (!_firstPress)
                        ? RaisedButton(
                            //Generate a response and push it
                            onPressed: () {
                              //Create our response object
                              learnerResponse = new Response(
                                  taskId: currentTask.id,
                                  learnerResponses: learnerAnswers,
                                  learnerId: firebaseUser.uid,
                                  attemptCount: attemptCount,
                                  taskType: currentTask.taskType);
                              //Push it to the session object.
                              widget.userSession.currentResponses
                                  .add(learnerResponse);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        getNextTask(widget.userSession)),
                              );
                            },
                            child: Text('Next Exercise.'),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoTask extends StatefulWidget {
  VideoTask({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _VideoTaskState createState() => _VideoTaskState();
}

class _VideoTaskState extends State<VideoTask> {
  var firebaseUser = FirebaseAuth.instance.currentUser;
  String answer = "";
  String vidUrl;
  String vidId;
  final _formKey = GlobalKey<FormState>();
  bool _firstPress = true;
  //Controls the youtubeplayer widget
  YoutubePlayerController _controller;
  //Video metadata
  YoutubeMetaData _videoMetaData;
  //Current state of the YoutubePlayer.
  PlayerState _playerState;

  //Volume and listener variables
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  //Task variables
  String prompt;
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
    print(currentTask.multiChoices.toString());
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    taskNumber = widget.userSession.taskIndex;

    //Response init
    attemptCount = 0;
    learnerAnswers = <String>[];

    //Videoplayer init
    //Hardcoded value for link for now, will pull from database.
    vidUrl = currentTask.mediaLink;
    //Strip the url for just the video id.
    vidId = YoutubePlayer.convertUrlToId(vidUrl);
    _controller = YoutubePlayerController(
      initialVideoId: vidId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    //_seekToController = TextEditingController();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    //_idController.dispose();
    //_seekToController.dispose();
    super.dispose();
  }

  //Builds the UI.
  @override
  Widget build(
    BuildContext context,
  ) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Video Task"),
          backgroundColor: Colors.red,
          leading: Container(),
        ),
        body: Builder(
          builder: (context) => Center(
            child: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 4,
                        child: Container(
                            child: Text(
                                "Write a brief summary of this video. What emotions were conveyed?"),
                            color: Colors.green,
                            padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 20.0,
                                left: 20.0,
                                right: 20.0)))
                  ],
                ),
                YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  topActions: <Widget>[
                    const SizedBox(width: 8.0),
                    //This expanded widget is the onclicked overlay info for the video.
                    Expanded(
                      child: Text(
                        _controller.metadata.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      onPressed: () {
                        log('Settings Tapped!');
                      },
                    ),
                  ],
                  onReady: () {
                    _isPlayerReady = true;
                  },
                ),
                SizedBox(height: 100),

                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              maxLines: null,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                //If something was submitted, add it to our answer list.
                                learnerAnswers.add(value);
                                //Mark this attempt.
                                attemptCount++;
                                return null;
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: RaisedButton(
                                color: _firstPress ? Colors.blue : Colors.grey,
                                onPressed: () {
                                  // Validate returns true if the form is valid, or false
                                  // otherwise.
                                  //Only do this on the firstPress of the button.
                                  if (_firstPress) {
                                    if (_formKey.currentState.validate()) {
                                      // If the form is valid, display a Snackbar.
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              'Answer submitted, move to the next exercise!')));
                                      //Then change the button to disabled
                                      setState(() {
                                        _firstPress = !_firstPress;
                                      });
                                    }
                                  }
                                },
                                child: Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                //Navigates to the next page.
                Row(
                  children: [
                    (!_firstPress)
                        ? RaisedButton(
                            onPressed: () {
                              deactivate();
                              //Create our response object
                              learnerResponse = new Response(
                                  taskId: currentTask.id,
                                  learnerResponses: learnerAnswers,
                                  learnerId: firebaseUser.uid,
                                  attemptCount: attemptCount,
                                  taskType: currentTask.taskType);
                              //Push it to the session object.
                              widget.userSession.currentResponses
                                  .add(learnerResponse);
                              print("NEXT TASK ID FROM VIDEO" +
                                  widget.userSession.currentTasks
                                      .elementAt(taskNumber)
                                      .id
                                      .toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        getNextTask(widget.userSession)),
                              );
                            },
                            child: Text('Next Exercise.'),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
