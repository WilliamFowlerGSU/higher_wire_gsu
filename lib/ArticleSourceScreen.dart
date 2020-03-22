import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import './globalStore.dart' as globalStore;

class ArticleSourceScreen extends StatefulWidget {
  ArticleSourceScreen(
      {Key key,
        this.sourceId = "techcrunch",
        this.sourceName = "TechCrunch",
        this.isCategory: false})
      : super(key: key);
  final sourceId;
  final sourceName;
  final isCategory;
  @override
  _ArticleSourceScreenState createState() => new _ArticleSourceScreenState(
      sourceId: this.sourceId,
      sourceName: this.sourceName,
      isCategory: this.isCategory);
}

class _ArticleSourceScreenState extends State<ArticleSourceScreen> {
  _ArticleSourceScreenState({this.sourceId, this.sourceName, this.isCategory});
  final sourceId;
  final sourceName;
  final isCategory;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  final auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  bool change = false;
  DataSnapshot snapshot;
  var data;
  var userDatabaseReference;
  var articleDatabaseReference;

  Future getData() async {
    var response;

    if (isCategory) {
      response = await http.get(
          Uri.encodeFull('https://newsapi.org/v2/top-headlines?category=' +
              sourceId +
              '&language=en'),
          headers: {
            "Accept": "application/json",
            "X-Api-Key": "57ea042e27334f2e89f8c87e569d127f"
          });
    } else {
      response = await http.get(
          Uri.encodeFull(
              'https://newsapi.org/v2/top-headlines?sources=' + sourceId),
          headers: {
            "Accept": "application/json",
            "X-Api-Key": "57ea042e27334f2e89f8c87e569d127f"
          });
    }
    userDatabaseReference = databaseReference.child(globalStore.currentUser.uid);
    articleDatabaseReference = userDatabaseReference.child('articles');
    var snap = await articleDatabaseReference.once();
    var localData = jsonDecode(response.body);

    for(var i = 0; i < localData["articles"].length; i++) {
      if (localData["articles"][i]["description"] == null) {
        localData["articles"][i]["description"] = "No description";
      }
      if (localData["articles"][i]["urlToImage"] == null) {
        localData["articles"][i]["urlToImage"] = 'assets/images/icons/higherWire.png';
      }
    }
    if (mounted) {
      this.setState(() {
        data = localData;
        snapshot = snap;
      });
    }

    return "Success!";
  }

  _hasArticle(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['url'].compareTo(article['url']) == 0) flag = 1;
          return;
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushArticle(article) {
    articleDatabaseReference.push().set({
      'source': article["source"]["name"],
      'description': article['description'],
      'publishedAt': article['publishedAt'],
      'title': article['title'],
      'url': article['url'],
      'urlToImage': article['urlToImage'],
    });
  }

  _onBookmarkTap(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      value.forEach((k, v) {
        if (v['url'].compareTo(article['url']) == 0) {
          flag = 1;
          articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Article removed'),
            backgroundColor: Colors.white,
          ));
        }
      });
      if (flag != 1) {
        pushArticle(article);
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Article added'),
          backgroundColor: Colors.white,
        ));
      }
      this.setState(() {
        change = true;
      });
    } else {
      pushArticle(article);
    }
  }

  void initState() {
    super.initState();
    this.getData();
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
      appBar: new AppBar(
        title: new Text(sourceName),
        centerTitle: true,
      ),
      backgroundColor: Colors.deepPurpleAccent[100],
      body: data == null
          ? const Center(child: const CircularProgressIndicator())
          : data["articles"].length != 0
          ? new ListView.builder(
        itemCount: data == null ? 0 : data["articles"].length,
        padding: new EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
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
                            timeAgo.format(DateTime.parse(data["articles"][index]["publishedAt"])),
                            style: new TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: new EdgeInsets.all(5.0),
                          child: new Text(
                            data["articles"][index]["source"]["name"],
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
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
                                    data["articles"][index]["title"],
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                new Padding(
                                  padding: new EdgeInsets.only(
                                      left: 4.0,
                                      right: 4.0,
                                      bottom: 4.0),
                                  child: new Text(
                                    data["articles"][index]["description"],
                                    style: new TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              flutterWebviewPlugin.launch(
                                  data["articles"][index]["url"]);
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
                                  data["articles"][index]["urlToImage"],
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
                                    Share.share(data["articles"][index]
                                    ["url"]);
                                  },
                                ),
                                new GestureDetector(
                                  child: new Padding(
                                      padding:
                                      new EdgeInsets.all(5.0),
                                      child: _hasArticle(
                                          data["articles"][index])
                                          ? buildButtonColumn(
                                          Icons.bookmark)
                                          : buildButtonColumn(
                                          Icons.bookmark_border)),
                                  onTap: () {
                                    _onBookmarkTap(
                                        data["articles"][index]);
                                  },
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Icon(Icons.chrome_reader_mode,
                color: Colors.purpleAccent, size: 120.0),
            new Text(
              "No Articles Saved",
              style:
              new TextStyle(fontSize: 40.0, color: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}