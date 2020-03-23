import 'dart:async';
import 'dart:convert';

import 'package:Expense/core/services/api.dart';

class UserSentMessageTrail {
  int id;
  int msgId;
  int userId;
  String title;
  String notifDesc;
  String priority;
  int sentBy;
  String sentOn;
  int sentTo;
  String isRead;
  String readOn;
  String timeago;

  // Constructor
  UserSentMessageTrail(
      {this.id,
      this.msgId,
      this.userId,
      this.title,
      this.notifDesc,
      this.priority,
      this.sentBy,
      this.sentOn,
      this.sentTo,
      this.isRead,
      this.readOn,
      this.timeago});

  // Static Method
  factory UserSentMessageTrail.fromJson(Map<String, dynamic> json) {
    return UserSentMessageTrail(
        id: json["id"],
        msgId: json["msg_id"],
        userId: json["user_id"],
        title: json["title"],
        notifDesc: json["notif_desc"],
        priority: json["priority"],
        sentBy: json["sent_by"],
        sentOn: json["sent_on"],
        sentTo: json["sent_to"],
        isRead: json["is_read"],
        readOn: json["read_on"],
        timeago: json["timeago"],
    );
  }
}

// Fetch data from API
Future<List<UserSentMessageTrail>> fetchUserSentMessageTrails(id) async {
  var endPoint = 'usermessages/$id';
  var listOfUserMessages;
  try {
    final response = await CallApi().getAuthData(endPoint);
    if (response.statusCode == 200) {
      Map<String, dynamic> mapResponse = json.decode(response.body);
      final userMessages = mapResponse["data"].cast<Map<String, dynamic>>();
      // Get list of UserSentMessageTrails
      listOfUserMessages = await userMessages.map<UserSentMessageTrail>((json) {
        return UserSentMessageTrail.fromJson(json);
      }).toList();
      return listOfUserMessages;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Messages from the API');
    }
  } catch (e) {
    print(e.toString());
    // return {'error': e.toString()};
  }
  return listOfUserMessages;
}
