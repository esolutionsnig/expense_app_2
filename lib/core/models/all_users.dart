
import 'dart:convert';

import 'package:Expense/core/services/api.dart';

class AllUsers {
  int id;
  String staffPin;
  String staffId;
  String surname;
  String firstname;
  String othernames;
  String phoneNumber;
  String username;
  String email;
  String avatarUrl;
  String preferedTheme;

  // Constructor
  AllUsers({
    this.id,
    this.staffPin,
    this.staffId,
    this.surname,
    this.firstname,
    this.othernames,
    this.phoneNumber,
    this.username,
    this.email,
    this.avatarUrl,
    this.preferedTheme,
  });

  // Static method
  factory AllUsers.fromJson(Map<String, dynamic> json) {
    return AllUsers(
      id: json["id"],
      staffPin: json["staff_pin"],
      staffId: json["staff_id"],
      surname: json["surname"],
      firstname: json["firstname"],
      othernames: json["othernames"],
      phoneNumber: json["phone_number"],
      username: json["username"],
      email: json["email"],
      avatarUrl: json["avatar_id"],
      preferedTheme: json["prefered_theme"],
    );
  }
}

// Fetch data from API
Future<List<AllUsers>> fetchAllUsers() async {
  var endPoint = 'users/all';
  var listOfUsers;
  try {
    final res = await CallApi().getAuthData(endPoint);
    if(res.statusCode == 200) {
      Map<String, dynamic> mapResult = json.decode(res.body);
      final allUsersMap = mapResult["data"].cast<Map<String, dynamic>>();
      // Get list of users
      listOfUsers = await allUsersMap.map<AllUsers>((json) {
        return AllUsers.fromJson(json);
      }).toList();
      return listOfUsers;
    } else {
      print(res.statusCode);
      throw Exception('Failed to load Users from API');
    }
  } catch(e) {
    print(e.toString());
  }
  return listOfUsers;
}
