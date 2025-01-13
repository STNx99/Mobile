
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mobile/api/apis.dart';
import 'package:project_mobile/models/chat_user.dart';
import 'package:project_mobile/screens/auth/login_screen.dart';
import 'package:project_mobile/widgets/chat_user_card.dart';
import 'dart:developer';

import '../helper/dialogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user, });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(

          title: const Text('Hồ sơ cá nhân'),

        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              // Hiển thị hộp thoại xác nhận
              bool confirmLogout = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Xác nhận"),
                    content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false); // Hủy bỏ
                        },
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true); // Xác nhận
                        },
                        child: const Text("Đăng xuất"),
                      ),
                    ],
                  );
                },
              );
              // Nếu người dùng xác nhận
              if (confirmLogout == true) {
                Dialogs.showLoading(context);
                await APIS.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context); // Đóng loading dialog
                    Navigator.pop(context); // Đóng màn hình hiện tại
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  });
                });
              }
            },
              icon: const Icon(Icons.logout),
              label: Text('Đăng xuất'),
          ),

        ),
        //body
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width,height: mq.height*.03,),


                  Stack(
                    children: [
                      _image!=null
                      ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height*.1),
                    child: Image.file(
                    File(_image!),
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit:BoxFit.fill,),)
                  :
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height*.1),
                        child: CachedNetworkImage(
                          width: mq.height * .2,
                          height: mq.height * .2,
                          fit:BoxFit.fill,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                         right: 0,
                         child: MaterialButton(
                           elevation: 1,
                            onPressed: (){
                             _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit),
              
                          )
                      )
              
                    ],
                  ),
                  SizedBox(height: mq.height*.03),
              
                  Text(widget.user.email,style:  const TextStyle(color: Colors.black54,fontSize: 25)),
                  SizedBox(height: mq.height*.05),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIS.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null :'Trường bắt buộc',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'eg. phi',
                      label: const Text('Name')
                    ),
                  ),
                  SizedBox(height: mq.height*.02),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIS.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null :'Trường bắt buộc',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline,color: Colors.blue,),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg. phi',
                        label: const Text('Về')
                    ),
                  ),
              
                  SizedBox(height: mq.height*.03),
              
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder(), minimumSize: Size(mq.width*.5,mq.height*.055)),
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        APIS.updateUserInfo().then((value){
                          Dialogs.showSnackbar(context, 'Đã cập nhật hồ sơ thành công!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit,size: 30,),
                    label: const Text('Cập nhật',style: TextStyle(fontSize: 16)
                      ,)
                    ,)
              
              
                ],),
            ),
          ),
        )
    );
  }
  void _showBottomSheet(){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
        builder: (_) {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height* .03,bottom: mq.height*.05),
        children: [
          const Text('Chọn Ảnh Hồ Sơ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: mq.height*.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                fixedSize: Size(mq.width*.3, mq.height*.15)
              ),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if(image!=null){
                  log('image path:${image.path} -- MimeType:${image.mimeType}');
                  setState(() {
                    _image = image.path;
                  });
                  Navigator.pop(context);

                }
              },
              child: Image.asset(
            'images/add_image.png')),

              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width*.3, mq.height*.15)
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if(image!=null){
                      log('image path:${image.path}');
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);

                    }
                  },
                  child: Image.asset(
                      'images/camera.jpg'))
          ],)
        ],
      );
    });
  }
}
