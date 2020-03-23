import 'dart:async';
import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/countries.dart';
import 'package:Expense/UI/shared/ggma.dart';
import 'package:Expense/UI/shared/lgas.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/UI/shared/nigeria_states.dart';
import 'package:Expense/core/services/api.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInformationScreen extends StatefulWidget {
  @override
  _ProfileInformationScreenState createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  int userId;
  int profileId;
  String _selectedGrade = '';
  String _selectedQualification = '';
  String trackerLine = '';
  String _selectedGender = '';
  String dob = '';
  String _selectedMaritalStatus = '';
  String address = '';
  String _selectedCountry = '';
  String _selectedSoo = '';
  String _selectedLga = '';
  String secondaryEmail = '';
  String _selectedPrefTheme = '';
  int userAge = 0;
  var upr;

  String success = '';
  String error = '';
  bool loading = false;
  bool editProfileInfo = false;
  bool editImage = false;
  bool editPassword = false;
  bool editBankInfo = false;
  bool editPin = false;

  var userData;
  var userProfileData;
  var userRolesData;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    var curAge;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var userRolesJson = localStorage.getString('userRoles');
    var userProfileJson = localStorage.getString('userProfile');
    var user = json.decode(userJson);
    var userRoles = json.decode(userRolesJson);
    var userProfile = json.decode(userProfileJson);
    // Calculate User Age
    if (userProfile['dob'] != null) {
      var newDateTimeObj = DateTime.parse(userProfile['dob'] + ' 00:00:00.000');
      curAge = calculateAge(newDateTimeObj);
    }
    if (this.mounted) {
      setState(() {
        userData = user[0];
        userId = userData['id'];
        userRolesData = userRoles;
        userProfileData = userProfile;
        // Assign values to profile form
        if (userProfileData != null) {
          profileId = userProfileData['id'];
          _selectedGrade = userProfileData['grade'];
          _selectedQualification = userProfileData['qualification'];
          _selectedGender = userProfileData['gender'];
          _selectedMaritalStatus = userProfileData['marital_status'];
          trackerLine = userProfileData['tracker_line'];
          dob = userProfileData['dob'];
          _selectedCountry = userProfileData['country'];
          _selectedSoo = userProfileData['soo'];
          _selectedLga = userProfileData['lga'];
          address = userProfileData['address'];
          secondaryEmail = userProfileData['secondary_email'];
          _selectedPrefTheme = userProfileData['pref_theme'];
          userAge = curAge;
        }
      });
    }
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  // final TextEditingController _controller = new TextEditingController();

  AutoCompleteTextField searchGradeTextField;
  AutoCompleteTextField searchQualificationTextField;
  AutoCompleteTextField searchGenderTextField;
  AutoCompleteTextField searchMaritalTextField;
  AutoCompleteTextField searchCountryTextField;
  AutoCompleteTextField searchStateTextField;
  AutoCompleteTextField searchLgaTextField;
  GlobalKey<AutoCompleteTextFieldState> gradeKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> genderKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> maritalKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> qualificationKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> countryKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> stateKey = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState> lgaKey = GlobalKey();

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }

  Future _selectDate() async {
    var newDob;
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2003),
        firstDate: DateTime(1940),
        lastDate: DateTime(2004));
    if (picked != null) {
      newDob = picked.toString().split(" ");
      if (this.mounted) {
        setState(() => dob = newDob[0]);
      }
    }
  }

  // Switch between edit and view profile
  void _manageProfile() {
    if (editProfileInfo) {
      setState(() {
        editProfileInfo = false;
      });
    } else {
      if (this.mounted) {
        setState(() {
          editProfileInfo = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'PROFILE INFO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                editProfileInfo
                    ? RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).accentColor,
                        ), //`Icon` to display
                        label: Text(
                          'Cancel'.toUpperCase(),
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ), //`Text` to display
                        onPressed: _manageProfile,
                      )
                    : RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).accentColor,
                        ), //`Icon` to display
                        label: Text(
                          'Edit'.toUpperCase(),
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ), //`Text` to display
                        onPressed: _manageProfile,
                      ),
              ],
            ),
          ),
          editProfileInfo
              ? Form(
                  key: _formKey,
                  autovalidate: true,
                  child: profileFormInterface(),
                )
              : userProfileData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: success != ''
                              ? Text(
                                  success,
                                  style: TextStyle(color: cteal),
                                )
                              : Text(''),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.supervisor_account,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['grade']),
                          subtitle: Text(
                            'Official Grade',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.card_membership,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['qualification']),
                          subtitle: Text(
                            'Academic Qualification',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.wc,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['gender']),
                          subtitle: Text(
                            'Gender',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.pregnant_woman,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['marital_status']),
                          subtitle: Text(
                            'Marital Status',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.phone,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['tracker_line']),
                          subtitle: Text(
                            'Tracker Line / Phone Number',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['dob']),
                          subtitle: Text(
                            'Date Of Birth',
                            style: TextStyle(fontSize: 11.0),
                          ),
                          trailing: Text(
                            '$userAge years old',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.phone,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['tracker_line']),
                          subtitle: Text(
                            'Tracker Line / Phone Number',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.flag,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['country']),
                          subtitle: Text(
                            'Country Of Residence',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.pin_drop,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['soo']),
                          subtitle: Text(
                            'State Of Origin',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.person_pin,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['lga']),
                          subtitle: Text(
                            'Local Government Area',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.home,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['address']),
                          subtitle: Text(
                            'Contact Address',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            size: 30.0,
                          ),
                          title: Text(userProfileData['secondary_email']),
                          subtitle: Text(
                            'Secondary Email Address',
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: editProfileInfo
                                ? RaisedButton.icon(
                                    color: clitegrey,
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Theme.of(context).accentColor,
                                    ), //`Icon` to display
                                    label: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                    ), //`Text` to display
                                    onPressed: _manageProfile,
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Theme.of(context).accentColor,
                                      onPressed: _manageProfile,
                                      child: Text(
                                        "Edit Profile Info".toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                          'Click the edit button to update profile information.'),
                    ),
        ],
      ),
    );
  }

  // Form User Interface
  Widget profileFormInterface() {
    return loading
        ? Loading()
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                searchGradeTextField = AutoCompleteTextField(
                  key: gradeKey,
                  clearOnSubmit: false,
                  suggestions: officialGrades,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.supervisor_account,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Select your grade',
                    labelText: 'Official Grade',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchGradeTextField.textField.controller.text = item;
                      _selectedGrade = item;
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
                searchQualificationTextField = AutoCompleteTextField(
                  key: qualificationKey,
                  clearOnSubmit: false,
                  suggestions: academicQualifications,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.card_membership,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Select highest academic qualification',
                    labelText: 'Academic Qualification',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchQualificationTextField.textField.controller.text =
                          item;
                      _selectedQualification = item;
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
                searchGenderTextField = AutoCompleteTextField(
                  key: genderKey,
                  clearOnSubmit: false,
                  suggestions: genders,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.wc,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Select your gender',
                    labelText: 'Gender',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchGenderTextField.textField.controller.text = item;
                      _selectedGender = item;
                    });
                  },
                  itemBuilder: (context, item) {
                    // UI for the autocompplete row
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
                searchMaritalTextField = AutoCompleteTextField(
                  key: maritalKey,
                  clearOnSubmit: false,
                  suggestions: maritalStatus,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.pregnant_woman,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Select your marital status',
                    labelText: 'Marital Status',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchMaritalTextField.textField.controller.text = item;
                      _selectedMaritalStatus = item;
                    });
                  },
                  itemBuilder: (context, item) {
                    // UI for the autocompplete row
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.phone,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Official Tracker Line / Phone Number',
                    labelText: 'Tracker Line / Phone Number',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  onChanged: (val) {
                    setState(() => trackerLine = val);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: RaisedButton.icon(
                        color: clitegrey,
                        icon: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).textSelectionColor,
                        ), //`Icon` to display
                        label: Text(
                          'Select Birth Date',
                          style: TextStyle(
                            color: Theme.of(context).textSelectionColor,
                          ),
                        ), //`Text` to display
                        onPressed: _selectDate,
                      ),
                    ),
                    Text(
                      dob,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textSelectionColor),
                    ),
                  ],
                ),
                searchCountryTextField = AutoCompleteTextField(
                  key: countryKey,
                  clearOnSubmit: false,
                  suggestions: allCountries,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.flag,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Type to select your country of residence',
                    labelText: 'Country Of Residence',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchCountryTextField.textField.controller.text = item;
                      _selectedCountry = item;
                    });
                  },
                  itemBuilder: (context, item) {
                    // UI for the autocompplete row
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
                searchStateTextField = AutoCompleteTextField(
                  key: stateKey,
                  clearOnSubmit: false,
                  suggestions: allStates,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.pin_drop,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Type to select your state of origin',
                    labelText: 'State Of Origin',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchStateTextField.textField.controller.text = item;
                      _selectedSoo = item;
                    });
                  },
                  itemBuilder: (context, item) {
                    // UI for the autocompplete row
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
                searchLgaTextField = AutoCompleteTextField(
                  key: lgaKey,
                  clearOnSubmit: false,
                  suggestions: allLgas,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person_pin,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Type to select your local government area',
                    labelText: 'Local Government Area',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  itemFilter: (item, query) {
                    return item.toLowerCase().startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.compareTo(b);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchLgaTextField.textField.controller.text = item;
                      _selectedLga = item;
                    });
                  },
                  itemBuilder: (context, item) {
                    // UI for the autocompplete row
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.home,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Enter your contact address',
                    labelText: 'Contact Address',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  maxLines: 2,
                  onChanged: (val) {
                    setState(() => address = val);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.email,
                      color: Theme.of(context).textSelectionColor,
                    ),
                    hintText: 'Enter a email address',
                    labelText: 'Secondary Email',
                    labelStyle:
                        TextStyle(color: Theme.of(context).textSelectionColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  // validator: (value) => isValidEmail(value)
                  //     ? null
                  //     : 'Please enter a valid email address',
                  onChanged: (val) {
                    setState(() => secondaryEmail = val);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: error != ''
                      ? Text(
                          error,
                          style: TextStyle(color: cred),
                        )
                      : Text(''),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).accentColor,
                    onPressed: _handleSaveChanges,
                    child: Text(
                      "Save Changes".toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  // Handle Profile Saving
  void _handleSaveChanges() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);

      // Get User ID
      userId = userData['id'];
      // Get Profile ID
      if (userProfileData != null) {
        profileId = userProfileData['id'];
      }

      // Save new record if profile does not exist
      if (userProfileData != null) {
        // Update Existing record
        var data = {
          'id': profileId,
          'user_id': userId,
          'grade': _selectedGrade,
          'qualification': _selectedQualification,
          'tracker_line': trackerLine,
          'gender': _selectedGender,
          'dob': dob,
          'marital_status': _selectedMaritalStatus,
          'address': address,
          'country': _selectedCountry,
          'soo': _selectedSoo,
          'lga': _selectedLga,
          'secondary_email': secondaryEmail,
          'pref_theme': _selectedPrefTheme
        };

        // Make API call
        var endPoint = 'profiles/user/$userId/update';
        var result = await CallApi().putAuthData(data, endPoint);
        if (result.statusCode == 201) {
          var body = json.decode(result.body);
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString('userProfile', json.encode(body['data']));
          var userProfileJson = localStorage.getString('userProfile');
          upr = json.decode(userProfileJson);
          _getUserInfo();
          setState(() {
            success = 'Profile successfully updated';
            loading = false;
            editProfileInfo = false;
          });
        } else {
          setState(() {
            error = 'Update failed, do try again and supply only valid data';
            loading = false;
          });
        }
      } else {
        var data = {
          'user_id': userId,
          'grade': _selectedGrade,
          'qualification': _selectedQualification,
          'tracker_line': trackerLine,
          'gender': _selectedGender,
          'dob': dob,
          'marital_status': _selectedMaritalStatus,
          'address': address,
          'country': _selectedCountry,
          'soo': _selectedSoo,
          'lga': _selectedLga,
          'secondary_email': secondaryEmail,
          'pref_theme': _selectedPrefTheme
        };

        // Make API call
        var endPoint = '$userId/profile';
        var result = await CallApi().postAuthData(data, endPoint);
        print(json.decode(result.body));
        if (result.statusCode == 201) {
          var body = json.decode(result.body);
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString('userProfile', json.encode(body['data']));
          var userProfileJson = localStorage.getString('userProfile');
          upr = json.decode(userProfileJson);
          _getUserInfo();
          setState(() {
            success = 'Profile successfully updated';
            loading = false;
            editProfileInfo = false;
          });
        } else {
          setState(() {
            error = 'Update failed, do try again and supply only valid data';
            loading = false;
          });
        }
      }
    }
  }
}
