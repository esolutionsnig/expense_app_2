import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/department.dart';
import 'package:Expense/core/models/petty_cash.dart';
import 'package:Expense/core/models/petty_cash_unpaid.dart';
import 'package:Expense/core/models/transaction_type.dart';
import 'package:Expense/core/services/api.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truncate/truncate.dart';

class PettyCashScreen extends StatefulWidget {
  @override
  _PettyCashScreenState createState() => _PettyCashScreenState();
}

class _PettyCashScreenState extends State<PettyCashScreen> {
  final _formKey = GlobalKey<FormState>();

  String pageAppTitle = 'Petty Cash';
  String tab1 = "All Requests";
  String tab2 = "Unpaid Requests";

  bool loading = false;

  AutoCompleteTextField searchDepartmentTextField;
  GlobalKey<AutoCompleteTextFieldState> depaartmentKey = GlobalKey();
  AutoCompleteTextField searchTransactionTypeTextField;
  GlobalKey<AutoCompleteTextFieldState> transactionTypeKey = GlobalKey();

  String title;
  int departmentId;
  String department;
  String transactionType;
  int transactionTypeId;
  String transactionDate;
  String totalAmount;
  int hod;
  int userId;
  String description;

  List<String> allDepartments = <String>[];
  var departments = List<Department>();

  _fetchDepartments() async {
    var endPoint = "departments";
    //Make API call
    var result = await CallApi().getAuthData(endPoint);
    if (result.statusCode == 200) {
      var data = json.decode(result.body);
      if (this.mounted) {
        setState(() {
          Iterable list = data['data'];
          departments =
              list.map((model) => Department.fromJson(model)).toList();
          departments.forEach((a) {
            // Add items to list
            allDepartments.add(a.name);
          });
        });
      }
    }
  }

  List<String> allTransactionTypes = <String>[];
  var transactionTypes = List<TransactionType>();

