import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/HomePage/homepage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void login(context) {
    if (username != '' && password != '') {
      Box box = Hive.box('credentials');
      box.put('username', username);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    }
  }

  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appTopBar('simpleBTP', null),
      backgroundColor: offWhiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  getString('loginText'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, color: textColor),
                ),
                const SizedBox(height: 50),
                const Row(children: [
                  Text(
                    'Username',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                ]),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 18, color: textColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    hintText: 'Username / e-mail...',
                    hintStyle: TextStyle(fontSize: 16, color: textColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Row(children: [
                  Text(
                    'Password',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                ]),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  textInputAction: TextInputAction.go,
                  style: const TextStyle(fontSize: 18, color: textColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    hintText: 'Password...',
                    hintStyle: TextStyle(fontSize: 16, color: textColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: username != '' && password != ''
                          ? primaryColor
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        getString('loginButton'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
