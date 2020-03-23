// import 'dart:convert';

// import 'package:draggable_scrollbar/draggable_scrollbar.dart';
// import 'package:flutter/material.dart';
// import 'package:icms_expense_app/UI/shared/color.dart';
// import 'package:icms_expense_app/UI/views/message/message_detail.dart';
// import 'package:icms_expense_app/UI/views/message/sent_message_detail.dart';
// import 'package:icms_expense_app/core/models/notifcation.dart';
// import 'package:icms_expense_app/core/models/user_message.dart';
// import 'package:icms_expense_app/core/models/user_sent_message.dart';
// import 'package:icms_expense_app/core/services/api.dart';
// import 'package:truncate/truncate.dart';

// class MessageScreen extends StatefulWidget {
//   @override
//   _MessageScreenState createState() => _MessageScreenState();
// }

// class _MessageScreenState extends State<MessageScreen> {
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();

//   final _scaffoldKey = new GlobalKey<ScaffoldState>();
//   VoidCallback _showMeesageSheetCallBack;

//   final _formKey = GlobalKey<FormState>();

//   String pageAppTitle = 'Messages';
//   String tab1 = "All Messages";
//   String tab2 = "Sent Messages";

//   @override
//   void initState() {
//     super.initState();
//     _showMeesageSheetCallBack = _showMessageSheet;
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
//   }

//   void _showMessageSheet() {
//     setState(() {
//       _showMeesageSheetCallBack = null;
//     });

