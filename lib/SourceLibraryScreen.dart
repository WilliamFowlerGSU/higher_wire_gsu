import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './ArticleSourceScreen.dart' as ArticleSourceScreen;

class SourceLibraryScreen extends StatefulWidget {
  SourceLibraryScreen({Key key}) : super(key: key);

  @override
  _SourceLibraryScreenState createState() => new _SourceLibraryScreenState();
}

class _SourceLibraryScreenState extends State<SourceLibraryScreen> {
  DataSnapshot snapshot;
  var sources;
  bool change = false;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future getData() async {
    var libSources = await http.get(
        Uri.encodeFull('https://newsapi.org/v2/sources?language=en'),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "57ea042e27334f2e89f8c87e569d127f"
        });

    if (mounted) {
      this.setState(() {
        sources = json.decode(libSources.body);
      });
    }
    return "Success!";
  }

  CircleAvatar _loadAvatar(var url) {
    try {
      return new CircleAvatar(
        child: new Icon(Icons.add_to_home_screen , color:Colors.black, size: 45.0),
        backgroundColor: Colors.deepPurpleAccent[100],
        radius: 37.5,
      );
    } catch (Exception) {
      return new CircleAvatar(
        child: new Icon(Icons.offline_bolt, color:Colors.black),
        backgroundColor: Colors.deepPurpleAccent[100],
        radius: 45.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: sources == null
          ? const Center(child: const CircularProgressIndicator())
          : new GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 20.0),
        padding: const EdgeInsets.all(5.0),
        itemCount: sources == null ? 0 : sources["sources"].length,
        itemBuilder: (BuildContext context, int index) {
          return new GridTile(
            footer: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    child: new SizedBox(
                      height: 36.0,
                      width: 100.0,
                      child: new Text(
                        sources["sources"][index]["name"],
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ),
                  )
                ]),
            child: new Container(
              height: 500.0,
              padding: const EdgeInsets.only(bottom: 5.0),
              child: new GestureDetector(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Stack(
                            children: <Widget>[
                              new SizedBox(
                                child: new Container(
                                  child: _loadAvatar(
                                      sources["sources"][index]["url"]),
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 12.0, right: 10.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (_) =>
                          new ArticleSourceScreen.ArticleSourceScreen(
                            sourceId: sources["sources"][index]["id"],
                            sourceName: sources["sources"][index]["name"],
                            isCategory: false,
                          )));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}