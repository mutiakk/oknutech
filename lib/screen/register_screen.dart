import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/api.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController firstControl = TextEditingController();
  TextEditingController lastControl = TextEditingController();
  TextEditingController passwordControl = TextEditingController();

  Future<void> _login() async {
    print("try Login");
    try {
      _showLoading("Please Wait...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return http.post(await Env().postRegist(),
          body: jsonEncode({
            "email": emailControl.text,
            "password": passwordControl.text,
            "first_name": firstControl.text,
            "last_name": lastControl.text
          }),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }).then((response) async {
        final body = jsonDecode(response.body);
        print(body);
        if (body['status'] == 0) {
          print("login OK");
          setState(() {
            _showDialog("Sukses", body["message"], LoginScreen());

            //Navigator.pop(context);

          });
          print(response.body);
        }
        else if(body['status'] == 103) {
          setState(() {
            Navigator.pop(context);
          });
          _showDialog("Cek Email Anda", body["message"], RegisterScreen());
        }else{
          _showDialog("Error", body["message"], RegisterScreen());
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  height: 300,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("asset/signup.png"),
                          fit: BoxFit.cover)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                    child: Text(
                      "Daftar",
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
                        controller:firstControl,
                        style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: 'First Name',
                          labelText: 'First Name',
                          hintStyle: TextStyle(
                            //color: Colors.black,
                              fontSize: 15,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller:lastControl,
                        style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: 'Last Name',
                          labelText: 'Last Name',
                          hintStyle: TextStyle(
                            //color: Colors.black,
                              fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          EmailValidator(errorText: "Email tidak valid"),
                        ]),
                        controller:emailControl,
                        style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.alternate_email_rounded),
                          hintText: 'Email ID',
                          labelText: 'Email',
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
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.lock),
                            labelText: 'Password',
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              //color: Colors.black,
                                fontSize: 18),
                          ),
                          obscureText: true),
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
                    child:  Text("Daftar",style: TextStyle(color: Colors.grey[900],fontSize: 20),),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun?",
                        style: TextStyle(
                          //fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 15),
                      ),
                      TextButton(onPressed: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      }, child: Text(
                        "Masuk",
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
}
