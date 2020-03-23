import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/message_trail.dart';
import 'package:Expense/core/models/user_sent_message.dart';
import 'package:Expense/core/services/api.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SentMessageDetailScreen extends StatefulWidget {
  final UserSentMessage userSentMessage;
  SentMessageDetailScreen({Key key, @required this.userSentMessage}) : super(key: key);

  @override
  _SentMessageDetailScreenState createState() => _SentMessageDetailScreenState();
}

class _SentMessageDetailScreenState extends State<SentMessageDetailScreen> {

  @override
  void initState() {
    // super.initState();
    _getAllUsers();
    super.initState();
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
        var senderId = widget.userSentMessage.sentBy;
        var getSenderData =
            allUsersData.where((user) => user["id"] == senderId);
        // lopp through to get avatar_id
        getSenderData.forEach((item) {
          senderItem = item;
        });
        // print(getSenderAvatarId);
        setState(() {
          senderData = senderItem;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        '${widget.userSentMessage.title}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ],
              )
            : Shimmer.fromColors(
                baseColor: cwhite,
                highlightColor: cluegreylite,
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
                              color: cgrey,
                              borderRadius: BorderRadius.circular(25.0)),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          width: 160.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              color: cgrey,
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
                Flexible(
                  child: FutureBuilder(
                    future: fetchUserMessageTrails(widget.userSentMessage.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                      }
                      return snapshot.hasData
                          ? MessageTrailList(messageTrails: snapshot.data)
                          : Loading();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
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
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: cblack),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'Enter Message', border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () {},
                  ),
                ],
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
            isMe: msgData.sentBy == 1 
            ? true : false,
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
