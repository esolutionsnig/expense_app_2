import 'dart:convert';

import 'package:Expense/core/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChequeRequisitionErmcData {
  int id;
  int userId;
  String payee;
  int amount;
  int amountPaid;
  String description;
  String supportingDocument;
  String requisitionOn;
  int transactionNumber;
  String department;
  int hod;
  String hodApproval;
  String hodComment;
  String budgeted;
  int checkedBy;
  String approved;
  int approvedBy;
  String approvalComment;
  String payed;
  String chequeNumber;
  String paymentStatus;
  String concluded;
  String concludedOn;

  // Constructor
  ChequeRequisitionErmcData({
    this.id,
    this.userId,
    this.payee,
    this.amount,
    this.amountPaid,
    this.description,
    this.supportingDocument,
    this.requisitionOn,
    this.transactionNumber,
    this.department,
    this.hod,
    this.hodApproval,
    this.hodComment,
    this.budgeted,
    this.checkedBy,
    this.approved,
    this.approvedBy,
    this.approvalComment,
    this.payed,
    this.chequeNumber,
    this.paymentStatus,
    this.concluded,
    this.concludedOn,
  });

  // Statis Method
  factory ChequeRequisitionErmcData.fromJson(Map<String, dynamic> json) {
    return ChequeRequisitionErmcData(
      id: json["id"],
      userId: json['user_id'],
      payee: json['payee'],
      amount: json['amount'],
      amountPaid: json['amount_paid'],
      description: json['description'],
      supportingDocument: json['supporting_document'],
      requisitionOn: json['requisition_on'],
      transactionNumber: json['transaction_number'],
      department: json['department'],
      hod: json['hod'],
      hodApproval: json['hod_approval'],
      hodComment: json['hod_comment'],
      budgeted: json['budgeted'],
      checkedBy: json['checked_by'],
      approved: json['approved'],
      approvedBy: json['approved_by'],
      approvalComment: json['approval_comment'],
      payed: json['payed'],
      chequeNumber: json['cheque_number'],
      paymentStatus: json['payment_status'],
      concluded: json['concluded'],
      concludedOn: json['concluded_on'],
    );
  }
}

// Fetch data from API
Future<List<ChequeRequisitionErmcData>> fetchChequeRequisitionErmcData() async {
  var listOfChequeRequisition;
  // Get data from local storage
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var userJson = localStorage.getString('user');
  var userData = json.decode(userJson);
  var user = userData[0];
  var userId = user["id"];
  var endPoint = 'chequerequisitions/user/$userId/approvals/ermc';

  try {
    // Make an API call
    final result = await CallApi().getAuthData(endPoint);
    if (result.statusCode == 200) {
      Map<String, dynamic> mapResult = json.decode(result.body);
      final pcs = mapResult["data"].cast<Map<String, dynamic>>();
      // Get list of petty cash
      final listOfChequeRequisition = await pcs.map<ChequeRequisitionErmcData>((json) {
        return ChequeRequisitionErmcData.fromJson(json);
      }).toList();
      return listOfChequeRequisition;
    } else {
      throw Exception("Failed to load data from API");
    }
  } catch (e) {
    print(e.toString());
  }
  return listOfChequeRequisition;
}
