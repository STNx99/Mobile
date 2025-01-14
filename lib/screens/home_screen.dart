
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_mobile/api/apis.dart';
import 'package:project_mobile/models/chat_user.dart';
import 'package:project_mobile/screens/profile_screen.dart';
import 'package:project_mobile/widgets/chat_user_card.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState(){
    super.initState();
    APIS.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: !_isSearching,
          onPopInvokedWithResult: (disposition, result) {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              log('Chế độ tìm kiếm đã bị vô hiệu hóa.');
            } else {
              log('Cho phép hành động bật ra.');
            }
          },

        child: Scaffold(
            appBar: AppBar(
              leading: const Icon(Icons.home),
              title: _isSearching?
                  TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,hintText: 'Tên, Email, ...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 16,letterSpacing: 0.5),
                    onChanged: (val){
                      //logic
                      _searchList.clear();
                      for(var i in list){
                        if(i.name.toLowerCase().contains(val.toLowerCase())||
                            i.email.toLowerCase().contains(val.toLowerCase())){
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                  :
              const Text('Chat'),
              actions: [
                IconButton(onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                    icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid
                    :Icons.search)),
                IconButton(onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (_) => ProfileScreen(user:APIS.me)));
                }, icon: const Icon(Icons.person_2_outlined))
              ],
            ),
            //body
            body: StreamBuilder(
              stream: APIS.getAllUsers(),
               builder: (context,snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    list = data?.map((e)=>ChatUser.fromJson(e.data())).toList()??[];
                    if(list.isNotEmpty){
                      return ListView.builder(
                          itemCount:_isSearching? _searchList.length :  list.length,
                          padding: EdgeInsets.only(top: mq.height * .01),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(user: _isSearching? _searchList[index] :list[index],);
                            // return Text('Name: ${list[index]}');
                          });
                    }else{
                      return const Center(child: Text('Không có kết nối',style: TextStyle(fontSize: 30),));
                    }
                }
               },
              ),
        ),
      ),
    );
  }
}
