import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:http/http.dart' as http;

import '../model/api.dart';
import '../model/profile.dart';
import 'history_screen.dart';
import 'login_screen.dart';


class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Profile user = Profile();
  var balance;
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController nomorTerima = TextEditingController();
  var amountController = MoneyMaskedTextController(
      leftSymbol: "Rp ", decimalSeparator: ",", initialValue: 0.0);

  //String token="";
  String auth = "";

  @override
  void initState() {
    super.initState();
    _getProfile();
    _getBalance();
  }

  getAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("_token");
    auth = "Bearer $token";
    // print(auth);
    return (auth);
  }

  Future<void> _getProfile() async {
    print("try Name");
    getAuth();
    _getBalance();
    try {
      return http.get(await (Env().getProfile()),
          headers: {"authorization": auth}).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body["status"] == 0) {
          for (var i = 0; i < body['data'].length; i++) {
            setState(() {
              user = Profile.fromJson(body['data']);
            });
          }
        } else if (body['code'] == 108) {
          _showDialog("Login kembali", body['message'], LoginScreen());
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
        } else {
          _showDialog("Error", "", MyHomePage());
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

  Future<void> _updateProfile() async {
    print("update pak");
    print(fname.text);
    getAuth();
    try {
      return http.post(await Env().postUpdateProfile(),
          body: {"first_name": fname.text, "last_name": lname.text},
          headers: {"authorization": auth}).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body["status"] == 0) {
          _showDialog(
              "Sukses", "Anda berhasil mengganti profile!", MyHomePage());
        } else if (body['status'] == 102) {
          _showDialog("Login kembali", body['message'], LoginScreen());
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
        } else {
          _showDialog("Error", "", MyHomePage());
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

  Future<void> _topUpBalance() async {
    print("coba topUp");
    print(amountController.numberValue);
    getAuth();
    print(auth);
    try {
      return http.post(await Env().postTopup(),
          body: jsonEncode({"amount": amountController.numberValue}),
          headers: {
            "authorization": auth,
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body["status"] == 0) {
          _showDialog("Sukses", "Saldo Anda akan bertambah!", MyHomePage());
        } else if (body['status'] == 102) {
          _showDialog("Login kembali", body['message'], LoginScreen());
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
        } else {
          _showDialog("Error", "", MyHomePage());
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

  Future<void> _transfer() async {
    print("coba transfer");
    print(amountController.numberValue);
    getAuth();
    print(auth);
    try {
      return http.post(await Env().postTransfer(),
          body: jsonEncode({"amount": amountController.numberValue}),
          headers: {
            "authorization": auth,
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body["status"] == 0) {
          _showDialog("Sukses", "Berhasil Terkirim ke ${nomorTerima.text.toString()}", MyHomePage());
        } else if (body['status'] == 102) {
          _showDialog("Login kembali", body['message'], LoginScreen());
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
        } else {
          _showDialog("Error", "", MyHomePage());
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

  Future<void> _getBalance() async {
    print("try Balance");
    getAuth();
    try {
      return http.get(await (Env().getBalance()),
          headers: {"authorization": auth}).then((value) async {
        final body = jsonDecode(value.body);
        print(body);
        if (body["status"] == 0) {
          balance = body["data"]["balance"];
        } else if (body['code'] == 108) {
          _showDialog("Login kembali", body['message'], LoginScreen());
          SharedPreferences prefs =
              await SharedPreferences.getInstance();
          prefs.clear();
        } else {
          _showDialog("Error", "", MyHomePage());
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
        body: RefreshIndicator(
          onRefresh: _getProfile,
          child: SingleChildScrollView(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              backgroundHome(
                  "${user.firstName ?? ""} ${user.lastName?? ""}", balance?? 0),
              InkWell(
                onTap: () {
                  print("Topup");
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Wrap(
                          children: [
                            Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      //alignment: Alignment.center,
                                      height: 150,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30))),
                                      child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Topup",
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange[800]),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                              "Masukkan Nominal Saldo : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.white))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150,
                                    )
                                  ],
                                ),
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  top: 80,
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.all(20),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.red,
                                    //   border: Border.all(color: Colors.grey),
                                    //   borderRadius: BorderRadius.circular(20)
                                    // ),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(10)),
                                          child: TextFormField(
                                            controller: amountController,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.orange,
                                              // fontWeight: FontWeight.w600,
                                            ),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              focusColor: Colors.white,
                                              //add prefix icon
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.orange,
                                                    width: 1.0),
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                              fillColor: Colors.orange,
                                              hintText: "contoh: 10000",
                                            ),
                                          ),
                                        ),
                                        MaterialButton(
                                          height: 40,
                                          color: Colors.orange[800],
                                          minWidth: 150,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20)),
                                          onPressed: () {
                                            if (amountController.numberValue ==
                                                0) {
                                              _showDialog("Cek Nominal",
                                                  "Isi Nominal", MyHomePage());
                                            } else if (amountController
                                                .numberValue <
                                                1000 &&
                                                amountController.numberValue !=
                                                    0) {
                                              _showDialog(
                                                  "Cek Nominal",
                                                  "Minimal Saldo 1000",
                                                  MyHomePage());
                                            } else {
                                              print(
                                                  amountController.numberValue);
                                              _topUpBalance();
                                            }
                                          },
                                          child: const Text("Isi Saldo"),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    // builder: (context) =>
                    //     Container(height: 100,color: Colors.blue,)
                  );
                },
                child: menus("Topup", Icons.add_box_outlined),
              ),
              InkWell(
                onTap: () {
                  print("Transfer");
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[900],
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30))),
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Wrap(
                          children: [
                            Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      //alignment: Alignment.center,
                                      height: 150,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                          Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              topLeft: Radius.circular(30))),
                                      child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Transfer",
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange[800]),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text("Masukkan Nominal Transfer : ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  //fontWeight: FontWeight.bold,
                                                  color: Colors.grey[900]))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150,
                                    )
                                  ],
                                ),
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  top: 70,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.black,width: 2),
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: nomorTerima,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.orange,
                                                  // fontWeight: FontWeight.w600,
                                                ),
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  focusColor: Colors.white,
                                                  //add prefix icon
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10.0),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: const BorderSide(
                                                        color: Colors.orange,
                                                        width: 1.0),
                                                    borderRadius:
                                                    BorderRadius.circular(10.0),
                                                  ),
                                                  fillColor: Colors.orange,
                                                  hintText: "Masukkan Nomor Penerima",
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              TextFormField(
                                                controller: amountController,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.orange,
                                                  // fontWeight: FontWeight.w600,
                                                ),
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  focusColor: Colors.white,
                                                  //add prefix icon
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10.0),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: const BorderSide(
                                                        color: Colors.orange,
                                                        width: 1.0),
                                                    borderRadius:
                                                    BorderRadius.circular(10.0),
                                                  ),
                                                  fillColor: Colors.orange,
                                                  hintText: "contoh: 10000",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        MaterialButton(
                                          height: 40,
                                          color: Colors.orange[800],
                                          minWidth: 150,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20)),
                                          onPressed: () {
                                            if (amountController.numberValue ==
                                                0) {
                                              _showDialog("Cek Nominal",
                                                  "Isi Nominal", MyHomePage());
                                            } else if (amountController
                                                .numberValue <
                                                10000 &&
                                                amountController.numberValue !=
                                                    0) {
                                              _showDialog(
                                                  "Cek Nominal",
                                                  "Minimal Transfer 10.000",
                                                  MyHomePage());
                                            } else {
                                              print(
                                                  amountController.numberValue);
                                              _transfer();
                                            }
                                          },
                                          child: const Text("Transfer"),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    // builder: (context) =>
                    //     Container(height: 100,color: Colors.blue,)
                  );
                },
                child: menus("Transfer", Icons.send),
              ),
              InkWell(
                onTap: () {
                  print("History");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()));
                },
                child: menus("Catatan Transaksi", Icons.calendar_today),
              ),
              InkWell(
                onTap: () async {
                  print("Logout");
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: menus("Logout", Icons.logout),
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 100,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage("asset/finallogo.png"))),
              )
            ]),
          ),
        ));
  }

  Widget backgroundHome(name, balance) {
    return Container(
      height: 275,
      child: Stack(
        children: [
          Container(
            child: Container(
              width: double.infinity,
              height: 150,
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
              decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60))),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome,",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          showTopModalSheet(context, top());
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 150,
                  margin: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Balance",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text("Rp $balance",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800])),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Goals",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(
                                  Icons.ac_unit,
                                  color: Colors.indigo,
                                ),
                                Icon(
                                  Icons.directions_car_sharp,
                                  color: Colors.green[900],
                                ),
                                Icon(
                                  Icons.directions_bike,
                                  color: Colors.blue[900],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget menus(nama, icon) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.orange[800],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nama,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900]),
          ),
          Icon(
            icon,
            color: Colors.grey[900],
          )
        ],
      ),
    );
  }

  Widget top() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30))),
        child: Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.top),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(80),
                          bottomLeft: Radius.circular(80)),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800]),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fname,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.orange,
                            // fontWeight: FontWeight.w600,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            //add prefix icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.orange,
                            hintText: user.firstName,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: lname,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.orange,
                            // fontWeight: FontWeight.w600,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            //add prefix icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.orange,
                            hintText: user.lastName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 80),
                    child: MaterialButton(
                      height: 40,
                      minWidth: 10,
                      color: Colors.orange[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        _updateProfile();
                      },
                      child: const Text("Update Profile"),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}