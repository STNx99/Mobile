import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:project_mobile/helper/my_date_util.dart';
import 'package:project_mobile/models/message.dart';

import '../api/apis.dart';
import '../main.dart';


// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIS.user.uid == widget.message.fromId
        ? _greenMessage() : _blueMessage();
  }
  Widget _blueMessage() {

    if(widget.message.read.isNotEmpty){
      APIS.updateMessageReadStatus(widget.message);
      log('cập nhật tin nhắn đã đọc');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04 ,vertical: mq.height*.01
            ),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 221, 245, 255),
            border: Border.all(color: Colors.lightBlue),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                )
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15,color: Colors.black87),
            ),
          ),
        ),
    Row(
      children: [
        Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),

        Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13,color: Colors.black54)),
      ],
    ),
      ],
    );
  }
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [
            SizedBox(width: mq.width*.04,),

            if(widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
            SizedBox(width: 2,),
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13,color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04 ,vertical: mq.height*.01
            ),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 221, 245, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)
                )
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15,color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }


}