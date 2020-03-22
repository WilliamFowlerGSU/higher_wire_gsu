import 'dart:async';
import 'package:flutter/material.dart';
import './HomeFeedScreen.dart' as HomeFeedScreeen;
import './SourceLibraryScreen.dart' as SourceLibraryScreen;
import './CategoriesScreen.dart' as CategoriesScreen;
import './BookmarkScreen.dart' as BookmarkScreen;

import './globalStore.dart' as globalStore;

void main() {
  runApp(new MaterialApp(home: new HigherWire(),
    theme: ThemeData(
    primaryColor: Colors.purple[600],
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
    controller = new TabController(vsync: this, length: 4);
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Image.asset(
          'assets/images/icons/higherWire.png',
            height: 120.0,
            width: 120.0,
            fit: BoxFit.cover,
            color: Colors.white,
              ),
            ],
          ),
        ),
        bottomNavigationBar: new Material(
            color: Colors.purple,
            child: new TabBar(controller: controller, tabs: <Tab>[
              new Tab(icon: new Icon(Icons.view_headline, size: 30.0, color: Colors.white)),
              new Tab(icon: new Icon(Icons.view_module, size: 30.0, color: Colors.white)),
              new Tab(icon: new Icon(Icons.explore, size: 30.0, color: Colors.white)),
              new Tab(icon: new Icon(Icons.bookmark, size: 30.0, color: Colors.white)),
            ])),
        body: new TabBarView(controller: controller, children: <Widget>[
          new HomeFeedScreeen.HomeFeedScreen(),
          new SourceLibraryScreen.SourceLibraryScreen(),
          new CategoriesScreen.CategoriesScreen(),
          new BookmarkScreen.BookmarksScreen(),
        ]));
  }
}