import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading_transparent.dart';
import 'package:Expense/core/models/message.dart';
import 'package:Expense/core/models/message_trail.dart';
import 'package:Expense/core/services/api.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:truncate/truncate.dart';

class MessageDetailScreen extends StatefulWidget {
  final UserMessage userMessage;
  MessageDetailScreen({Key key, @required this.userMessage}) : super(key: key);

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool _isSending = false;

  String ttl = 'Re: ';
  String msgTitle = '';
  String msgContent = '';
  String msgPriority = 'medium';
  int recepientId;
  int msgId;
  String error = '';
  var newMsg;
  var recData;
  var now = new DateTime.now();
  var curDateTime;
  var nuse;

  @override
  void initState() {
    super.initState();
    _getAllUsers();
    newMsg = widget.userMessage.id;
    // super.initState();
  }

  var senderData;
  List<String> msgTrail = [];

  // Fetch User Lists
  Future<Null> _getAllUsers() async {
    var senderItem;
    var endPoint = 'users/all';
    try {
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var mapResult = json.decode(res.body);
        var allUsersData = mapResult["data"];
        // Check if user exist in users list
        var senderId = widget.userMessage.sentBy;
        var getSenderData =
            allUsersData.where((user) => user["id"] == senderId);
        // lopp through to get avatar_id
        getSenderData.forEach((item) {
          senderItem = item;
        });
        // print(getSenderAvatarId);
        setState(() {
          senderData = senderItem;
          fetchUserMessageTrails(newMsg);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Send message to recepient
  void _sendMessageToUser() async {
    // Retrive data from API
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var userData = json.decode(userJson);
    var user = userData[0];
    var userId = user['id'];

    recepientId = widget.userMessage.sentBy;
    msgId = widget.userMessage.id;

    // if (_formKey.currentState.validate()) {
    print('sending');
    setState(() {
      _isSending = true;
    });

    var data = {
      'id': msgId,
      'msg_id': msgId,
      'user_id': userId,
      'title': ttl + widget.userMessage.title,
      'message': msgContent,
      'priority': msgPriority,
      'sent_by': userId,
      'sent_to': recepientId,
    };
    print('object sent:');

    // Make API call
    var endPoint = 'usermessages/reply/$msgId';
    var result = await CallApi().postAuthData(data, endPoint);
    print(result.statusCode);
    if (result.statusCode == 201) {
      var body = json.decode(result.body);
      var returnedData = body["data"];
      nuse = returnedData;
      setState(() {
        _isSending = false;
        _getAllUsers();
      });
      _formKey.currentState.reset();
    } else {
      setState(() {
        error = 'Authentication failed, please supply valid credential';
        _isSending = false;
      });
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Declare the field that holds the message.
    // final UserMessage userMessage = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: Theme.of(context).primaryColor,
        title: senderData != null
            ? Row(
                children: <Widget>[
                  Container(
                    width: 40.0,
                    height: 40.0,
                    margin: EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 0.0),
                    child: senderData != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(senderData['avatar_id']),
                            backgroundColor: cwhite,
                            minRadius: 30.0,
                          )
                        : Icon(Icons.person_pin),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      senderData != null
                          ? Text(
                              senderData['surname'] +
                                  ' ' +
                                  senderData['firstname'],
                            )
                          : Text('loading..'),
                      Text(
                        truncate('${widget.userMessage.title}', 30,
                            omission: '...', position: TruncatePosition.end),
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ],
              )
            : Shimmer.fromColors(
                baseColor: cwhite,
                highlightColor: credl5,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40.0,
                      height: 40.0,
                      margin: EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 0.0),
                      child: Icon(Icons.person_pin),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 160.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                              color: cgreyy,
                              borderRadius: BorderRadius.circular(25.0)),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          width: 160.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              color: cgreyy,
                              borderRadius: BorderRadius.circular(25.0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/msgbgdark.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                newMsg != null
                    ? Flexible(
                        child: FutureBuilder(
                          future: fetchUserMessageTrails(newMsg),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                            }
                            return snapshot.hasData
                                ? MessageTrailList(messageTrails: snapshot.data)
                                : LoadingTransparent();
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Text(''),
                            ),
                          ],
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: _isSending
                      ? Text(
                          'Sending message...',
                          style: TextStyle(color: cwhite, fontSize: 14),
                        )
                      : Text(''),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: cwhite,
                boxShadow: [
                  BoxShadow(
                    color: cgrey,
                    offset: Offset(-2, 0),
                    blurRadius: 5.0,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: cblack),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: 'Enter Message',
                            border: InputBorder.none),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a message';
                          } else {
                            msgContent = value;
                          }
                          return msgContent = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _sendMessageToUser,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final bool isMe;
  final String timeago;
  final String sentOn;
  final String message;

  Bubble({
    this.isMe,
    this.timeago,
    this.sentOn,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      padding:
          isMe ? EdgeInsets.only(left: 40.0) : EdgeInsets.only(right: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(timeago,
                        style: TextStyle(color: cwhite, fontSize: 12.0)),
                    Text(
                      sentOn,
                      style: TextStyle(color: cwhite, fontSize: 12.0),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                              0.1,
                              1
                            ],
                          colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFF9F9F9),
                            ])
                      : LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                              0.1,
                              1
                            ],
                          colors: [
                              Color(0xFFF9F9F9),
                              Color(0xFFFFFFFF),
                            ]),
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          topLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(0.0),
                          bottomLeft: Radius.circular(15.0),
                        )
                      : BorderRadius.only(
                          topRight: Radius.circular(15.0),
                          topLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          bottomLeft: Radius.circular(0.0),
                        ),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      message,
                      style: TextStyle(color: cblack),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageTrailList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<UserMessageTrail> messageTrails;
  // Constructor
  MessageTrailList({Key key, this.messageTrails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.rrect(
      controller: _scrollController,
      backgroundColor: cprimary,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          var msgData = messageTrails[index];
          return Bubble(
            isMe: msgData.sentBy == 1 ? true : false,
            timeago: msgData.timeago,
            sentOn: msgData.sentOn,
            message: msgData.notifDesc,
          );
        },
        itemCount: messageTrails.length,
      ),
    );
  }
}
