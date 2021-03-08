import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/utils/utils.dart';
import 'ProductionTask.dart';
import 'PerceptionTask.dart';
import 'LessonPage.dart';

class InstructionTask extends StatefulWidget {
  InstructionTask({Key key, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Session userSession;

  @override
  _InstructionTaskState createState() => _InstructionTaskState();
}

class _InstructionTaskState extends State<InstructionTask> {
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  String answer = "";
  final _formKey = GlobalKey<FormState>();
  bool _firstPress = true;
  String _question =
      "There are many types of fruits. Here are some examples with the English word and pronunciation.";

  //Task variables
  String prompt;
  Task currentTask;
  int taskNumber;

  //Method to play the audio sample.
  void play(String audio) {
    print("Playing Audio");
    //audioPlayer.play("/test.mp3", isLocal: true);
    audioCache.play(audio);
  }

  //Plays remote audio files
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
    //Task init
    //Get the current task before we increment to the next one for the following task.
    currentTask =
        widget.userSession.currentTasks.elementAt(widget.userSession.taskIndex);
    print(currentTask.multiChoices.toString());
    //Increment our index only once to prepare for the next task! Initstate will not be called again.
    widget.userSession.incrementTask();
    taskNumber = widget.userSession.taskIndex;
    print("Instruction task words: " + currentTask.instructionWords.toString());
    print("Instruction task imageLinks: " +
        currentTask.instructionImages.toString());
    print(
        "Instruction task words: " + currentTask.instructionMedias.toString());
  }

  //Builds the UI.
  @override
  Widget build(
    BuildContext context,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Task " + taskNumber.toString() + ": Instruction"),
          backgroundColor: Colors.red,
          leading: Container(),
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              currentTask.prompt,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: screenWidth, maxHeight: screenHeight - 300),
                child: ListView.separated(
                  padding: EdgeInsets.all(10),
                  itemCount: currentTask.instructionWords.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.black12,
                    height: 20,
                    thickness: 2,
                    indent: 180,
                    endIndent: 180,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Text(
                                currentTask.instructionWords[index],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blueAccent),
                              ),
                            ),
                            Expanded(
                              child: ButtonTheme(
                                minWidth: 60,
                                height: 30,
                                buttonColor: Colors.redAccent[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.white)),
                                child: RaisedButton(
                                  child: Icon(Icons.play_arrow),
                                  onPressed: () => playRemote(
                                      currentTask.instructionMedias[index]),
                                ),
                              ),
                            ),
                            (currentTask.instructionImages[index] != "none")
                                ? Flexible(
                                    child: Image.network(
                                      currentTask.instructionImages[index],
                                      height: 100,
                                      width: 100,
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                  ),
                          ]),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => getNextTask(widget.userSession)),
                );
              },
              child: Text('Next Exercise.'),
            ),
          ],
        ),
      ),
    );
  }
}
