import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:project_mobile/models/chat_user.dart';
import 'package:project_mobile/models/message.dart';

import 'notification_access_token.dart';

class APIS {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Check user
  static User get user => auth.currentUser!;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // Request FCM token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, // Your name
            "body": msg,
          },
          "android": {
            "priority": "high",
            "notification": {
              "sound": "default",
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "alert": {
                  "title": me.name,
                  "body": msg,
                },
                "sound": "default",
              }
            }
          },
        }
      };

      const projectID = 'chat-ab619';

      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // Handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }


static late ChatUser me;
  static Future<bool> userExitsts() async{
    return (await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get())
        .exists;
  }

  static Future<void> getSelfInfo() async{
     await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
        if(user.exists){
          me = ChatUser.fromJson(user.data()!);
          await getFirebaseMessagingToken();

          APIS.updateActiveStatus(true);
          log('My data: ${user.data()}');
        }else{
          await createUser().then((value)=> null);
        }
     });
  }
  //create user
  static Future<void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: auth.currentUser!.displayName.toString(),
      email: user.email.toString(),
      about: "Chào. Tôi đang dùng chat",
      image:user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }
  //get all user from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>>  getAllUsers(){
    return firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }
  //get update infor user
  static Future<void> updateUserInfo() async{
     await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
          'name':me.name,
          'about':me.about,
     });
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';


  static Stream<QuerySnapshot<Map<String, dynamic>>>  getAllMessages(
      ChatUser user
      ){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser,String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message =
    Message(toId: chatUser.id,
        msg: msg, read: '', type: type,
        fromId: user.uid, sent: time);

    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
   await  ref.doc(time).set(message.toJson()).then((value) =>
       sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore.collection('chats/${getConversationID(message.fromId)}/messages/').doc(message.sent).update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }
  static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent',descending: true)
        .limit(1).snapshots();
  }
}