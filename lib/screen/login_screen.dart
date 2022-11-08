import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oknutech/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

import '../model/api.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController passwordControl = TextEditingController();

  bool password = true;

  void _toggle() {
    setState(() {
      password = !password;
    });
  }

  Future<void> _login() async {
    print("try Login");
    try {
      _showLoading("Please Wait...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return http.post(await Env().postLogin(),
          body: jsonEncode({
            "email": emailControl.text,
            "password": passwordControl.text
          }),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }).then((response) async {
        final body = jsonDecode(response.body);
        print(body);
        if (body['status'] == 0) {
          print(body['data']['token']);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("_token", body['data']['token']);
          print("login OK");
          setState(() {
            //Navigator.pop(context);
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>MyHomePage()));
            });
          });
          print(response.body);
        }
        else if(body['status'] == 102) {
          setState(() {
            Navigator.pop(context);
          });
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  (body['message']),
                ),
                // content: Text(body['data']),
                actions: <Widget>[
                  MaterialButton(
                    child: Text('OK'),
                    textColor: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("asset/signin.png"),
                      fit: BoxFit.cover)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                child: Text(
                  "Masuk",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 40),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller:emailControl,
                    style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.alternate_email_rounded),
                      hintText: 'Email ID',
                      hintStyle: TextStyle(
                          //color: Colors.black,
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordControl,
                      style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          color: Colors.black,
                          onPressed: () {
                            setState(() {
                              _toggle();
                            });
                          },
                          icon: password
                              ? Icon(Icons.remove_red_eye_rounded, color: Colors.grey, size: 18)
                              : Icon(Icons.remove_red_eye_outlined, color: Colors.orange, size: 18),
                        ),

                        hintText: 'Password',
                        hintStyle: TextStyle(
                            //color: Colors.black,
                            fontSize: 18),
                      ),
                      obscureText: password),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal:30,vertical: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.orange[800],
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () {
                  _login();
                },
                child:  Text("Masuk",style: TextStyle(color: Colors.grey[900],fontSize: 20),),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Tidak punya akun?",
                      style: TextStyle(
                          //fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 15),
                    ),
                    TextButton(onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    }, child: Text(
                      "Daftar",
                      style: TextStyle(
                        //fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                          fontSize: 15),))
                  ],
                ),
              ),
            SizedBox(height: 40,),
            Container(
              alignment: Alignment.bottomCenter,
              height: 30,
              width: 100,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage("asset/finallogo.png"))),
            )
          ],
        ),
      ),
    ));
  }
  //Dialog Box for wait login
  void _showLoading(String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
