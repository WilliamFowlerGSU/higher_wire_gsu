import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import './globalStore.dart' as globalStore;

class BookmarksScreen extends StatefulWidget {
  BookmarksScreen({Key key}) : super(key: key);

  @override
  _BookmarksScreenState createState() => new _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  DataSnapshot snapshot;
  bool change = false;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future updateSnapshot() async {
    var snap = await globalStore.articleDatabaseReference.once();
    this.setState(() {
      snapshot = snap;
    });
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.updateSnapshot();
  }

  _onBookmarkTap(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      value.forEach((k, v) {
        if (v['url'].compareTo(article['url']) == 0) {
          globalStore.articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Article removed'),
            backgroundColor: Colors.purpleAccent,
          ));
        }
      });
      this.updateSnapshot();
      this.setState(() {
        change = true;
      });
    }
  }

  Column buildButtonColumn(IconData icon) {
    Color color = Theme.of(context).primaryColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(icon, color: color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.deepPurpleAccent[100],
      body: (snapshot != null && snapshot.value != null)
          ? new Column(
        children: <Widget>[
          new Flexible(
              child: new FirebaseAnimatedList(
                query: globalStore.articleDatabaseReference,
                sort: (a, b) => b.key.compareTo(a.key),
                padding: new EdgeInsets.all(2.0),
                itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, index) {
                  return new GestureDetector(
                    child: new Card(
                      color: Colors.black,
                      elevation: 1.7,
                      child: new Padding(
                        padding: new EdgeInsets.all(10.0),
                        child: new Column(
                          children: [
                            new Row(
                              children: <Widget>[
                                new Padding(
                                  padding: new EdgeInsets.only(left: 4.0),
                                  child: new Text(
                                    timeAgo.format(DateTime.parse(
                                        snapshot.value["publishedAt"])),
                                    style: new TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                new Padding(
                                  padding: new EdgeInsets.all(5.0),
                                  child: new Text(
                                    snapshot.value["source"],
                                    style: new TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purpleAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            new Row(
                              children: [
                                new Expanded(
                                  child: new GestureDetector(
                                    child: new Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 8.0,
                                              bottom: 8.0,
                                              top: 8.0),
                                          child: new Text(
                                            snapshot.value["title"],
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.only(
                                              left: 4.0,
                                              right: 4.0,
                                              bottom: 4.0),
                                          child: new Text(
                                            snapshot.value["description"],
                                            style: new TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      flutterWebviewPlugin.launch(
                                          snapshot.value["url"]);
                                    },
                                  ),
                                ),
                                new Column(
                                  children: <Widget>[
                                    new Padding(
                                      padding: new EdgeInsets.only(top: 8.0),
                                      child: new SizedBox(
                                        height: 100.0,
                                        width: 100.0,
                                        child: new Image.network(
                                          snapshot.value["urlToImage"],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        new GestureDetector(
                                          child: new Padding(
                                              padding:
                                              new EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 5.0),
                                              child: buildButtonColumn(
                                                  Icons.share)),
                                          onTap: () {
                                            Share.share(snapshot.value["url"]);
                                          },
                                        ),
                                        new GestureDetector(
                                          child: buildButtonColumn(
                                              Icons.bookmark),
                                          onTap: () {
                                            _onBookmarkTap(snapshot.value);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
        ],
      )
          : new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Icon(Icons.chrome_reader_mode,
                color: Colors.purpleAccent, size: 120.0),
            new Text(
              "No articles saved",
              style: new TextStyle(fontSize: 40.0, color: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}