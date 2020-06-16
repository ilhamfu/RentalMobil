// import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'misc.dart';

class DetailPageBody extends StatelessWidget {
  final int timeDifference;

  final Function setDate;

  final DocumentSnapshot data;
  final DateTime startDate;
  final DateTime endDate;
  const DetailPageBody({
    Key key,
    this.data,
    this.setDate,
    this.startDate,
    this.endDate,
    this.timeDifference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _RentDetailWidget(
            data: data,
            endDate: endDate,
            startDate: startDate,
            updateDate: setDate),
        _PaymentDetailWidget(
            timeDifference: timeDifference, price: data["harga_sewa"] ?? 0)
      ],
    );
  }
}

class SecondPage extends StatefulWidget {
  final Map<String,dynamic> payload;
  SecondPage({Key key, this.payload}) : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _PaymentDetailWidget extends StatelessWidget {
  final int timeDifference;

  final int price;
  const _PaymentDetailWidget({
    Key key,
    this.timeDifference,
    this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice, tax, totalPaid;
    if (timeDifference > 0) {
      totalPrice = price * timeDifference * 1.0;
      tax = totalPrice * 5 / 100;
      totalPaid = totalPrice + tax;
    } else {
      totalPrice = 0;
      tax = 0;
      totalPaid = 0;
    }

    return Expanded(
      flex: 8,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Total Pembayaran",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                Text("RP. ${totalPaid.toStringAsFixed(2).padLeft(11)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF72A4C3)))
              ],
            ),
          ),
          Divider(
            color: Color(0xFF72A4C3),
            thickness: 2,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Bayar Sewa",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "RP. ${totalPrice.toStringAsFixed(2).padLeft(10)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Pajak",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "RP. ${tax.toStringAsFixed(2).padLeft(13)}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RentDetailWidget extends StatelessWidget {
  final DateTime startDate;

  final DateTime endDate;
  final Function updateDate;
  final DocumentSnapshot data;
  const _RentDetailWidget({
    Key key,
    this.startDate,
    this.endDate,
    this.updateDate,
    this.data,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 30),
        decoration: BoxDecoration(
            color: secondaryColor,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)]),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Logo"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Kode",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text("${data.documentID}",
                            style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.black38,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data["nama"],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                    CachedNetworkImage(
                        height: 120,
                        width: 120,
                        imageUrl: data["gambar"]??"",
                        placeholder: (context, url) => Container(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget: (context, url, misc) => Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  boxShadow: [
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
                            ))
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.black38,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Material(
                      child: InkWell(
                        onTap: () async {
                          var data = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 1)),
                              lastDate:
                                  DateTime(DateTime.now().year + 1, 12, 31));
                          if (data != null) {
                            updateDate(data, endDate);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Tanggal Sewa",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                )
                              ],
                            ),
                            Text(
                                "${DateFormat("yyyy-MMMM-dd").format(startDate)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF72A4C3),
                                    fontSize: 16))
                          ],
                        ),
                      ),
                    )),
                    Expanded(
                        child: Material(
                      child: InkWell(
                        onTap: () async {
                          var data = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 1)),
                              lastDate:
                                  DateTime(DateTime.now().year + 1, 12, 31));
                          if (data != null) {
                            updateDate(startDate, data);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Tanggal Kembali",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.edit,
                                  size: 14,
                                )
                              ],
                            ),
                            Text(
                                "${DateFormat("yyyy-MMMM-dd").format(endDate)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF72A4C3)))
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondPageState extends State<SecondPage> {
  DateTime startDate;
  DateTime endDate;
  int timeDifference;
  bool canSave = true;

  void _updateData() async {
    try {
      await Firestore.instance
          .collection("mobil")
          .document((widget.payload["data"] as DocumentSnapshot)?.documentID)
          .setData({"tersedia": false,"user":(widget.payload["user"] as FirebaseUser)?.uid,"tanggal_sewa":startDate,"tanggal_kembali":endDate}, merge: true);
          
      Navigator.of(context).pop(true);
    } catch (e) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "KONFIRMASI",
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w600),
        ),
        backgroundColor: secondaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: DetailPageBody(
          setDate: _updateDate,
          data: widget.payload["data"],
          startDate: startDate,
          endDate: endDate,
          timeDifference: timeDifference),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        disabledElevation: 0,
        backgroundColor: canSave ? null : Colors.grey,
        onPressed: canSave ? _updateData : null,
        child: Icon(Icons.check),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var date = DateTime.now();
    startDate = DateTime(date.year, date.month, date.day);
    endDate = startDate.add(Duration(days: 7));
    timeDifference = 7;
  }

  _updateDate(DateTime startDate, DateTime endDate) {
    setState(() {
      this.startDate = startDate;
      this.endDate = endDate;
      timeDifference = endDate.difference(startDate).inDays;
      print(timeDifference);
      if (timeDifference < 1) {
        canSave = false;
      } else {
        canSave = true;
      }
    });
  }
}
