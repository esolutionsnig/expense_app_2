import 'dart:io';
import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

class DisplayPictureScreen extends StatefulWidget {
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final uploader = FlutterUploader();
  final _formKey = GlobalKey<FormState>();

  // Active image file
  File _imageFile;

  int userId;

  String success = '';
  String error = '';
  bool loading = false;
  bool editImage = false;
  var fn;
  double percentCount = 0.0;
  String pcCount;
  bool _isUploading = false;

  var userData;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    if (this.mounted) {
      setState(() {
        userData = user[0];
        userId = userData['id'];
      });
    }
  }

  // Switch between edit and view profile
  void _manageProfile() {
    if (editImage) {
      setState(() {
        editImage = false;
      });
    } else {
      if (this.mounted) {
        setState(() {
          editImage = true;
        });
      }
    }
  }

  // Crop Image
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: corange,
            toolbarWidgetColor: cwhite,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (this.mounted) {
      setState(() {
        _imageFile = cropped ?? _imageFile;
      });
    }
  }

  // Remove image
  void _clear() {
    if (this.mounted) {
      setState(() {
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'DISPLAY PICTURE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                editImage
                    ? RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).accentColor,
                        ), //`Icon` to display
                        label: Text(
                          'Close'.toUpperCase(),
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ), //`Text` to display
                        onPressed: _manageProfile,
                      )
                    : RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).accentColor,
                        ), //`Icon` to display
                        label: Text(
                          'Edit'.toUpperCase(),
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ), //`Text` to display
                        onPressed: _manageProfile,
                      ),
              ],
            ),
          ),
          editImage
              ? Form(
                  key: _formKey,
                  autovalidate: true,
                  child: profileFormInterface(),
                )
              : userData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: success != ''
                              ? Text(
                                  success,
                                  style: TextStyle(color: cteal),
                                )
                              : Text(''),
                        ),
                        Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.network(
                            userData['avatar_id'],
                            fit: BoxFit.fill,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                          'Click the edit button to update profile display image.'),
                    ),
        ],
      ),
    );
  }

  // Form User Interface
  Widget profileFormInterface() {
    return _isUploading
        ? Loading()
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _imageFile == null
                        ? Text('Select an image to upload')
                        : Image.file(_imageFile),
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cwhite,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Choose from gallery',
                          icon: Icon(
                            Icons.photo_library,
                            size: 30,
                          ),
                          onPressed: () => _takePhoto(ImageSource.gallery),
                        ),
                        if (_imageFile != null) ...[
                          IconButton(
                            tooltip: 'Clear selected image',
                            icon: Icon(
                              Icons.cancel,
                              size: 30,
                            ),
                            onPressed: () => _clear(),
                          ),
                          IconButton(
                            tooltip: 'Clear selected image',
                            icon: Icon(
                              Icons.crop,
                              size: 30,
                            ),
                            onPressed: () => _cropImage(),
                          ),
                          IconButton(
                            tooltip: 'Upload and save changes',
                            icon: Icon(
                              Icons.cloud_upload,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => getUploadImg(_imageFile),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: error != ''
                      ? Text(
                          error,
                          style: TextStyle(color: cred),
                        )
                      : Text(''),
                ),
              ],
            ),
          );
  }

  // New Way
  void getUploadImg(_image) async {
    setState(() {
      _isUploading = true;
    });

    // Get Token
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var tokenJson = localStorage.getString('token');
    var token = json.decode(tokenJson);

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token
    };

    if (_image == null) {
      setState(() {
        _isUploading = false;
      });
    } else {
      //================== form data =====================

      var dio = Dio();
      dio.options.headers = headers;
      Response response;
      var a;
      var d;

      String ep = CallApi().getBaseUrl();
      String endPoint = "profiles/user/$userId/upload-image";

      try {
        Future<FormData> formData() async {
          return FormData.fromMap({
            "avatar": await MultipartFile.fromFile(_imageFile.path,
                filename: "upload.txt")
          });
        }

        response = await dio.post(
          ep + endPoint,
          data: await formData(),
          onSendProgress: (received, total) {
            if (total != -1) {
              a = received / total;
              d = a * 100;
              percentCount = a;
              pcCount = d.toStringAsFixed(0) + "%";
            }
          },
        );
        if (response.statusCode == 201) {
          _getNewUserInfo();
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        print('error: $e');
      }

      // ====================end==========================

    }
  }

  // Take Photo
  Future _takePhoto(ImageSource source) async {
    var selectedFile = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = selectedFile;
    });
  }

  // Get Updaed User Info
  void _getNewUserInfo() async {
    // Make API call
    var result = await CallApi().getAuthData('getUser');
    var body = json.decode(result.body);
    if (result.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('user', json.encode(body['data']));
      _getUserInfo();
      setState(() {
        success = 'Profile successfully updated';
        _isUploading = false;
        editImage = false;
      });
    } else {
      setState(() {
        _isUploading = false;
        editImage = false;
      });
    }
  }
}
