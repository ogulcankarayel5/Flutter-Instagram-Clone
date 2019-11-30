import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/post_model.dart';
import 'package:flutterinstagramclone/models/user_data.dart';
import 'package:flutterinstagramclone/services/database_service.dart';
import 'package:flutterinstagramclone/services/storage_service.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  TextEditingController _captureController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Add photo"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Take photo"),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              CupertinoActionSheetAction(
                child: Text("Choose from gallery"),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Add photo"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Take photo"),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Text("choose from gallery"),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);

    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      // imageFile=await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  // _cropImage(File imageFile) async{
  //   File croppedImage=await ImageCropper.cropImage(
  //     sourcePath: imageFile.path,
  //     aspectRatio: CropAspectRatio(ratioX: 1.0,ratioY: 1.0),
  //   );

  //   return croppedImage;
  // }

  _submit() async {
    if (!_isLoading && _image != null && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      //create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likes: {},
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );

      DatabaseService.createPost(post);
      //reset data

      _captureController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Crete Post ',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _submit,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _isLoading
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.blue[200],
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    )
                  : SizedBox.shrink(),
              GestureDetector(
                onTap: _showSelectImageDialog,
                child: Container(
                  height: width,
                  width: width,
                  color: Colors.grey[300],
                  child: _image == null
                      ? Icon(
                          Icons.add_a_photo,
                          color: Colors.white70,
                          size: 150.0,
                        )
                      : Image(
                          image: FileImage(_image),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _captureController,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                  decoration: InputDecoration(
                    labelText: "Caption",
                  ),
                  onChanged: (input) => _caption = input,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
