import 'package:Expense/UI/shared/general.dart';
import 'package:Expense/UI/shared/ggma.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatefulWidget {
  @override
  _ContactSupportScreenState createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  String reachoutTitle = "Need to get in touch?";
  String reachout =
      "We would love to hear from you! Please use any of our contact medium to reach out and we will respond as soon as possible.";

  // make call;
  _makeCall(String number) async {
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not launch $number';
    }
  }

  // send SMS;
  _sendSms(String number) async {
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not launch $number';
    }
  }

  // send Email;
  _sendEmail(String email) async {
    if (await canLaunch(email)) {
      await launch(email);
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: innerPageTitle('App Support'),
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
                  "Contact Admin and IT Staff",
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
            margin: EdgeInsets.only(top: 65.0),
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            reachoutTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            reachout,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(
                            'Human Resources',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 14.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: InkWell(
                                    onTap: () => _makeCall('tel:$hrNumber'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.phone,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          hrNumber,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendSms('sms:$hrNumber'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.message,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          hrNumber,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendEmail('mailto:$hrEmail'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          hrEmail,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(
                            'Corporate Services',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 14.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: InkWell(
                                    onTap: () => _makeCall('tel:$csNumber'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.phone,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          csNumber,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendSms('sms:$csNumber'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.message,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          csNumber,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendEmail('mailto:$csEmail'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          csEmail,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(
                            'Developer: Ernest Ibeh',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 14.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: InkWell(
                                    onTap: () => _makeCall('tel:$dev1Number'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.phone,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev1Number,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendSms('sms:$dev1Number'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.message,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev1Number,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendEmail('mailto:$dev1Email'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev1Email,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(
                            'Developer: Chika Enemuo',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 14.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: InkWell(
                                    onTap: () => _makeCall('tel:$dev2Number'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.phone,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev2Number,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendSms('sms:$dev2Number'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.message,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev2Number,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: InkWell(
                                    onTap: () => _sendEmail('mailto:$dev2Email'),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          dev2Email,
                                          style: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