//     _scaffoldKey.currentState
//         .showBottomSheet((context) {
//           return Container(
//             height: 350.0,
//             padding: const EdgeInsets.all(10.0),
//             decoration: BoxDecoration(
//               color: clitegrey,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(25.0),
//                   topRight: Radius.circular(25.0)),
//             ),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               elevation: 5.0,
//               child: Container(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.only(top: 16.0, bottom: 4.0),
//                       child: Text('Send new message'),
//                     ),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: TextFormField(
//                               decoration: InputDecoration(
//                                 labelText: 'Choose recepient',
//                                 hintText:
//                                     'Select whom you are sending this message to',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value.isEmpty) {
//                                   return 'Please enter something';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8.0),
//                             child: TextFormField(
//                               maxLines: 2,
//                               decoration: InputDecoration(
//                                 labelText: 'Message content',
//                                 hintText:
//                                     'Enter your message here',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(6.0),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value.isEmpty) {
//                                   return 'Please enter something';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12.0),
//                             child: FlatButton(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30.0)),
//                               splashColor: caccent,
//                               color: cprimary,
//                               disabledColor: cdisabled,
//                               child: Row(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 20.0),
//                                     child: Text(
//                                       'SEND MESSAGE',
//                                       style: TextStyle(color: cwhite),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Container(),
//                                   ),
//                                   Transform.translate(
//                                     offset: Offset(15.0, 0.0),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: FlatButton(
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(28.0),
//                                         ),
//                                         splashColor: caccent,
//                                         color: cwhite,
//                                         child: Icon(
//                                           Icons.send,
//                                           color: cprimary,
//                                         ),
//                                         onPressed: () async {
//                                           // _handleSignIn();
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               onPressed: () async {
//                                 // _handleSignIn();
//                               },
//                             ),
//                             // child: RaisedButton(
//                             //   onPressed: () {
//                             //     // Validate returns true if the form is valid, or false
//                             //     if (_formKey.currentState.validate()) {
//                             //       // if the form is valid, display a snackbar
//                             //       Scaffold.of(context).showSnackBar(SnackBar(
//                             //         content: Text('Processing Data'),
//                             //       ));
//                             //     }
//                             //   },
//                             //   child: Text('Seend Message'),
//                             // ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         })
//         .closed
//         .whenComplete(() {
//           if (mounted) {
//             setState(() {
//               _showMeesageSheetCallBack = _showMessageSheet;
//             });
//           }
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       body: DefaultTabController(
//         length: 2,
//         child: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               SliverAppBar(
//                 expandedHeight: 200.0,
//                 floating: false,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                     centerTitle: true,
//                     title: Text(pageAppTitle,
//                         style: TextStyle(
//                           color: cwhite,
//                           fontSize: 20.0,
//                         )),
//                     background: Image.asset(
//                       "assets/messageheader.png",
//                       fit: BoxFit.cover,
//                     )),
//               ),
//               SliverPersistentHeader(
//                 delegate: _SliverAppBarDelegate(
//                   TabBar(
//                     indicatorColor: cprimary,
//                     labelColor: cprimary,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: [
//                       Tab(icon: Icon(Icons.move_to_inbox), text: tab1),
//                       Tab(icon: Icon(Icons.inbox), text: tab2),
//                     ],
//                   ),
//                 ),
//                 pinned: true,
//               ),
//             ];
//           },
//           body: RefreshIndicator(
//             key: _refreshIndicatorKey,
//             onRefresh: fetchNotifcations,
//             child: TabBarView(
//               children: <Widget>[AllMessages(), SentMessages()],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: FloatingActionButton(
//           onPressed: () {
//             _showMeesageSheetCallBack();
//           },
//           backgroundColor: cwhite,
//           child: Icon(
//             Icons.message,
//             color: cprimary,
//             size: 30.0,
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);

//   final TabBar _tabBar;

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return new Container(
//       decoration: BoxDecoration(color: cwhite),
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }

// // Sent Messages
// class SentMessages extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(color: clitegrey),
//       child: FutureBuilder(
//         future: fetchUserSentMessages(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print(snapshot.error);
//           }
//           return snapshot.hasData
//               ? UserSentMessageList(userSentMessages: snapshot.data)
//               : Center(
//                   child: CircularProgressIndicator(),
//                 );
//         },
//       ),
//     );
//   }
// }

// // All Messages
// class AllMessages extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(color: clitegrey),
//       child: FutureBuilder(
//         future: fetchUserMessages(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print(snapshot.error);
//           }
//           return snapshot.hasData
//               ? UserMessageList(userMessages: snapshot.data)
//               : Center(
//                   child: CircularProgressIndicator(),
//                 );
//         },
//       ),
//     );
//   }
// }

// // Message List
// class UserMessageList extends StatelessWidget {
//   ScrollController _scrollController = ScrollController();
//   final List<UserMessage> userMessages;
//   // Constructor
//   UserMessageList({Key key, this.userMessages}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollbar.rrect(
//       controller: _scrollController,
//       backgroundColor: cprimary,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemBuilder: (context, index) {
//           var msgData = userMessages[index];
//           return GestureDetector(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: msgData.is_read == 'YES' ? cwhite : Colors.transparent,
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
//                 child: msgData != null
//                     ? ListTile(
//                         leading: Column(
//                           children: <Widget>[
//                             Icon(
//                               Icons.star_border,
//                               size: 35.0,
//                               color: msgData.priority == 'low'
//                                   ? clow
//                                   : msgData.priority == 'medium'
//                                       ? cmedium
//                                       : chigh,
//                             ),
//                             Text(
//                               msgData.priority,
//                               style: TextStyle(fontSize: 12.0, color: cgrey),
//                             ),
//                           ],
//                         ),
//                         title: Text('${msgData.title}'),
//                         subtitle: Text(
//                           truncate(msgData.notif_desc, 50,
//                               omission: '...', position: TruncatePosition.end),
//                           style: TextStyle(fontSize: 12.0, color: cgrey),
//                         ),
//                         trailing: Text(
//                           '${msgData.timeago}',
//                           style: TextStyle(fontSize: 12.0, color: cgrey),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   MessageDetailScreen(userMessage: msgData),
//                               // Pass the arguments as part of the RouteSettings.
//                               // settings: RouteSettings(
//                               //   arguments: msgData
//                               // ),
//                             ),
//                           );
//                         },
//                       )
//                     : '',
//               ),
//             ),
//           );
//         },
//         itemCount: userMessages.length,
//       ),
//     );
//   }
// }

// // Sent Message List
// class UserSentMessageList extends StatelessWidget {
//   ScrollController _scrollController = ScrollController();
//   final List<UserSentMessage> userSentMessages;
//   // Constructor
//   UserSentMessageList({Key key, this.userSentMessages}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollbar.rrect(
//       controller: _scrollController,
//       backgroundColor: cprimary,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemBuilder: (context, index) {
//           var msgData = userSentMessages[index];
//           return GestureDetector(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: msgData.is_read == 'YES' ? cwhite : Colors.transparent,
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
//                 child: msgData != null
//                     ? ListTile(
//                         leading: Column(
//                           children: <Widget>[
//                             Icon(
//                               Icons.star_border,
//                               size: 35.0,
//                               color: msgData.priority == 'low'
//                                   ? clow
//                                   : msgData.priority == 'medium'
//                                       ? cmedium
//                                       : chigh,
//                             ),
//                             Text(
//                               msgData.priority,
//                               style: TextStyle(fontSize: 12.0, color: cgrey),
//                             ),
//                           ],
//                         ),
//                         title: Text('${msgData.title}'),
//                         subtitle: Text(
//                           truncate(msgData.notif_desc, 50,
//                               omission: '...', position: TruncatePosition.end),
//                           style: TextStyle(fontSize: 12.0, color: cgrey),
//                         ),
//                         trailing: Text(
//                           '${msgData.timeago}',
//                           style: TextStyle(fontSize: 12.0, color: cgrey),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SentMessageDetailScreen(
//                                   userSentMessage: msgData),
//                             ),
//                           );
//                         },
//                       )
//                     : '',
//               ),
//             ),
//           );
//         },
//         itemCount: userSentMessages.length,
//       ),
//     );
//   }
// }
