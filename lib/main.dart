import 'dart:async';
import 'package:flutter/material.dart';
import './HomeFeedScreen.dart' as HomeFeedScreeen;
import './SourceLibraryScreen.dart' as SourceLibraryScreen;
import './globalStore.dart' as globalStore;

void main() {
  runApp(new MaterialApp(home: new HigherWire(),
    theme: ThemeData(
    primaryColor: Colors.grey,
  ),));
}

class HigherWire extends StatefulWidget {
  @override
  createState() => new HigherWireState();
}

class HigherWireState extends State<HigherWire>
    with SingleTickerProviderStateMixin {
  TabController controller;
  Future ensureLogIn() async {
    await globalStore.logIn;
  }


  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new IconButton(
              icon: Image.asset('assets/images/icons/higherWire.png',
                  scale: 0.1),
            ),
          centerTitle: true,
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(
//                Icons.settings,
//                color: Colors.white,
//              ),
//            )
//          ],
        ),
        bottomNavigationBar: new Material(
            color: Colors.green[600],
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(icon: new Icon(Icons.view_headline, size: 30.0)),
              new Tab(icon: new Icon(Icons.view_module, size: 30.0)),
//              new Tab(icon: new Icon(Icons.explore, size: 30.0)),
//              new Tab(icon: new Icon(Icons.bookmark, size: 30.0)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new HomeFeedScreeen.HomeFeedScreen(),
          new SourceLibraryScreen.SourceLibraryScreen(),
        ]));
  }
}