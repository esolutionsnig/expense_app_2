import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PettyCashDataHod {
  int id;
  int userId;
  String title;
  String transactionDate;
  String transactionNumber;
  int totalAmount;
  int approvedAmount;
  int amountPaid;
  String hodApproval;
  String hodComment;
  String ermcApproval;
  String ermcComment;
  String corporateServicesApproval;
  String corporateServicesComment;
  String isConcluded;
  String concludedOn;
  String isPaid;
  String paidOn;
  String paymentComment;
  String paymentStatus;
  String description;

  // Constructor
  PettyCashDataHod(
      {this.amountPaid,
      this.approvedAmount,
      this.concludedOn,
      this.corporateServicesApproval,
      this.corporateServicesComment,
      this.description,
      this.ermcApproval,
      this.ermcComment,
      this.hodApproval,
      this.hodComment,
      this.id,
      this.isConcluded,
      this.isPaid,
      this.paidOn,
      this.paymentComment,
      this.paymentStatus,
      this.title,
      this.totalAmount,
      this.transactionDate,
      this.transactionNumber,
      this.userId});

  // Static Method
  factory PettyCashDataHod.fromJson(Map<String, dynamic> json) {
    return PettyCashDataHod(
        amountPaid: json["amount_paid"],
        approvedAmount: json["approved_amount"],
        concludedOn: json["concluded_on"],
        corporateServicesApproval: json["approved"],
        corporateServicesComment: json["approval_comment"],
        description: json["description"],
        ermcApproval: json["ermc_approval"],
        ermcComment: json["ermc_comment"],
        hodApproval: json["hod_approval"],
        hodComment: json["hod_comment"],
        id: json["id"],
        isConcluded: json["concluded"],
        isPaid: json["payed"],
        paidOn: json["payed_on"],
        paymentComment: json["payment_comment"],
        paymentStatus: json["payment_status"],
        title: json["title"],
        totalAmount: json["total_amount"],
        transactionDate: json["transaction_date"],
        transactionNumber: json["transaction_number"],
        userId: json["user_id"]);
  }
}

// Fetch data from API
Future<List<PettyCashDataHod>> fetchPettyCashApprovalHod() async {
  var listOfPettyCash;
  // Get data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'expenses/user/$userId/approvals/hod';
  
  try {
    // Make an API call
    final result = await CallApi().getAuthData(endPoint);
    if (result.statusCode == 200) {
      Map<String, dynamic> mapResult = json.decode(result.body);
      final pcs = mapResult["dataDesc"].cast<Map<String, dynamic>>();
      // Get list of petty cash
      final listOfPettyCash = await pcs.map<PettyCashDataHod>((json) {
        return PettyCashDataHod.fromJson(json);
      }).toList();
      return listOfPettyCash;
    } else {
      print('statusCode: ' + result.statusCode);
      throw Exception("Failed to load data from API");
    }
  } catch(e) {
    print(e.toString());
  }
  return listOfPettyCash;
}
