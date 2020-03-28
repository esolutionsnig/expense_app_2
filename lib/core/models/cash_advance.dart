import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashAdvanceData {
  int id;
  int userId;
  String title;
  int department;
  int transactionType;
  String transactionDate;
  String transactionNumber;
  String purpose;
  int beneficiary;
  int amount;
  int approvedAmount;
  int amountPaid;
  String supportingDocument;
  String hodApproval;
  String hodComment;
  String ermcApproval;
  String ermcComment;
  String mdApproval;
  String mdComment;
  String financeApproval;
  String financeComment;
  String paymentMode;
  int bank;
  String payed;
  String payedOn;
  String paymentComment;
  String paymentStatus;
  String concluded;
  String concludedOn;
  String rDate;

  // Constructor
  CashAdvanceData({
    this.id,
    this.userId,
    this.title,
    this.department,
    this.transactionType,
    this.transactionDate,
    this.transactionNumber,
    this.purpose,
    this.beneficiary,
    this.amount,
    this.approvedAmount,
    this.amountPaid,
    this.supportingDocument,
    this.hodApproval,
    this.hodComment,
    this.ermcApproval,
    this.ermcComment,
    this.mdApproval,
    this.mdComment,
    this.financeApproval,
    this.financeComment,
    this.paymentMode,
    this.bank,
    this.payed,
    this.payedOn,
    this.paymentComment,
    this.paymentStatus,
    this.concluded,
    this.concludedOn,
    this.rDate,
  });

  // Statis Method
  factory CashAdvanceData.fromJson(Map<String, dynamic> json) {
    return CashAdvanceData(
      id: json["id"],
      userId: json["user_id"],
      title: json["title"],
      department: json["department"],
      transactionType: json["transaction_type"],
      transactionDate: json["transaction_date"],
      transactionNumber: json["transaction_number"],
      purpose: json["purpose"],
      beneficiary: json["beneficiary"],
      amount: json["amount"],
      approvedAmount: json["approved_amount"],
      amountPaid: json["amount_paid"],
      supportingDocument: json["supporting_document"],
      hodApproval: json["hod_approval"],
      hodComment: json["hod_comment"],
      ermcApproval: json["ermc_approval"],
      ermcComment: json["ermc_comment"],
      mdApproval: json["md_approval"],
      mdComment: json["md_comment"],
      financeApproval: json["finance_approval"],
      financeComment: json["finance_comment"],
      paymentMode: json["payment_mode"],
      bank: json["bank"],
      payed: json["payed"],
      payedOn: json["payed_on"],
      paymentComment: json["payment_comment"],
      paymentStatus: json["payment_status"],
      concluded: json["concluded"],
      concludedOn: json["concluded_on"],
      rDate: json["r_date"],
    );
  }
}

// Fetch data from API
Future<List<CashAdvanceData>> fetchCashAdvance() async {
  var listOfCashAdvance;
  // Get data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'cashadvances/user/$userId/get-all';

  try {
    // Make an API call
    final result = await CallApi().getAuthData(endPoint);
    if (result.statusCode == 200) {
      Map<String, dynamic> mapResult = json.decode(result.body);
      final pcs = mapResult["dataDesc"].cast<Map<String, dynamic>>();
      // Get list of petty cash
      final listOfCashAdvance = await pcs.map<CashAdvanceData>((json) {
        return CashAdvanceData.fromJson(json);
      }).toList();
      return listOfCashAdvance;
    } else {
      print('statusCode: ' + result.statusCode);
      throw Exception("Failed to load data from API");
    }
  } catch (e) {
    print(e.toString());
  }
  return listOfCashAdvance;
}
