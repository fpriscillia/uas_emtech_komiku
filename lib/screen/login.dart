import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emtech_comic/screen/register.dart';
import '../main.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  String _user_id = "";
  String _user_password = "";
  String _error_login = "";

  void doLogin() async {
    final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/login.php"),
        body: {'user_id': _user_id, 'user_password': _user_password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", _user_id);
        prefs.setString("user_name", json['user_name']);
        main();
      } else {
        setState(() {
          _error_login = "Incorrect user or password";
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Center(
          child: Text(
            "KOMIKU",
            style: TextStyle(
              fontSize: 48,
              color: Colors.deepPurple,
              fontFamily: "Arial",
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30),
          child: TextField(
            onChanged: (v) {
              _user_id = v;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'User ID',
                hintText: 'Masukkan user id Anda'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: TextField(
            onChanged: (v) {
              _user_password = v;
            },
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Masukkan password'),
          ),
        ),
        if (_error_login != "")
          Text(
            _error_login,
            style: TextStyle(color: Colors.red),
          ),
        Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Container(
              height: 50,
              width: 340,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  doLogin();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            )),
        Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Container(
              height: 50,
              width: 340,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
                },
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            )),
        SizedBox(
          height: 100,
        ),
        Text(
          "Project by \n160721036 - Trevin Terrence Timisela \n160721022 - Fransisca Priscillia",
          style: TextStyle(color: Colors.black54),
        )
      ]),
    ));
  }
}
