import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/notification.dart';
import 'package:Expense/core/services/api.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:truncate/truncate.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: innerPageTitle('Notifications'),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 0.0 : 0.0,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: 55.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Updates on your activities",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 65.0),
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: fetchNotifcations,
              child: FutureBuilder(
                future: fetchNotifcations(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                  }
                  return snapshot.hasData
                      ? NotifcationList(notifcations: snapshot.data)
                      : Loading();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Notifcation List
class NotifcationList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<Notifcation> notifcations;
  // Constructor
  NotifcationList({Key key, this.notifcations}) : super(key: key);

  // Update notification status to read
  Future<Null> _readNotification(int id) async {
    var endPoint = 'usernotifications/$id';
    try {
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        // print('updated');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show notification
    void _showNotificationDialog(int id, int userId, String title,
        String notifDesc, String addedOn, String timeago) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("$title"),
            content: Text("$notifDesc"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return DraggableScrollbar.rrect(
      controller: _scrollController,
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          var notData = notifcations[index];
          return GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: notData != null
                  ? ListTile(
                      leading: Icon(
                        Icons.notifications_none,
                        size: 35.0,
                      ),
                      title: Text('${notData.title}'),
                      subtitle: Text(
                        truncate(notData.notifDesc, 50,
                            omission: '...', position: TruncatePosition.end),
                        style: TextStyle(fontSize: 12.0),
                      ),
                      trailing: Text(
                        '${notData.timeago}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                      onTap: () {
                        _showNotificationDialog(
                            notData.id,
                            notData.userId,
                            notData.title,
                            notData.notifDesc,
                            notData.addedOn,
                            notData.timeago);
                        // Read and Update record
                        _readNotification(notData.id);
                      },
                    )
                  : '',
            ),
          );
        },
        itemCount: notifcations.length,
      ),
    );
  }
}
