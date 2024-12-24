import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String errorMessage = "";

  void _register() async {
    final userId = userIdController.text;
    final userName = userNameController.text;
    final password = passwordController.text;

    final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/register.php"),
        body: {'user_id': userId, 'user_name':userName, 'password': password});
    if (response.statusCode == 200) {
        setState(() {
          errorMessage = "Berhasil";
        });
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "REGISTER AKUN KOMIKU",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.deepPurple,
                    fontFamily: "Arial",
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User ID',
                    hintText: 'Masukkan user id Anda',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                    hintText: 'Masukkan nama pengguna Anda',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Masukkan password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Konfirmasi Password',
                    hintText: 'Masukkan kembali password',
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  height: 50,
                  width: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: _register,
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              const Text(
                "Project by: 160721036 160721022",
                style: TextStyle(color: Colors.black54),
              )
            ],
          ),
        ),
      ),
    );
  }
}

