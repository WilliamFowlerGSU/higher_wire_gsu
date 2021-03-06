import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import './globalStore.dart' as globalStore;
import './SearchScreen.dart' as SearchScreen;

class HomeFeedScreen extends StatefulWidget {
  HomeFeedScreen({Key key}) : super(key: key);

  @override
  _HomeFeedScreenState createState() => new _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  var data;
  var newsSelection = "cnn";
  DataSnapshot snapshot;
  var snapSources;
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  final TextEditingController _controller = new TextEditingController();
  Future getData() async {
    await globalStore.logIn;
    if (await globalStore.userDatabaseReference == null) {
      await globalStore.logIn;
    }
    snapSources = await globalStore.articleSourcesDatabaseReference.once();
    var snap = await globalStore.articleDatabaseReference.once();
    if (snapSources.value != null) {
      newsSelection = '';
      snapSources.value.forEach((key, source) {
        newsSelection = newsSelection + source['id'] + ',';
      });
    }
    var response = await http.get(
        Uri.encodeFull("http://newsapi.org/v2/top-headlines?country=us&apiKey=57ea042e27334f2e89f8c87e569d127f",));
    var localData = jsonDecode(response.body);
    // adds values that return as null
    for(var i = 0; i < 20; i++) {
      if (localData["articles"][i]["description"] == null) {
        localData["articles"][i]["description"] = "No description";
      }
      if (localData["articles"][i]["urlToImage"] == null) {
        localData["articles"][i]["urlToImage"] = 'assets/images/icons/higherWire.png';
      }
    }

    this.setState(() {
      data = localData;
      snapshot = snap;
    });
    return "Success!";
  }

  _hasArticle(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['url'].compareTo(article['url']) == 0) {
            flag = 1;
            return;
          }
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushArticle(article) {
    globalStore.articleDatabaseReference.push().set({
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
          globalStore.articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Article Removed'),
            backgroundColor: Colors.purpleAccent,
          ));
        }
      });
      if (flag != 1) {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('Article Saved'),
          backgroundColor: Colors.purpleAccent,
        ));
        pushArticle(article);
      }
    } else {
      pushArticle(article);
    }
    this.getData();
  }

  _onRemoveSource(id, name) {
    if (snapSources != null) {
      snapSources.value.forEach((key, source) {
        if (source['id'].compareTo(id) == 0) {
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('Are you sure you want to remove $name?'),
            backgroundColor: Colors.purpleAccent,
            duration: new Duration(seconds: 5),
            action: new SnackBarAction(
                label: 'Yes',
                onPressed: () {
                  globalStore.articleSourcesDatabaseReference
                      .child(key)
                      .remove();
                  Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text('$name Removed'),
                      backgroundColor: Colors.purpleAccent));
                }),
          ));
        }
      });
      this.getData();
    }
  }

  void handleTextInputSubmit(var input) {
    if (input != '') {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (_) =>
              new SearchScreen.SearchScreen(searchQuery: input)));
    }
  }

  @override
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
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.deepPurpleAccent[100],
      body: new Column(children: <Widget>[
        new Padding(
          padding: new EdgeInsets.all(0.0),
          child: new PhysicalModel(
            color: Colors.purpleAccent,
            elevation: 3.0,
            child: new TextField(
              controller: _controller,
              onSubmitted: handleTextInputSubmit,
              decoration: new InputDecoration(
                  hintText: 'Search For News...', icon: new Icon(Icons.search)),
            ),
          ),
        ),
        new Expanded(
          child: data == null
              ? const Center(child: const CircularProgressIndicator())
              : data["articles"].length != 0
              ? new ListView.builder(
            itemCount: data == null ? 0 : data["articles"].length,
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (BuildContext context, int index) {
              return new Card(
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
                              timeAgo.format((DateTime.parse(data["articles"][index]["publishedAt"]))),
                              style: new TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          new Padding(
                            padding: new EdgeInsets.all(5.0),
                            child: new Text(
                              data["articles"][index]["source"]["name"],
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
                                      data["articles"][index]["title"],
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
                                      data["articles"][index]["description"],
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
                                    data["articles"][index]["url"],
                                   );
                              },
                            ),
                          ),
                          new Column(
                            children: <Widget>[
                              new Padding(
                                padding:
                                new EdgeInsets.only(top: 8.0),
                                child: new SizedBox(
                                  height: 100.0,
                                  width: 100.0,
                                  child: new Container(
                                      child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/images/icons/higherWire.png',
                                          image:data["articles"][index]["urlToImage"],
                                          fit: BoxFit.cover,
                                      )
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
                                      Share.share(data["articles"][index]["url"]);
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
                                            : buildButtonColumn(Icons
                                            .bookmark_border)),
                                    onTap: () {
                                      _onBookmarkTap(
                                          data["articles"][index]);
                                    },
                                  ),
                                  new GestureDetector(
                                    child: new Padding(
                                        padding:
                                        new EdgeInsets.all(5.0),
                                        child: buildButtonColumn(
                                            Icons.not_interested)),
                                    onTap: () {
                                      _onRemoveSource(
                                          data["articles"][index]["source"]["id"],
                                          data["articles"][index]["source"]["name"]);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ), ////
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
                  "No articles saved",
                  style: new TextStyle(
                      fontSize: 40.0, color: Colors.purpleAccent),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}