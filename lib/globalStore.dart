import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


final _googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final _auth = FirebaseAuth.instance;
final databaseReference = FirebaseDatabase.instance.reference();

FirebaseUser currentUser;

var sourceList = [];
var userDatabaseReference;
var articleSourcesDatabaseReference;
var articleDatabaseReference;

Future<String> _ensureLoggedIn() async {

  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  userDatabaseReference = databaseReference.child(user.uid);
  articleDatabaseReference = databaseReference.child(user.uid).child('articles');
  articleSourcesDatabaseReference = databaseReference.child(user.uid).child('sources');

  return 'signInWithGoogle succeeded: $user';
  }

var logIn = _ensureLoggedIn();