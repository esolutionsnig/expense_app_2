import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/views/Message/message_detail.dart';
import 'package:Expense/UI/views/Message/my_contacts.dart';
import 'package:Expense/UI/views/Message/sent_message_detail.dart';
import 'package:Expense/core/models/message.dart';
import 'package:Expense/core/models/user_sent_message.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:truncate/truncate.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String appPageName = 'Messages';
  String tab1 = "All Messages";
  String tab2 = "Sent Messages";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(appPageName,
                        style: TextStyle(
                          fontSize: 20.0,
                        )),
                    background: Image.asset(
                      "assets/messageheader.png",
                      fit: BoxFit.cover,
                    )),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.move_to_inbox), text: tab1),
                      Tab(icon: Icon(Icons.inbox), text: tab2),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchUserMessages,
            child: TabBarView(
              children: <Widget>[AllMessages(), SentMessages()],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyContactScreen()
              ),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.message,
            color: cwhite,
            size: 30.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      decoration: BoxDecoration(color: Theme.of(context).accentColor),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Sent Messages
class SentMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: FutureBuilder(
        future: fetchUserSentMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? UserSentMessageList(userSentMessages: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

// All Messages
class AllMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: FutureBuilder(
        future: fetchUserMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? UserMessageList(userMessages: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

// Message List
class UserMessageList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<UserMessage> userMessages;
  // Constructor
  UserMessageList({Key key, this.userMessages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.rrect(
      controller: _scrollController,
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          var msgData = userMessages[index];
          return GestureDetector(
            child: Container(
              margin: EdgeInsets.only(bottom: 5.0),
              decoration: BoxDecoration(
                color: msgData.isRead == 'YES' ? creadmsg : cunreadmsg,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: msgData != null
                    ? ListTile(
                        leading: Column(
                          children: <Widget>[
                            Icon(
                              Icons.star_border,
                              size: 35.0,
                              color: msgData.priority == 'low'
                                  ? clow
                                  : msgData.priority == 'medium'
                                      ? cmedium
                                      : chigh,
                            ),
                            Text(
                              msgData.priority,
                              style: TextStyle(fontSize: 12.0, color: cgrey),
                            ),
                          ],
                        ),
                        title: Text('${msgData.title}', style: TextStyle(color: cblack),),
                        subtitle: Text(
                          truncate(msgData.notifDesc, 50,
                              omission: '...', position: TruncatePosition.end),
                          style: TextStyle(fontSize: 12.0, color: cgrey),
                        ),
                        trailing: Text(
                          '${msgData.timeago}',
                          style: TextStyle(fontSize: 12.0, color: cgrey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MessageDetailScreen(userMessage: msgData),
                            ),
                          );
                        },
                      )
                    : '',
              ),
            ),
          );
        },
        itemCount: userMessages.length,
      ),
    );
  }
}

// Sent Message List
class UserSentMessageList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<UserSentMessage> userSentMessages;
  // Constructor
  UserSentMessageList({Key key, this.userSentMessages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.rrect(
      controller: _scrollController,
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          var msgData = userSentMessages[index];
          return GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: msgData.isRead == 'YES' ? creadmsg : cunreadmsg,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: msgData != null
                    ? ListTile(
                        leading: Column(
                          children: <Widget>[
                            Icon(
                              Icons.star_border,
                              size: 35.0,
                              color: msgData.priority == 'low'
                                  ? clow
                                  : msgData.priority == 'medium'
                                      ? cmedium
                                      : chigh,
                            ),
                            Text(
                              msgData.priority,
                              style: TextStyle(fontSize: 12.0, color: cgrey),
                            ),
                          ],
                        ),
                        title: Text('${msgData.title}', style: TextStyle(color: cblack),),
                        subtitle: Text(
                          truncate(msgData.notifDesc, 50,
                              omission: '...', position: TruncatePosition.end),
                          style: TextStyle(fontSize: 12.0, color: cgrey),
                        ),
                        trailing: Text(
                          '${msgData.timeago}',
                          style: TextStyle(fontSize: 12.0, color: cgrey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SentMessageDetailScreen(
                                  userSentMessage: msgData),
                            ),
                          );
                        },
                      )
                    : '',
              ),
            ),
          );
        },
        itemCount: userSentMessages.length,
      ),
    );
  }
}
