import 'dart:async';
import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMessage {
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
  UserMessage(
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
  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
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
Future<List<UserMessage>> fetchUserMessages() async {
  var listOfUserMessages;
  // Get Data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'usermessages/all/user/$userId';

  try {
    final response = await CallApi().getAuthData(endPoint);
    if (response.statusCode == 200) {
      Map<String, dynamic> mapResponse = json.decode(response.body);
      final userMessages = mapResponse["data"].cast<Map<String, dynamic>>();
      // Get list of userMessages
      listOfUserMessages = await userMessages.map<UserMessage>((json) {
        return UserMessage.fromJson(json);
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
