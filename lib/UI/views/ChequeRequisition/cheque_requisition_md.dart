import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/cheque_requisition_md.dart';
import 'package:Expense/core/services/api.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truncate/truncate.dart';

class ChequeRequisitionMdScreen extends StatefulWidget {
  @override
  _ChequeRequisitionMdScreenState createState() =>
      _ChequeRequisitionMdScreenState();
}

class _ChequeRequisitionMdScreenState
    extends State<ChequeRequisitionMdScreen> {
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  bool loading = false;

  // Show Cash Advance Sheet
  _showPettyCashModalBottomSheet(
      context, ChequeRequisitionMdData data) {
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
              pageTitle(data.payee),
              Divider(),
              Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: dialogTitle("Transaction Date:"),
                      subtitle: dialogSubTitle(data.requisitionOn),
                    ),
                    ListTile(
                      title: dialogTitle("Transaction Number:"),
                      subtitle:
                          dialogSubTitle('${data.transactionNumber}'),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Approval:"),
                      subtitle: data.hodApproval == "YES"
                          ? dialogSubTitle("HOD has approved your request.")
                          : dialogSubTitle(
                              "HOD is yet to approve your request."),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Comment:"),
                      subtitle: data.hodComment != null
                          ? dialogSubTitle(data.hodComment)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("ERMC Approval:"),
                      subtitle: data.budgeted != null
                          ? dialogSubTitle("ERMC has approved your request.")
                          : dialogSubTitle(
                              "ERMC is yet to approve your request"),
                    ),
                    ListTile(
                      title: dialogTitle("Managing Director's Approval:"),
                      subtitle: data.approved == "YES"
                          ? dialogSubTitle(
                              "Managing director's has approved your request.")
                          : dialogSubTitle(
                              "Managing director's is yet to approve your request"),
                    ),
                    ListTile(
                        title: dialogTitle("Managing Director's Comment:"),
                        subtitle: data.approvalComment != null
                            ? dialogSubTitle(data.approvalComment)
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Payment Status:"),
                      subtitle: dialogSubTitle(data.paymentStatus),
                    ),
                    ListTile(
                      title: dialogTitle("Description:"),
                      subtitle: dialogSubTitle(data.description),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Requested:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(data.amount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Paid:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(data.amountPaid)}"),
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
                            arguments: data,
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
        title: Text('Cheque Requisition'),
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
                  "Managing Director's Approval",
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
            margin: EdgeInsets.only(top: 60),
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: FutureBuilder(
                future: fetchChequeRequisitionMdData(),
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
                                                topRight:
                                                    Radius.circular(15.0)),
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
                                            title: Text('${pcData.payee}'),
                                            subtitle: Text(
                                              truncate(pcData.description, 50,
                                                  omission: '...',
                                                  position:
                                                      TruncatePosition.end),
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
                                              _showPettyCashModalBottomSheet(context, pcData);
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
        ],
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

  // Approve staff request
  void _approveStaffRequest(int id) async {
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
      print(isApproved);

      var data = {
        'ucr_id': id,
        'approved_amount': approvedAmount,
        'approved': isApproved,
        'approval_comment': hodComment,
      };

      // Make API call
      var endPoint = 'chequerequisitions/user/$userId/md';
      var result = await CallApi().putAuthData(data, endPoint);
      if (result.statusCode == 201) {
        if (this.mounted) {
          setState(() {
            fetchChequeRequisitionMdData();
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
    final ChequeRequisitionMdData pcData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve requests'),
      ),
      body: ListView(
        children: <Widget>[
          // Cash Advance
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
                    child: cashDetailpageHeader(pcData.payee),
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
                                      "Requested amount is: ",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "N${egoFormata.format(pcData.amount)}",
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
