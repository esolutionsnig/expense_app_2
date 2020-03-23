import 'dart:async';
import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifcation {
  int id;
  int userId;
  String title;
  String notifDesc;
  String addedOn;
  String timeago;
  String isRead;
  int notificationCount;

  // Constructor
  Notifcation(
      {this.id,
      this.userId,
      this.title,
      this.notifDesc,
      this.timeago,
      this.addedOn,
      this.isRead,
      this.notificationCount});

  // Static Method
  factory Notifcation.fromJson(Map<String, dynamic> json) {
    return Notifcation(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        notifDesc: json["notif_desc"],
        addedOn: json["added_on"],
        timeago: json["timeago"],
        isRead: json["isRead"]);
  }
}

// Fetch data from API
Future<List<Notifcation>> fetchNotifcations() async {
  var listOfNotifcations;
  // Get Data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'usernotifications/unread/user/$userId';

  try {
    final response = await CallApi().getAuthData(endPoint);
    if (response.statusCode == 200) {
      Map<String, dynamic> mapResponse = json.decode(response.body);
      final notifcations = mapResponse["data"].cast<Map<String, dynamic>>();
      // Get list of notifcations
      listOfNotifcations = await notifcations.map<Notifcation>((json) {
        return Notifcation.fromJson(json);
      }).toList();
      return listOfNotifcations;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Notifcation from the API');
    }
  } catch (e) {
    print(e.toString());
    // return {'error': e.toString()};
  }
  return listOfNotifcations;
}
