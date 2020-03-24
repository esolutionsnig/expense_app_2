import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/petty_cash_approval_hod.dart';
import 'package:Expense/core/services/api.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truncate/truncate.dart';

class PettyCashApprovalHodScreen extends StatefulWidget {
  @override
  _PettyCashApprovalHodScreenState createState() =>
      _PettyCashApprovalHodScreenState();
}

class _PettyCashApprovalHodScreenState
    extends State<PettyCashApprovalHodScreen> {
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  bool loading = false;

  // Show Petty Cash Sheet
  _showPettyCashModalBottomSheet(
      context,
      int id,
      int userId,
      String title,
      String transactionDate,
      String transactionNumber,
      int totalAmount,
      int approvedAmount,
      int amountPaid,
      String hodApproval,
      String hodComment,
      String ermcApproval,
      String ermcComment,
      String corporateServicesApproval,
      String corporateServicesComment,
      String isConcluded,
      String concludedOn,
      String isPaid,
      String paidOn,
      String paymentComment,
      String paymentStatus,
      String description,
      PettyCashDataHod pcData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400.0,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: <Widget>[
              pageTitle(title),
              Divider(),
              Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: dialogTitle("Transaction Date:"),
                      subtitle: dialogSubTitle("$transactionDate"),
                    ),
                    ListTile(
                      title: dialogTitle("Transaction Number:"),
                      subtitle: dialogSubTitle("$transactionNumber"),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Approval:"),
                      subtitle: hodApproval == "YES"
                          ? dialogSubTitle("HOD has approved your request.")
                          : dialogSubTitle(
                              "HOD is yet to approve your request."),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Comment:"),
                      subtitle: hodComment != null
                          ? dialogSubTitle("$hodComment")
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("ERMC Approval:"),
                      subtitle: ermcApproval == "YES"
                          ? dialogSubTitle("ERMC has approved your request.")
                          : dialogSubTitle(
                              "ERMC is yet to approve your request"),
                    ),
                    ListTile(
                        title: dialogTitle("ERMC Comment:"),
                        subtitle: ermcComment != null
                            ? dialogSubTitle("$ermcComment")
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Corporate Services Approval:"),
                      subtitle: corporateServicesApproval == "YES"
                          ? dialogSubTitle(
                              "Corporate services has approved your request.")
                          : dialogSubTitle(
                              "Corporate services is yet to approve your request"),
                    ),
                    ListTile(
                        title: dialogTitle("Corporate Services Comment:"),
                        subtitle: corporateServicesComment != null
                            ? dialogSubTitle("$ermcComment")
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Payment Status:"),
                      subtitle: dialogSubTitle("$paymentStatus"),
                    ),
                    ListTile(
                      title: dialogTitle("Payment Comment:"),
                      subtitle: dialogSubTitle("$paymentComment"),
                    ),
                    ListTile(
                        title: dialogTitle("Paid On:"),
                        subtitle: paidOn != null
                            ? dialogSubTitle("$paidOn")
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Description:"),
                      subtitle: dialogSubTitle("$description"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Requested:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(totalAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Approved:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(approvedAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Paid:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(amountPaid)}"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "CLOSE",
                      style: TextStyle(
                          color: Theme.of(context).textSelectionColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApprovalPage(),
                          settings: RouteSettings(
                            arguments: pcData,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Approve Request".toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Petty Cash Approval'),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 0.0 : 0.0,
      ),
      body: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: FutureBuilder(
            future: fetchPettyCashApprovalHod(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
              }
              return snapshot.hasData
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        var pcData = snapshot.data[index];
                        return GestureDetector(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 10.0),
                              child: pcData != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0),
                                            topRight: Radius.circular(15.0)),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.account_balance_wallet,
                                          size: 33,
                                          color: pcData.paymentStatus ==
                                                  'Fully Paid'
                                              ? cgreen
                                              : pcData.paymentStatus ==
                                                      'Partially Paid'
                                                  ? cliteblue
                                                  : corange,
                                        ),
                                        title: Text('${pcData.title}'),
                                        subtitle: Text(
                                          truncate(pcData.description, 50,
                                              omission: '...',
                                              position: TruncatePosition.end),
                                          style: TextStyle(
                                              fontSize: 12.0, color: cgrey),
                                        ),
                                        trailing: Text(
                                          '${pcData.paymentStatus}',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: pcData.paymentStatus ==
                                                      'Fully Paid'
                                                  ? cgreen
                                                  : pcData.paymentStatus ==
                                                          'Partially Paid'
                                                      ? cliteblue
                                                      : corange),
                                        ),
                                        onTap: () {
                                          _showPettyCashModalBottomSheet(
                                              context,
                                              pcData.id,
                                              pcData.userId,
                                              pcData.title,
                                              pcData.transactionDate,
                                              pcData.transactionNumber,
                                              pcData.totalAmount,
                                              pcData.approvedAmount,
                                              pcData.amountPaid,
                                              pcData.hodApproval,
                                              pcData.hodComment,
                                              pcData.ermcApproval,
                                              pcData.ermcComment,
                                              pcData.corporateServicesApproval,
                                              pcData.corporateServicesComment,
                                              pcData.isConcluded,
                                              pcData.concludedOn,
                                              pcData.isPaid,
                                              pcData.paidOn,
                                              pcData.paymentComment,
                                              pcData.paymentStatus,
                                              pcData.description,
                                              pcData);
                                        },
                                      ),
                                    )
                                  : Text('')),
                        );
                      },
                      itemCount: snapshot.data.length,
                    )
                  : Loading();
            },
          ),
        ),
      ),
    );
  }
}

