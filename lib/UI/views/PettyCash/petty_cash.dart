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
            title: Text("Petty Cash Form"),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
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
  _showPettyCashModalBottomSheet(context, PettyCashData pettyCashData) {
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
              pageTitle(pettyCashData.title),
              Divider(),
              Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: dialogTitle("Transaction Date:"),
                      subtitle: dialogSubTitle(pettyCashData.transactionDate),
                    ),
                    ListTile(
                      title: dialogTitle("Transaction Number:"),
                      subtitle: dialogSubTitle(pettyCashData.transactionNumber),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Approval:"),
                      subtitle: pettyCashData.hodApproval == "YES"
                          ? dialogSubTitle("HOD has approved your request.")
                          : dialogSubTitle(
                              "HOD is yet to approve your request."),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Comment:"),
                      subtitle: pettyCashData.hodComment != null
                          ? dialogSubTitle(pettyCashData.hodComment)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("ERMC Approval:"),
                      subtitle: pettyCashData.ermcApproval == "YES"
                          ? dialogSubTitle("ERMC has approved your request.")
                          : dialogSubTitle(
                              "ERMC is yet to approve your request"),
                    ),
                    ListTile(
                      title: dialogTitle("ERMC Comment:"),
                      subtitle: pettyCashData.ermcComment != null
                          ? dialogSubTitle(pettyCashData.ermcComment)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("Corporate Services Approval:"),
                      subtitle: pettyCashData.corporateServicesApproval == "YES"
                          ? dialogSubTitle(
                              "Corporate services has approved your request.")
                          : dialogSubTitle(
                              "Corporate services is yet to approve your request"),
                    ),
                    ListTile(
                        title: dialogTitle("Corporate Services Comment:"),
                        subtitle: pettyCashData.corporateServicesComment != null
                            ? dialogSubTitle(pettyCashData.ermcComment)
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Payment Status:"),
                      subtitle: dialogSubTitle(pettyCashData.paymentStatus),
                    ),
                    ListTile(
                      title: dialogTitle("Payment Comment:"),
                      subtitle: dialogSubTitle(pettyCashData.paymentComment),
                    ),
                    ListTile(
                      title: dialogTitle("Paid On:"),
                      subtitle: pettyCashData.paidOn != null
                          ? dialogSubTitle(pettyCashData.paidOn)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("Description:"),
                      subtitle: dialogSubTitle(pettyCashData.description),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Requested:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(pettyCashData.totalAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Approved:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(pettyCashData.approvedAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Paid:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(pettyCashData.amountPaid)}"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
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
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: () {
                      if (pettyCashData.isConcluded == 'YES') {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConcludeRequestScreen(),
                            settings: RouteSettings(
                              arguments: pettyCashData,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Conclude".toUpperCase(),
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
    return ListView.builder(
      itemBuilder: (context, index) {
        var pcData = pettyCashData[index];
        return GestureDetector(
          child: pcData.isConcluded == "YES"
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(7.0),
                    ),
                    color: Colors.teal.withOpacity(0.25),
                  ),
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
                          title: Text(pcData.title),
                          subtitle: Text(
                            truncate(pcData.description, 50,
                                omission: '...',
                                position: TruncatePosition.end),
                            style: TextStyle(fontSize: 12.0, color: cgrey),
                          ),
                          trailing: Text(
                            pcData.paymentStatus,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: pcData.paymentStatus == 'Fully Paid'
                                    ? cgreen
                                    : pcData.paymentStatus == 'Partially Paid'
                                        ? cliteblue
                                        : corange),
                          ),
                          onTap: () {
                            _showPettyCashModalBottomSheet(context, pcData);
                          },
                        )
                      : Text(''),
                )
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(7.0),
                    ),
                    color: Theme.of(context).accentColor,
                  ),
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
                          title: Text(pcData.title),
                          subtitle: Text(
                            truncate(pcData.description, 50,
                                omission: '...',
                                position: TruncatePosition.end),
                            style: TextStyle(fontSize: 12.0, color: cgrey),
                          ),
                          trailing: Text(
                            pcData.paymentStatus,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: pcData.paymentStatus == 'Fully Paid'
                                    ? cgreen
                                    : pcData.paymentStatus == 'Partially Paid'
                                        ? cliteblue
                                        : corange),
                          ),
                          onTap: () {
                            _showPettyCashModalBottomSheet(context, pcData);
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
      context, UnpaidPettyCashData unpaidPettyCashData) {
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
              pageTitle(unpaidPettyCashData.title),
              Divider(),
              Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: dialogTitle("Transaction Date:"),
                      subtitle:
                          dialogSubTitle(unpaidPettyCashData.transactionDate),
                    ),
                    ListTile(
                      title: dialogTitle("Transaction Number:"),
                      subtitle:
                          dialogSubTitle(unpaidPettyCashData.transactionNumber),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Approval:"),
                      subtitle: unpaidPettyCashData.hodApproval == "YES"
                          ? dialogSubTitle("HOD has approved your request.")
                          : dialogSubTitle(
                              "HOD is yet to approve your request."),
                    ),
                    ListTile(
                      title: dialogTitle("HOD Comment:"),
                      subtitle: unpaidPettyCashData.hodComment != null
                          ? dialogSubTitle(unpaidPettyCashData.hodComment)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("ERMC Approval:"),
                      subtitle: unpaidPettyCashData.ermcApproval == "YES"
                          ? dialogSubTitle("ERMC has approved your request.")
                          : dialogSubTitle(
                              "ERMC is yet to approve your request"),
                    ),
                    ListTile(
                        title: dialogTitle("ERMC Comment:"),
                        subtitle: unpaidPettyCashData.ermcComment != null
                            ? dialogSubTitle(unpaidPettyCashData.ermcComment)
                            : Text('')),
                    ListTile(
                      title: dialogTitle("Corporate Services Approval:"),
                      subtitle: unpaidPettyCashData.corporateServicesApproval ==
                              "YES"
                          ? dialogSubTitle(
                              "Corporate services has approved your request.")
                          : dialogSubTitle(
                              "Corporate services is yet to approve your request"),
                    ),
                    ListTile(
                      title: dialogTitle("Corporate Services Comment:"),
                      subtitle:
                          unpaidPettyCashData.corporateServicesComment != null
                              ? dialogSubTitle(unpaidPettyCashData.ermcComment)
                              : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("Payment Status:"),
                      subtitle:
                          dialogSubTitle(unpaidPettyCashData.paymentStatus),
                    ),
                    ListTile(
                      title: dialogTitle("Payment Comment:"),
                      subtitle:
                          dialogSubTitle(unpaidPettyCashData.paymentComment),
                    ),
                    ListTile(
                      title: dialogTitle("Paid On:"),
                      subtitle: unpaidPettyCashData.paidOn != null
                          ? dialogSubTitle(unpaidPettyCashData.paidOn)
                          : Text(''),
                    ),
                    ListTile(
                      title: dialogTitle("Description:"),
                      subtitle: dialogSubTitle(unpaidPettyCashData.description),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Requested:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(unpaidPettyCashData.totalAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Approved:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(unpaidPettyCashData.approvedAmount)}"),
                    ),
                    ListTile(
                      title: dialogTitle("Amount Paid:"),
                      subtitle: dialogSubTitleAmount(
                          "N${egoFormata.format(unpaidPettyCashData.amountPaid)}"),
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
                    title: Text(pcData.title),
                    subtitle: Text(
                      truncate(pcData.description, 50,
                          omission: '...', position: TruncatePosition.end),
                      style: TextStyle(fontSize: 12.0, color: cgrey),
                    ),
                    trailing: Text(
                      pcData.paymentStatus,
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
                      _showPettyCashModalBottomSheet(context, pcData);
                    },
                  )
                : Text(''),
          ),
        );
      },
      itemCount: unpaidPettyCashData.length,
    );
  }
}

