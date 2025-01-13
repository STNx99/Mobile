import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_mobile/api/apis.dart';
import 'package:project_mobile/screens/home_screen.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isAnimate = false;


  void initSate(){
    super.initState();
    Future.delayed(const Duration(microseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick(){
    Dialogs.showLoading(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user!=null){
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if((await APIS.userExitsts())){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        }else{
          await APIS.createUser().then((value){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });

  }

  // _handleFaceBookBtnClick(){
  //   _signInWithFaceBook().then((user) {
  //     log('\nUser: ${user.user}');
  //     log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (_) => const HomeScreen()));
  //   });
  // }

  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIS.auth.signInWithCredential(credential);
    } catch(e){
      log('\nSignInwithGoogle: $e');
      Dialogs.showSnackbar(context,'Something went wrong (check internet!)');
      return null;
    }

  }

  // Future<UserCredential> _signInWithFaceBook() async {
  //   // Trigger the sign-in flow
  //   final LoginResult loginResult = await FacebookAuth.instance.login();
  //
  //   // Create a credential from the access token
  //   final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
  //
  //   // Once signed in, return the UserCredential
  //   return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Welcome to Chat'),
        ),

      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/logoChat.png')
        ),
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .1,
            width: mq.width * .8,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white60,
                  shape: const StadiumBorder(),
                  elevation: 1
              ),
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset('images/google.png', height: mq.height * .03,),
              label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(text: 'Đăng nhập bằng '),
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w500)
                      ),
                    ]
                  )
              )
            ),
        ),
        // SizedBox(height: 5),
        // Positioned(
        //   bottom: mq.height * .15,
        //   left: mq.width * .1,
        //   width: mq.width * .9,
        //   height: mq.height * .07,
        //   child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.white60,
        //           shape: const StadiumBorder(),
        //           elevation: 1
        //       ),
        //       onPressed: () {
        //         // _handleFaceBookBtnClick();
        //       },
        //       icon: Image.asset('images/facebook.png', height: mq.height * .03,),
        //       label: RichText(
        //           text: const TextSpan(
        //               style: TextStyle(color: Colors.black, fontSize: 16),
        //               children: [
        //                 TextSpan(text: 'Login with '),
        //                 TextSpan(
        //                     text: 'FaceBook',
        //                     style: TextStyle(fontWeight: FontWeight.w500)
        //                 ),
        //               ]
        //           )
        //       )
        //   ),
        // ),
        ],
      ),
    );
  }
}
