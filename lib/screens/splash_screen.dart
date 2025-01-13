import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_mobile/api/apis.dart';
import 'package:project_mobile/screens/auth/login_screen.dart';
import 'package:project_mobile/screens/home_screen.dart';
import '../main.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));

      //navigate
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => APIS.auth.currentUser != null
                ? const HomeScreen()
                : const LoginScreen(),
          ));
    });
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chào mừng đến với Chat'),
      ),

      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            right:  mq.width * .25 ,
            width: mq.width * .5,
            child: Image.asset('images/logoChat.png')
        ),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width * .9,
            child: Text(
              'Project Mobile',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                     color: Colors.black87,
                  letterSpacing: .05
              ),
            )
        )
      ],
      ),
    );
  }
}