// Approve Request Class
class ApprovalPage extends StatefulWidget {
  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final _formKey = GlobalKey<FormState>();
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  int userId;
  int approvedAmount = 0;
  bool hodApproval = false;
  String accountType;
  String hodComment;

  String success = '';
  String error = '';
  bool loading = false;
  bool showForm = true;

  AutoCompleteTextField searchBankTextField;
  GlobalKey<AutoCompleteTextFieldState> bankKey = GlobalKey();
  AutoCompleteTextField searchAccountTypeTextField;
  GlobalKey<AutoCompleteTextFieldState> accounTypeKey = GlobalKey();

  var userData;

  List<bool> isSelected;

  @override
  void initState() {
    _getUserInfo();
    isSelected = [true, false];
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    if (this.mounted) {
      setState(() {
        userData = user[0];
        userId = userData['id'];
      });
    }
  }

  String validateAmount(String value) {
    if (int.parse(value) < 3) {
      return 'Amount can not be more than 10,000';
    } else {
      return null;
    }
  }

  // Approve staff request
  void _approveStaffRequest(int pettyCashId) async {
    if (_formKey.currentState.validate()) {
      String isApproved = 'NO';
      if (this.mounted) {
        setState(() => loading = true);
      }

      // Get Toggle button vale
      var approvalState = isSelected[0];

      if (approvalState) {
        isApproved = 'YES';
      } else {
        isApproved = 'NO';
      }

      var data = {
        'expense_id': pettyCashId,
        'approved_amount': approvedAmount,
        'hod_approval': isApproved,
        'hod_comment': hodComment,
      };

      // Make API call
      var endPoint = 'expenses/user/$userId/hod';
      var result = await CallApi().putAuthData(data, endPoint);
      if (result.statusCode == 201) {
        if (this.mounted) {
          setState(() {
            fetchPettyCashApprovalHod();
            loading = false;
            Navigator.of(context).pop();
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            error = 'Request failed, please supply valid credential';
            loading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PettyCashDataHod pcData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved requests'),
      ),
      body: ListView(
        children: <Widget>[
          // Petty Cash
          Container(
            padding: EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              elevation: 10.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                    child: cashDetailpageHeader(pcData.title),
                  ),
                  Divider(
                    color: Theme.of(context).accentColor,
                  ),
                  loading
                      ? Loading()
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "The requested amount is: ",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "N${egoFormata.format(pcData.totalAmount)}",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ToggleButtons(
                                      borderColor: Colors.transparent,
                                      fillColor: Colors.transparent,
                                      borderWidth: 1,
                                      selectedBorderColor:
                                          Theme.of(context).primaryColor,
                                      selectedColor:
                                          Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(0),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4,
                                              bottom: 4.0,
                                              right: 15.0,
                                              left: 15.0),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.done_all),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                'Approve',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4,
                                              bottom: 4.0,
                                              right: 15.0,
                                              left: 15.0),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.cancel),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                'Disapprove',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onPressed: (int index) {
                                        setState(() {
                                          for (int i = 0;
                                              i < isSelected.length;
                                              i++) {
                                            if (i == index) {
                                              isSelected[i] = true;
                                              // showForm = true;
                                            } else {
                                              isSelected[i] = false;
                                              // showForm = false;
                                            }
                                          }
                                        });
                                        if (isSelected[0] == true) {
                                          setState(() {
                                            showForm = true;
                                          });
                                        } else {
                                          setState(() {
                                            showForm = false;
                                          });
                                        }
                                      },
                                      isSelected: isSelected,
                                    ),
                                    showForm
                                        ? Form(
                                            key: _formKey,
                                            autovalidate: true,
                                            child: Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Amount',
                                                    labelText:
                                                        'How much are you approving?',
                                                    labelStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .textSelectionColor),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  // validator: validateAmount,
                                                  onChanged: (val) {
                                                    setState(() =>
                                                        approvedAmount =
                                                            int.parse(val));
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          top: 10.0,
                                                          right: 8.0),
                                                  child: Text(''),
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Comment',
                                                    labelText:
                                                        'Explain your decision',
                                                    labelStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .textSelectionColor),
                                                  ),
                                                  maxLines: 2,
                                                  onChanged: (val) {
                                                    setState(
                                                        () => hodComment = val);
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          top: 5.0,
                                                          right: 8.0),
                                                  child: Text(''),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(''),
                        RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Theme.of(context).primaryColor,
                          icon: Icon(
                            Icons.save,
                            color: Theme.of(context).accentColor,
                          ), //`Icon` to display
                          label: Text(
                            'SAVE APPROVAL',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ), //`Text` to display
                          onPressed: () {
                            _approveStaffRequest(pcData.id);
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }
}
