import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rental_mobil/second_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser user;

  Future<bool> _handleSignIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      var temp = (await _auth.signInWithCredential(credential)).user;
      setState(() {
        user = temp;
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleLogOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    setState(() {
      user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F5F7),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(letterSpacing: 3),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: user != null ? _handleLogOut : _handleSignIn,
              child: Text(
                user != null ? "Log Out" : "Log In",
                style: TextStyle(color: Colors.white),
              ))
        ],
        leading: Icon(Icons.ac_unit),
        centerTitle: true,
      ),
      body: MainPageBody(user: user, handleSignIn: _handleSignIn),
    );
  }
}

class MainPageBody extends StatelessWidget {
  const MainPageBody({
    Key key,
    this.user,
    this.handleSignIn,
  }) : super(key: key);

  final FirebaseUser user;
  final Function handleSignIn;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("mobil")
            .where("tersedia", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active)
            return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                separatorBuilder: (BuildContext build, index) => SizedBox(
                      height: 10,
                    ),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext build, int index) {
                  DocumentSnapshot doc = snapshot.data.documents[index];
                  return CarListItem(
                    data: doc,
                    onTap: user == null
                        ? () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Anda perlu login untuk memesan mobil")));
                            Timer(Duration(seconds: 1), () {
                              Scaffold.of(context).hideCurrentSnackBar();
                            });
                          }
                        : () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => SecondPage(
                                    payload: {"data": doc, "user": user})));
                          },
                  );
                });
          return Container();
        });
  }
}

class CarListItem extends StatelessWidget {
  const CarListItem({
    Key key,
    this.onTap,
    this.data,
  }) : super(key: key);
  final DocumentSnapshot data;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, bottom: 16, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${data["nama"]}",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Kapasitas Maks : ${data["kapasitas"]} Orang",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Harga",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "Rp.${data["harga_sewa"].toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF72A4C3)),
                                ),
                                Text(
                                  " / Hari",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
              Expanded(
                flex: 5,
                child: CachedNetworkImage(
                    imageUrl: data["gambar"] ?? "",
                    placeholder: (context, url) => Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget: (context, url, misc) => Container(
                          decoration:
                              BoxDecoration(color: Colors.black12, boxShadow: [
                            BoxShadow(color: Colors.black12),
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: -3,
                                blurRadius: 3)
                          ]),
                          child: Center(
                            child: Icon(
                              Icons.block,
                              color: Colors.white10,
                              size: 80,
                            ),
                          ),
                        )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
