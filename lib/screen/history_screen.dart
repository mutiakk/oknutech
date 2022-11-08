import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/api.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../model/history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String auth = "";
  List<History> _listHistory = [];

  getAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("_token");
    auth = "Bearer $token";
    // print(auth);
    return (auth);
  }

  @override
  void initState() {
    super.initState();
    _getHistory();
  }

  Future<void> _getHistory() async {
    print("try History");
    getAuth();
    try {
      return http.get(await (Env().getHistory()),
          headers: {"authorization": auth}).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body['status'] == 0) {
          print("OK");
          for (var i = 0; i < body['data'].length; i++) {
            setState(() {
              History history = History.fromJson(body['data'][i]);
              _listHistory.add(history);
            });
          }
        } else if (body['code'] == 108) {
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
          _showDialog("Login kembali", body['message'], LoginScreen());
        } else {
          _showDialog("Error", "Coba kembali", MyHomePage());
        }
      }).catchError((error) {
        print(error);
      });
    } catch (e) {
      {
        print(e);
      }
    }
  }

  Future<void> _showDialog(alert, check, move) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alert),
          content: Text(check),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => move));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.orange[900],
            automaticallyImplyLeading: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            title: Text(
              "Catatan Transaksi",
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        body: _listHistory.isEmpty
            ? Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              Text("Tunggu Sebentar",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
            ],
          ),
        )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    itemCount: _listHistory == null ? 0 : _listHistory.length,
                    itemBuilder: (context, i) {
                      return boxDetail(_listHistory[i].transactionTime.toString(), _listHistory[i].amount.toString(), _listHistory[i].type);
                    }),
              ));
  }

  Widget boxDetail(date, amount, type) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.grey[350]),
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(20, 10, 30, 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tanggal dan Waktu: ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(date,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900])),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tipe Transaksi : ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(type,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900])),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Amount: ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text("Rp $amount",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900])),
              ],
            )
          ],
        ),
      ),
    );
  }
}