  _fetchTransactionTypes() async {
    var endPoint = "expensetypes";
    //Make API call
    var result = await CallApi().getAuthData(endPoint);
    if (result.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          Iterable list = json.decode(result.body);
          transactionTypes =
              list.map((model) => TransactionType.fromJson(model)).toList();
          transactionTypes.forEach((a) {
            // Add items to list
            allTransactionTypes.add(a.name);
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchDepartments();
    _fetchTransactionTypes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var userData;

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

  // Add new bank account
  void _addNewPettyCash() async {
    if (_formKey.currentState.validate()) {
      if (this.mounted) {
        setState(() => loading = true);
      }

      // check if department exists in a list of departments
      var dItem = departments.where((item) => item.name == department);
      // lopp through to get hodId and Department Name
      dItem.forEach((a) {
        hod = a.hod;
        departmentId = a.id;
      });

      // check if transaction type exists in a list of transaction types
      var tItem =
          transactionTypes.where((item) => item.name == transactionType);
      // lopp through to get hodId and transactionType Name
      tItem.forEach((t) {
        transactionTypeId = t.id;
      });

      var data = {
        'title': title,
        'department': departmentId,
        'transaction_type': transactionTypeId,
        'transaction_date': transactionDate,
        'total_amount': totalAmount,
        'hod': hod,
        'description': description
      };

      userId = userData['id'];

      // Make API call
      var endPoint = '$userId/expenses';
      var result = await CallApi().postAuthData(data, endPoint);
      if (result.statusCode == 201) {
        if (this.mounted) {
          setState(() {
            fetchPettyCash();
            loading = false;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    }
  }

  String validateName(String value) {
    if (value.length < 3) {
      return 'Petty cash title is required';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add bank account form
    void _addPettyCashForm() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Bank Account Addition"),
            content: loading
                ? Loading()
                : ListView(
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        autovalidate: true,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  labelText: 'Petty Cash Title',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                validator: validateName,
                                onChanged: (val) {
                                  setState(() => title = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                              searchDepartmentTextField = AutoCompleteTextField(
                                key: depaartmentKey,
                                clearOnSubmit: false,
                                suggestions: allDepartments,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                  hintText: 'Select your department',
                                  labelText: 'Department',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                itemFilter: (item, query) {
                                  return item
                                      .toLowerCase()
                                      .startsWith(query.toLowerCase());
                                },
                                itemSorter: (a, b) {
                                  return a.compareTo(b);
                                },
                                itemSubmitted: (item) {
                                  setState(
                                    () {
                                      searchDepartmentTextField
                                          .textField.controller.text = item;
                                      department = item;
                                    },
                                  );
                                },
                                itemBuilder: (context, item) {
                                  // UI for the autocompplete row
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                              searchTransactionTypeTextField =
                                  AutoCompleteTextField(
                                key: transactionTypeKey,
                                clearOnSubmit: false,
                                suggestions: allTransactionTypes,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                  hintText: 'Select petty cash type',
                                  labelText: 'Transaction Type',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                itemFilter: (item, query) {
                                  return item
                                      .toLowerCase()
                                      .startsWith(query.toLowerCase());
                                },
                                itemSorter: (a, b) {
                                  return a.compareTo(b);
                                },
                                itemSubmitted: (item) {
                                  setState(() {
                                    searchTransactionTypeTextField
                                        .textField.controller.text = item;
                                    transactionType = item;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // UI for the autocompplete row
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Transaction Date',
                                  labelText: 'e.g 2020-02-14',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                onChanged: (val) {
                                  setState(() => transactionDate = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Amount',
                                  labelText: 'Transaction amount',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => totalAmount = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Description',
                                  labelText: 'Describe this request',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                maxLines: 2,
                                validator: validateName,
                                onChanged: (val) {
                                  setState(() => description = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: Text(''),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            actions: <Widget>[
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
                  RaisedButton.icon(
                    color: Theme.of(context).accentColor,
                    icon: Icon(
                      Icons.save,
                      color: Theme.of(context).primaryColor,
                    ), //`Icon` to display
                    label: Text(
                      'SAVE',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ), //`Text` to display
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addNewPettyCash();
                    },
                  )
                ],
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 60.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    pageAppTitle,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.table_chart), text: tab1),
                      Tab(icon: Icon(Icons.view_quilt), text: tab2),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: loading
              ? Loading()
              : TabBarView(
                  children: <Widget>[AllPettyCash(), UnpaidPettyCash()],
                ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            _addPettyCashForm();
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
            size: 30.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      decoration: BoxDecoration(color: Theme.of(context).accentColor),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Unpaid Petty Cash Page
class UnpaidPettyCash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: FutureBuilder(
        future: fetchUnpaidPettyCash(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? UnpaidPettyCashList(unpaidPettyCashData: snapshot.data)
              : Loading();
        },
      ),
    );
  }
}

// All Petty Cash Page
class AllPettyCash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: FutureBuilder(
        future: fetchPettyCash(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? PettyCashList(pettyCashData: snapshot.data)
              : Loading();
        },
      ),
    );
  }
}

// All Petty Cash List
class PettyCashList extends StatelessWidget {
  final List<PettyCashData> pettyCashData;
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  // Constructor
  PettyCashList({Key key, this.pettyCashData}) : super(key: key);

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
      String description) {
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: Theme.of(context).accentColor,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close".toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
    return ListView.builder(
      itemBuilder: (context, index) {
        var pcData = pettyCashData[index];
        return GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: pcData != null
                ? ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet,
                      size: 33,
                      color: pcData.paymentStatus == 'Fully Paid'
                          ? cgreen
                          : pcData.paymentStatus == 'Partially Paid'
                              ? cliteblue
                              : corange,
                    ),
                    title: Text('${pcData.title}'),
                    subtitle: Text(
                      truncate(pcData.description, 50,
                          omission: '...', position: TruncatePosition.end),
                      style: TextStyle(fontSize: 12.0, color: cgrey),
                    ),
                    trailing: Text(
                      '${pcData.paymentStatus}',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: pcData.paymentStatus == 'Fully Paid'
                              ? cgreen
                              : pcData.paymentStatus == 'Partially Paid'
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
                          pcData.description);
                    },
                  )
                : Text(''),
          ),
        );
      },
      itemCount: pettyCashData.length,
    );
  }
}

// All Unpaid Petty Cash
class UnpaidPettyCashList extends StatelessWidget {
  final List<UnpaidPettyCashData> unpaidPettyCashData;
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  // Constructor
  UnpaidPettyCashList({Key key, this.unpaidPettyCashData}) : super(key: key);

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
      String description) {
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: Theme.of(context).accentColor,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close".toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
    return ListView.builder(
      itemBuilder: (context, index) {
        var pcData = unpaidPettyCashData[index];
        return GestureDetector(
          child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: pcData != null
                  ? ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet,
                        size: 33,
                        color: pcData.paymentStatus == 'Fully Paid'
                            ? cgreen
                            : pcData.paymentStatus == 'Partially Paid'
                                ? cliteblue
                                : corange,
                      ),
                      title: Text('${pcData.title}'),
                      subtitle: Text(
                        truncate(pcData.description, 50,
                            omission: '...', position: TruncatePosition.end),
                        style: TextStyle(fontSize: 12.0, color: cgrey),
                      ),
                      trailing: Text(
                        '${pcData.paymentStatus}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: pcData.paymentStatus == 'Fully Paid'
                              ? cgreen
                              : pcData.paymentStatus == 'Partially Paid'
                                  ? cliteblue
                                  : corange,
                        ),
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
                            pcData.description);
                      },
                    )
                  : Text('')),
        );
      },
      itemCount: unpaidPettyCashData.length,
    );
  }
}
