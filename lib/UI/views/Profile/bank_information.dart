import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/ggma.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/core/models/bank.dart';
import 'package:Expense/core/services/api.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BankInformationScreen extends StatefulWidget {
  @override
  _BankInformationScreenState createState() => _BankInformationScreenState();
}

class _BankInformationScreenState extends State<BankInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  int userId;
  int bankCount = 0;
  String bankName;
  String accountType;
  String accountNumber;
  String bvn;

  String success = '';
  String error = '';
  bool loading = false;
  bool editBank = false;

  AutoCompleteTextField searchBankTextField;
  GlobalKey<AutoCompleteTextFieldState> bankKey = GlobalKey();
  AutoCompleteTextField searchAccountTypeTextField;
  GlobalKey<AutoCompleteTextFieldState> accounTypeKey = GlobalKey();

  var userData;

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

  // Update account
  Future<Null> _setPreferredAccount(int id, int userId) async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
    var endPoint = 'userbanks/user/$userId/bank/set-preferred';

    var data = {"bank_id": id};

    try {
      var res = await CallApi().putAuthData(data, endPoint);
      print(res.statusCode);
      if (res.statusCode == 200) {
        print('object');
        if (this.mounted) {
          setState(() {
            fetchBanks();
            loading = false;
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Add new bank account
  void _addNewBankAccount() async {
    if (_formKey.currentState.validate()) {
      if (this.mounted) {
        setState(() {
          loading = true;
        });
      }

      var data = {
        'name': bankName,
        'account_type': accountType,
        'account_number': accountNumber,
        'bvn': bvn,
      };

      // Make API call
      var endPoint = 'userbanks';
      var result = await CallApi().postAuthData(data, endPoint);
      print(result.statusCode);
      if (result.statusCode == 201) {
        if (this.mounted) {
          setState(() {
            fetchBanks();
            loading = false;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            error = 'Authentication failed, please supply valid credential';
            loading = false;
          });
        }
      }
    }
  }

  String validateAccountName(String value) {
    if (value.length < 3) {
      return 'Account name is required';
    } else {
      return null;
    }
  }

  String validateAccountType(String value) {
    if (value.length < 6) {
      return 'Account type is required';
    } else {
      return null;
    }
  }

  String validateAccountNumber(String value) {
    if (value.length < 9) {
      return 'Account number is invalid';
    } else if (value.length > 10) {
      return 'Account number exceeded';
    } else {
      return null;
    }
  }

  String validateBvnNumber(String value) {
    if (value.length < 10) {
      return 'Bank verification number is incomplete';
    } else if (value.length > 11) {
      return 'Bank verification number is exceeded';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add bank account form
    void _addBankAccountForm() {
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
                              searchBankTextField = AutoCompleteTextField(
                                key: bankKey,
                                clearOnSubmit: false,
                                suggestions: offcialBanks,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                  hintText: 'Select your bank',
                                  labelText: 'Bank',
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
                                    searchBankTextField
                                        .textField.controller.text = item;
                                    bankName = item;
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
                                child: error != ''
                                    ? Text(
                                        error,
                                        style: TextStyle(color: cred),
                                      )
                                    : Text(''),
                              ),
                              searchAccountTypeTextField =
                                  AutoCompleteTextField(
                                key: accounTypeKey,
                                clearOnSubmit: false,
                                suggestions: accountTypes,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                  hintText: 'Select your bank account type',
                                  labelText: 'Account Type',
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
                                    searchAccountTypeTextField
                                        .textField.controller.text = item;
                                    accountType = item;
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
                                child: error != ''
                                    ? Text(
                                        error,
                                        style: TextStyle(color: cred),
                                      )
                                    : Text(''),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Bank Account Number',
                                  labelText: 'Account Number',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                keyboardType: TextInputType.number,
                                validator: validateAccountNumber,
                                onChanged: (val) {
                                  setState(() => accountNumber = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: error != ''
                                    ? Text(
                                        error,
                                        style: TextStyle(color: cred),
                                      )
                                    : Text(''),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Bank Verification Number',
                                  labelText: 'BVN',
                                  labelStyle: TextStyle(
                                      color:
                                          Theme.of(context).textSelectionColor),
                                ),
                                validator: validateBvnNumber,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => bvn = val);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 5.0, right: 8.0),
                                child: error != ''
                                    ? Text(
                                        error,
                                        style: TextStyle(color: cred),
                                      )
                                    : Text(''),
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
                      _addNewBankAccount();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: FutureBuilder(
            future: fetchBanks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
              }
              return snapshot.hasData
                  ? loading
                      ? Loading()
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            var bankData = snapshot.data[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 10.0),
                              child: bankData != null
                                  ? Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      color: bankData.isPreferred != 'YES'
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context).primaryColor,
                                      elevation: 10,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(
                                              Icons.business,
                                              size: 70.0,
                                              color:
                                                  bankData.isPreferred != 'YES'
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .accentColor,
                                            ),
                                            title: Text(
                                              bankData.name,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                color: bankData.isPreferred !=
                                                        'YES'
                                                    ? Theme.of(context)
                                                        .textSelectionColor
                                                    : Theme.of(context)
                                                        .accentColor,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Type: ',
                                                      style: TextStyle(
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      bankData.accountType,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Number: ',
                                                      style: TextStyle(
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      bankData.accountNumber,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Status: ',
                                                      style: TextStyle(
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      bankData.accountStatus,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: bankData
                                                                    .isPreferred !=
                                                                'YES'
                                                            ? Theme.of(context)
                                                                .textSelectionColor
                                                            : Theme.of(context)
                                                                .accentColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          ButtonBar(
                                            alignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              bankData.isPreferred != 'YES'
                                                  ? FlatButton(
                                                      child: Text(
                                                        'SET AS PREFERRED ACCOUNT',
                                                        semanticsLabel:
                                                            'Set as default account',
                                                      ),
                                                      textColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      onPressed: () {
                                                        _setPreferredAccount(
                                                          bankData.id,
                                                          bankData.userId,
                                                        );
                                                      },
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16.0,
                                                              bottom: 16.0),
                                                      child: Text(
                                                        'PREFERRED ACCOUNT',
                                                        style: TextStyle(
                                                          color: bankData
                                                                      .isPreferred !=
                                                                  'YES'
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : '',
                            );
                          },
                          itemCount: snapshot.data.length,
                        )
                  : Loading();
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            _addBankAccountForm();
          },
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.business,
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