// Confirm / Conclude Request Class
class ConcludeRequestScreen extends StatefulWidget {
  @override
  _ConcludeRequestScreenState createState() => _ConcludeRequestScreenState();
}

class _ConcludeRequestScreenState extends State<ConcludeRequestScreen> {
  final egoFormata = new NumberFormat("#,##0.00", "en_NG");

  int userId;
  bool loading = false;
  bool showForm = true;
  var userData;
  var error;
  var success;
  bool isSuccess = false;
  bool isError = false;

  @override
  void initState() {
    _getUserInfo();
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
  void _concludeRequest(context, int id) async {
    if (this.mounted) {
      setState(() => loading = true);
    }

    var data = {
      'expense_id': id,
    };

    // Make API call
    var endPoint = 'expenses/user/$userId/conclude';
    var result = await CallApi().putAuthData(data, endPoint);
    if (result.statusCode == 201) {
      if (this.mounted) {
        setState(() {
          fetchPettyCash();
          loading = false;
          isSuccess = true;
          isError = false;
          success =
              "Petty cash request successfully concluded. This transacton will now be marked as completed.";
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          loading = false;
          isSuccess = false;
          isError = true;
          error = 'Request failed, please try again later.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PettyCashData pettyCashData =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Conclude Requests'),
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
                    child: cashDetailpageHeader(pettyCashData.title),
                  ),
                  Divider(
                    color: Theme.of(context).accentColor,
                  ),
                  loading
                      ? Loading()
                      : Container(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: isSuccess
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 15),
                                      child: Text(
                                        success,
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RaisedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                PettyCashScreen(),
                                          ),
                                        );
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      icon: Icon(
                                        Icons.done_all,
                                        color: Theme.of(context).accentColor,
                                      ), //`Icon` to display
                                      label: Text(
                                        'Done'.toUpperCase(),
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      "Ensure you have been paid the total sum of: ",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        child: Text(
                                          "N${egoFormata.format(pettyCashData.amountPaid)}",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "before clicking the confirm button. This step is not reversible.",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    isError
                                        ? Text(
                                            success,
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          )
                                        : Text(''),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            "Close".toUpperCase(),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textSelectionColor),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        RaisedButton.icon(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          icon: Icon(
                                            Icons.save,
                                            color:
                                                Theme.of(context).accentColor,
                                          ), //`Icon` to display
                                          label: Text(
                                            'Confirm'.toUpperCase(),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ), //`Text` to display
                                          onPressed: () {
                                            _concludeRequest(
                                                context, pettyCashData.id);
                                          },
                                        )
                                      ],
                                    ),
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
