import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Course.dart';
import 'package:flutter_app/providers/course_provider.dart';
import 'package:flutter_app/utils/session.dart';

import '../authentication.dart';
import '../main.dart';
import 'ModulePage.dart';

class CoursePage extends StatefulWidget {
/*  @override
  void initState() {
    //final courseProvider = Provider.of<CourseProvider>(context);
    super.initState();
  }*/

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //This provider instance will load the courses for the current user.
    var courseProvider = Provider.of<CourseProvider>(context, listen: false);
    Session userSession;
    Future<List<Course>> userCourses = courseProvider.courses;
    String courseStatus = "Assigned Courses";
    //Current device screen width and height
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            title: Text('Course Selection Page'),
            backgroundColor: Colors.green,
            leading: Container()),
        body:
            //Builds the list of course ListTiles from the backend.
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                courseStatus,
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FutureBuilder<List<Course>>(
                future: userCourses,
                builder: (context, snapshot) {
                  //This will give us a loading indicator while we await the snapshot.
                  if (snapshot.data == null) return CircularProgressIndicator();
                  if (snapshot.data.length == 0) {
                    courseStatus =
                        "No courses found, please contact your instructor!";
                    return Column(children: <Widget>[
                      Text(courseStatus),
                      Image.asset("assets/images/notfound.png",
                          height: 50, width: 50)
                    ]);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      print("Building list of courses");
                      print(index);
                      print(snapshot.data[index].id);
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        subtitle: (snapshot.data[index].prefix != null)
                            ? Text(snapshot.data[index].prefix)
                            : Text(""),
                        leading: Icon(Icons.event_note),
                        trailing: Icon(Icons.arrow_forward_outlined),
                        onTap: () {
                          userSession = new Session(
                              courseId: snapshot.data[index].id,
                              designerId: snapshot.data[index].designerId);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ModulePage(
                                courseName: snapshot.data[index].name,
                                userSession: userSession),
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
            RaisedButton(
              child: Text("Refresh List"),
              onPressed: () {
                setState(() {});
              },
            ),
            RaisedButton(
              onPressed: () {
                context.read<Authentication>().signOut();
              },
              child: Text("Sign out"),
            ),
          ],
        ),
      ),
    );
  }
}
