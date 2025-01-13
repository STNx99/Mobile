
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:project_mobile/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../models/message.dart';
class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  List<Message> list=[];

  final _textController = TextEditingController();

  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus,
      child: SafeArea(
        child: PopScope(
          canPop: !_showEmoji,
          onPopInvokedWithResult: (disposition, result) {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              log('Chế độ tìm kiếm đã bị vô hiệu hóa.');
            } else {
              log('Cho phép hành động bật ra.');
            }
          },

          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(children: [
              Expanded(
                child: StreamBuilder(
                   stream: APIS.getAllMessages(widget.user),
                  builder: (context,snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
          
                         list = data?.map((e)=>Message.fromJson(e.data())).toList()??[];
                      // final list = ['hi','Hello'];
                      //   list.add(Message(toId: 'zzz', msg: 'hihi', read: '1', type: Type.text, fromId: APIS.user.uid, sent: '12h25'));
                      //   list.add(Message(toId: APIS.user.uid, msg: 'hihi123', read: '11', type: Type.text, fromId: 'text2', sent: '12h22'));
                        if(list.isNotEmpty){
                          return ListView.builder(
                              itemCount:  list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                 return MessageCard(message: list[index]);
                              });
                        }else{
                          return const Center(child: Text('Gửi lời chào. 👋',style: TextStyle(fontSize: 30),));
                        }
                    }
                  }
                )
              ),
          
              _chatInput(),
          
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: const Config(),
                  ),
                )
          
          
          
          
            ],),
          ),
        ),
      ),
    );
  }
  Widget _appBar(){
    return InkWell(
      onTap:(){},
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black54
            )),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.3),
            child: CachedNetworkImage(
      
              width: mq.height * .05,
              height: mq.height * .05,
              imageUrl: widget.user.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
      
          const SizedBox(width: 10),
      
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(widget.user.name, style: const TextStyle(fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
              const SizedBox(width: 2),
              const Text('Lần cuối nhìn thấy không có sẵn.', style: TextStyle(fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500))
          ],)
        ],
      ),
    );
  }
  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * .01,horizontal: mq.width*.03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                //
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(()=>_showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      size: 25,
                    )),
                Expanded(child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onTap: (){
                    if(_showEmoji) setState(() => _showEmoji = !_showEmoji);
                  },
                  decoration: const InputDecoration(hintText: 'Đang gõ văn bản....',
                      hintStyle: TextStyle(color: Colors.blueAccent)
                  ),
                )),

                IconButton(
                    onPressed: () {

                    },
                    icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent
                    )),

                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent
                    )),
              ],),
            ),
          ),

          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              APIS.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text='';
            }
          } ,
            minWidth: 0,
            shape: const CircleBorder(),
            padding: const EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 5),
            color: Colors.green,
            child: const Icon(Icons.send,color: Colors.white,size: 28),)
        ],
      ),
    );
  }
}

