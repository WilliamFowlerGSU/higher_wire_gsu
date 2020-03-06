//import 'dart:async';
import 'package:flutter/material.dart';
import './HomeFeedScreen.dart' as HomeFeedScreeen;
//import './globalStore.dart' as globalStore;

void main() {
  runApp(new MaterialApp(home: new HigherWire(),
    theme: ThemeData(
    primaryColor: Colors.green,
  ),));
}

class HigherWire extends StatefulWidget {
  @override
  createState() => new HigherWireState();
}

class HigherWireState extends State<HigherWire>
    with SingleTickerProviderStateMixin {
  TabController controller;
//  Future ensureLogIn() async {
//    await globalStore.logIn;
//  }


  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 1);
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
          title: new Text("Higher Wire"),
          centerTitle: true,

        ),
        bottomNavigationBar: new Material(
            color: Colors.green[600],
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(icon: new Icon(Icons.view_headline, size: 30.0)),
//              new Tab(icon: new Icon(Icons.view_module, size: 30.0)),
//              new Tab(icon: new Icon(Icons.explore, size: 30.0)),
//              new Tab(icon: new Icon(Icons.bookmark, size: 30.0)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new HomeFeedScreeen.HomeFeedScreen(),
        ]));
  }
}