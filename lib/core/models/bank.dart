import 'dart:async';
import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bank {
  int id;
  int userId;
  String name;
  String accountType;
  String accountNumber;
  String accountStatus;
  String isPreferred;
  int bankCount;

  // Constructor
  Bank(
      {this.id,
      this.userId,
      this.name,
      this.accountType,
      this.accountNumber,
      this.accountStatus,
      this.isPreferred,
      this.bankCount});

  // Static Method
  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        accountType: json["account_type"],
        accountNumber: json["account_number"],
        accountStatus: json["account_status"],
        isPreferred: json["is_preferred"],
    );
  }
}
 
// Fetch data from API
Future<List<Bank>> fetchBanks() async {
  var listOfBanks;
  // Get Data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'userbanks/user/$userId/bank/all';

  try {
    final response = await CallApi().getAuthData(endPoint);
    if (response.statusCode == 200) {
      Map<String, dynamic> mapResponse = json.decode(response.body);
      final banks = mapResponse["data"].cast<Map<String, dynamic>>();
      // Get list of Banks
      listOfBanks = await banks.map<Bank>((json) {
        return Bank.fromJson(json);
      }).toList();
      
      return listOfBanks;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Bank from the API');
    }
  } catch (e) {
    print(e.toString());
    // return {'error': e.toString()};
  }
  return listOfBanks;
}
