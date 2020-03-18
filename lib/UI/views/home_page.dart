import 'dart:async';
import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/roles.dart';
import 'package:Expense/UI/views/Authentication/sign_in_page.dart';
import 'package:Expense/UI/views/CashAdvanced/cash_advance.dart';
import 'package:Expense/UI/views/ChequeRequisition/cheque_requisition.dart';
import 'package:Expense/UI/views/Contact/contact.dart';
import 'package:Expense/UI/views/ContactSupport/contact_support.dart';
import 'package:Expense/UI/views/Message/message.dart';
import 'package:Expense/UI/views/Notification/notification.dart';
import 'package:Expense/UI/views/PettyCash/petty_cash.dart';
import 'package:Expense/UI/views/PettyCash/petty_cash_hod.dart';
import 'package:Expense/UI/views/Profile/profile.dart';
import 'package:Expense/core/services/api.dart';
import 'package:badges/badges.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final egoFormata = NumberFormat("#,##0.00", "en_US");

  String defaultavatar =
      'https://res.cloudinary.com/icmsdevteam/image/upload/v1578489156/team_unblba.jpg';

  int userId;
  var userData;
  var userRolesData;
  var userAvatarData;
  var notifcations;
  var notificationCount = 0;
  var mxgCounta = 0;
  var requestedPettyCash = 0;
  var approvedPettyCash = 0;
  var paidPettyCash = 0;
  var unpaidPettyCash = 0;
  var requestedCashAdvance = 0;
  var approvedCashAdvance = 0;
  var paidCashAdvance = 0;
  var unpaidCashAdvance = 0;
  var requestedChequeRequisition = 0;
  var approvedChequeRequisition = 0;
  var paidChequeRequisition = 0;
  var unpaidChequeRequisition = 0;
  bool siginingOut = false;
  String userRole;

  String appVersion = "1.0.1";

  @override
  void initState() {
    _getUserInfo();
    Timer.periodic(Duration(seconds: 30), (timer) {
      _getNotificationCount();
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }

  // Get user information from local storage
  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var userRolesJson = localStorage.getString('userRoles');
    var user = json.decode(userJson);
    var userRoles = json.decode(userRolesJson);
    if (this.mounted) {
      setState(() {
        userData = user[0];
        userId = userData['id'];
        userRolesData = userRoles;
      });
    }
    userRolesData.forEach((a) {
      if (this.mounted) {
        setState(() {
          userRole = a;
        });
      }
    });
  }

  // Get notification count
  Future<Null> _getNotificationCount() async {
    var endPoint = 'usernotifications/unread/user/$userId';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var nots = body["data"].toList();
        //  Set state
        setState(() {
          notificationCount = nots.length;
          _getRegisteredUsers();
          _getPettyCash();
          _getCashAdvance();
          _getChequeRequisition();
          _getMessageCount();
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get List of Registered Users
  Future<Null> _getRegisteredUsers() async {
    var endPoint = 'users/all';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        // Save to local storage
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('listOfUsers', json.encode(body['data']));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get Messages
  Future<Null> _getMessageCount() async {
    var endPoint = 'usermessages/unread/user/$userId';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var nots = body["data"].toList();
        //  Set state
        setState(() {
          mxgCounta = nots.length;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get notification count
  Future<Null> _getPettyCash() async {
    var endPoint = 'expenses/user/$userId/get-all';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var rpc = body["totalRequested"].toString();
        var apc = body["totalApproved"].toString();
        var ppc = body["totalPaid"].toString();
        var upc = body["totalUnpaid"].toString();
        int requestedPc = int.parse(rpc);
        int approvedPc = int.parse(apc);
        int paidPc = int.parse(ppc);
        int unpaidPc = int.parse(upc);
        //  Set state
        setState(() {
          requestedPettyCash = requestedPc;
          approvedPettyCash = approvedPc;
          paidPettyCash = paidPc;
          unpaidPettyCash = unpaidPc;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get notification count
  Future<Null> _getCashAdvance() async {
    var endPoint = 'cashadvances/user/$userId/get-all';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var rca = body["totalRequested"].toString();
        var aca = body["totalApproved"].toString();
        var pca = body["totalPaid"].toString();
        var uca = body["totalUnpaid"].toString();
        int requestedca = int.parse(rca);
        int approvedca = int.parse(aca);
        int paidca = int.parse(pca);
        int unpaidca = int.parse(uca);
        //  Set state
        setState(() {
          requestedCashAdvance = requestedca;
          approvedCashAdvance = approvedca;
          paidCashAdvance = paidca;
          unpaidCashAdvance = unpaidca;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // // Get notification count
  Future<Null> _getChequeRequisition() async {
    var endPoint = 'chequerequisitions/user/$userId/get-all';
    try {
      // Make API call
      var res = await CallApi().getAuthData(endPoint);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var rcr = body["totalRequested"].toString();
        var acr = body["totalApproved"].toString();
        var pcr = body["totalPaid"].toString();
        var ucr = body["totalUnpaid"].toString();
        int requestedcr = int.parse(rcr);
        int approvedcr = int.parse(acr);
        int paidcr = int.parse(pcr);
        int unpaidcr = int.parse(ucr);
        //  Set state
        setState(() {
          requestedChequeRequisition = requestedcr;
          approvedChequeRequisition = approvedcr;
          paidChequeRequisition = paidcr;
          unpaidChequeRequisition = unpaidcr;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Bottom Sheet
  _showModalBottomSheet(
      context, String title, requested, approved, paid, unpaid) {
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.account_balance_wallet,
                              size: 45,
                            ),
                            title: Text(
                              '${egoFormata.format(requested)}',
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Total Amount Requested',
                              style: TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.account_balance_wallet,
                              size: 45,
                              color: capproved,
                            ),
                            title: Text(
                              '${egoFormata.format(approved)}',
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Total Amount Approved',
                              style: TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.account_balance_wallet,
                              size: 45,
                              color: cpaid,
                            ),
                            title: Text(
                              '${egoFormata.format(paid)}',
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Total Amount Paid',
                              style: TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.account_balance_wallet,
                              size: 45,
                              color: cunpaid,
                            ),
                            title: Text(
                              '${egoFormata.format(unpaid)}',
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Total Amount Unpaid',
                              style: TextStyle(
                                fontSize: 16.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).accentColor,
                  onPressed: () {
                    if (title == "Petty Cash") {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PettyCashScreen()));
                    } else if (title == "Cash Advance") {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CashAdvanceScreen()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChequeRequisitionScreen()));
                    }
                  },
                  child: Text(
                    "Visit Page".toUpperCase(),
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
    // AppBar Actions
    List<Widget> actions = List();
    actions.add(
      Badge(
        position: BadgePosition.topRight(top: 10, right: 6),
        badgeContent: Text(
          '$mxgCounta',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        badgeColor: Theme.of(context).accentColor,
        child: IconButton(
            padding: EdgeInsets.only(top: 22, right: 15),
            icon: Icon(
              Icons.message,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MessageScreen()));
            }),
      ),
    );
    actions.add(
      Badge(
        position: BadgePosition.topRight(top: 10, right: 6),
        badgeContent: Text(
          '$notificationCount',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        badgeColor: Theme.of(context).accentColor,
        child: IconButton(
            padding: EdgeInsets.only(top: 22, right: 15),
            icon: Icon(
              Icons.notifications_none,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationScreen()));
            }),
      ),
    );

    // Drawer Items
    List<Widget> drawerItems = List();
    drawerItems.addAll([
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/menutopbg.png"),
          ),
        ),
        accountName: userData != null
            ? Text(
                '${userData['surname']} ${userData['firstname']} ${userData['othernames']}',
                style: TextStyle(color: Theme.of(context).accentColor),
              )
            : Text(''),
        accountEmail: userData != null
            ? Text(
                '${userData['email']}',
                style: TextStyle(color: Theme.of(context).accentColor),
              )
            : Text(''),
        currentAccountPicture: ClipOval(
          child: userData != null
              ? Image.network(
                  '${userData['avatar_id']}',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.person,
                  size: 100,
                ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Manage Profile'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ProfileScreen()));
        },
      ),
      ListTile(
        leading: Icon(Icons.contacts),
        title: Text('Registered Staff'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MyContactScreen()));
        },
      ),
      ListTile(
        leading: Icon(Icons.message),
        title: Text('Message'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => MessageScreen()));
        },
      ),
      ListTile(
        leading: Icon(Icons.notifications),
        title: Text('Notification'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => NotificationScreen()));
        },
      ),
      Divider(),
      ExpansionTile(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Icon(
                Icons.ac_unit,
                color: Theme.of(context).textSelectionColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Petty Cash'),
            ),
          ],
        ),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Petty Cash Request'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PettyCashScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.done_all),
            title: Text('HOD Approval'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PettyCashApprovalHodScreen()));
            },
          ),
        ],
      ),
      ExpansionTile(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Icon(
                Icons.adjust,
                color: Theme.of(context).textSelectionColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Cash Advance'),
            ),
          ],
        ),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cash Advance Request'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => CashAdvanceScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.done_all),
            title: Text('HOD Approval'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PettyCashScreen()));
            },
          ),
        ],
      ),
      ExpansionTile(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Icon(
                Icons.book,
                color: Theme.of(context).textSelectionColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Cheque Requisition'),
            ),
          ],
        ),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cheque Requisition Request'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PettyCashScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.done_all),
            title: Text('HOD Approval'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PettyCashScreen()));
            },
          ),
        ],
      ),
      Divider(),
      // ERMC
      userRole == ermcExecutive
          ? ExpansionTile(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 42.0),
                    child: Text(' '),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('ERM & C Approvals'),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Petty Cash Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cash Advance Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cheque Requisition Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
              ],
            )
          : userRole == ermcOfficer
              ? ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 42.0),
                        child: Text(' '),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('ERM & C Approvals'),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Petty Cash Approval'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Cash Advance Approval'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Cheque Requisition Approval'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                  ],
                )
              : Row(),
      // CS
      userRole == csExecutive
          ? ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('Corporate Services Approval'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PettyCashScreen()));
              },
            )
          : userRole == csOfficer
              ? ListTile(
                  leading: Icon(Icons.people_outline),
                  title: Text('Corporate Services Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                )
              : Row(),
      // FINCON
      userRole == financeExecutive
          ? ExpansionTile(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 42.0),
                    child: Text(' '),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Finance'),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Petty Cash Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Petty Cash Payment'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cash Advance Payment'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cheque Requisition Payment'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
              ],
            )
          : userRole == financeOfficer
              ? ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 42.0),
                        child: Text(' '),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Finance'),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.check),
                      title: Text('Petty Cash Approval'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Petty Cash Payment'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Cash Advance Payment'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.done_all),
                      title: Text('Cheque Requisition Payment'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                  ],
                )
              : Row(),
      // Managing Director
      userRole == manager
          ? ExpansionTile(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 42.0),
                    child: Text(' '),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Managing Director'),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cash Advance Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Cheque Requisition Approval'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
              ],
            )
          : Row(),
      // Reports
      userRole == superAdmin
          ? ExpansionTile(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 22.0),
                    child: Icon(
                      Icons.show_chart,
                      color: Theme.of(context).textSelectionColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Reports'),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.pie_chart),
                  title: Text('Petty Cash'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.pie_chart),
                  title: Text('Cash Advance'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.pie_chart),
                  title: Text('Cheque Requisition'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
              ],
            )
          : userRole == admin
              ? ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 42.0),
                        child: Text(' '),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Reports'),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.pie_chart),
                      title: Text('Petty Cash'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.pie_chart),
                      title: Text('Cash Advance'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.pie_chart),
                      title: Text('Cheque Requisition'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                  ],
                )
              : userRole == hod
                  ? ExpansionTile(
                      title: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 42.0),
                            child: Text(' '),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Reports'),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.pie_chart),
                          title: Text('Petty Cash'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    PettyCashScreen()));
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.pie_chart),
                          title: Text('Cash Advance'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    PettyCashScreen()));
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.pie_chart),
                          title: Text('Cheque Requisition'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    PettyCashScreen()));
                          },
                        ),
                      ],
                    )
                  : userRole == manager
                      ? ExpansionTile(
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 42.0),
                                child: Text(' '),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Reports'),
                              ),
                            ],
                          ),
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.pie_chart),
                              title: Text('Petty Cash'),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PettyCashScreen()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.pie_chart),
                              title: Text('Cash Advance'),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PettyCashScreen()));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.pie_chart),
                              title: Text('Cheque Requisition'),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PettyCashScreen()));
                              },
                            ),
                          ],
                        )
                      : Row(),
      // Settings
      userRole == superAdmin
          ? ExpansionTile(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 22.0),
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).textSelectionColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Settings'),
                  ),
                ],
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Roles & Permission'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('User Management'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Expense Types'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Retirement Types'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.store_mall_directory),
                  title: Text('Departments'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PettyCashScreen()));
                  },
                ),
              ],
            )
          : userRole == admin
              ? ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 22.0),
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(context).textSelectionColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Settings'),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.security),
                      title: Text('Roles & Permission'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text('User Management'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.shuffle),
                      title: Text('Expense Types'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.shuffle),
                      title: Text('Retirement Types'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.store_mall_directory),
                      title: Text('Departments'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PettyCashScreen()));
                      },
                    ),
                  ],
                )
              : Row(),
      Divider(),
      ListTile(
        leading: Icon(Icons.refresh),
        title: Text('Request Password Reset'),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      ListTile(
        leading: Icon(Icons.contact_phone),
        title: Text('Contact Support'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ContactSupportScreen()));
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.power_settings_new,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        onTap: () {
          _doYouWantToSignOut();
          _handleSignOut();
        },
      ),
      Divider(),
      ListTile(
        title: Text(
          'Version: $appVersion',
          style: TextStyle(
              fontSize: 11.0, color: Theme.of(context).textSelectionColor),
          textAlign: TextAlign.right,
        ),
        onTap: () {},
      ),
    ]);

    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: pageTitle('Dashboard'),
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 0.0 : 0.0,
          actions: actions,
        ),
        drawer: Drawer(
          child: ListView(
            children: drawerItems,
          ),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _getNotificationCount,
          child: Stack(
            children: <Widget>[
              Container(
                height: 80.0,
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
                      "Overview of your activities",
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
                margin: EdgeInsets.only(top: 90.0),
                child: DraggableScrollbar.rrect(
                  controller: _scrollController,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: ListView(
                    controller: _scrollController,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15.0,
                          top: 15.0,
                          right: 15.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Quick'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Buttons'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              color: Theme.of(context).accentColor,
                              textColor: Theme.of(context).accentColor,
                              padding: EdgeInsets.all(12),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "Profile",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              color: Theme.of(context).accentColor,
                              textColor: Theme.of(context).accentColor,
                              padding: EdgeInsets.all(12),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ContactSupportScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.contact_phone,
                                    size: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "Support",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15.0,
                          top: 30.0,
                          right: 15.0,
                          bottom: 3.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Transact'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'ions'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Petty Cash
                      Container(
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: InkWell(
                          onTap: () {
                            _showModalBottomSheet(
                                context,
                                "Petty Cash",
                                requestedPettyCash,
                                approvedPettyCash,
                                paidPettyCash,
                                unpaidPettyCash);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5.0,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_balance_wallet,
                                size: 45,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                'Petty Cash',
                                style: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Click to view more',
                                style: TextStyle(
                                  fontSize: 16.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Cash Advance
                      Container(
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: InkWell(
                          onTap: () {
                            _showModalBottomSheet(
                                context,
                                "Cash Advance",
                                requestedCashAdvance,
                                approvedCashAdvance,
                                paidCashAdvance,
                                unpaidCashAdvance);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5.0,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_balance_wallet,
                                size: 45,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                'Cash Advance',
                                style: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Click to view more',
                                style: TextStyle(
                                  fontSize: 16.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Cheque Requisition
                      Container(
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: InkWell(
                          onTap: () {
                            _showModalBottomSheet(
                                context,
                                "Petty Cash",
                                requestedChequeRequisition,
                                approvedChequeRequisition,
                                paidChequeRequisition,
                                unpaidChequeRequisition);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5.0,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_balance_wallet,
                                size: 45,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                'Cheque Requisition',
                                style: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Click to view more',
                                style: TextStyle(
                                  fontSize: 16.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () {
              _doYouWantToSignOut();
              _handleSignOut();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.settings_power,
              color: Theme.of(context).accentColor,
              size: 30.0,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          child: AlertDialog(
            title: Text('Do you want to exit this application?'),
            content: Text(
                'Ensure you have concluded with the current transaction before exiting.'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('NO'),
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: () => SystemNavigator.pop(),
                child: Text('YES'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Sign Out Confirmation
  Future<bool> _doYouWantToSignOut() {
    return showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Processing Request'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    strokeWidth: 5,
                  ),
                  Text('Please wait...'),
                ],
              ),
            )) ??
        false;
  }

  // Handle Sign Out
  Future _handleSignOut() async {
    // Log out from server
    try {
      // Make API call
      var res = await CallApi().getData('signout');
      var body = json.decode(res.body);
      if (body['success']) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('token');
        localStorage.remove('user');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignInPage(),
            ));
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
