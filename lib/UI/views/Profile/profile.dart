import 'dart:convert';

import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/views/Profile/bank_information.dart';
import 'package:Expense/UI/views/Profile/display_picture.dart';
import 'package:Expense/UI/views/Profile/password_change.dart';
import 'package:Expense/UI/views/Profile/pin_change.dart';
import 'package:Expense/UI/views/Profile/profile_information.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:truncate/truncate.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String pageAppTitle = 'Profile Management';

  var userData;
  int userId;
  var userRolesData;

  @override
  void initState() {
    this._getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var userRolesJson = localStorage.getString('userRoles');
    var user = json.decode(userJson);
    var userRoles = json.decode(userRolesJson);
    setState(() {
      userData = user[0];
      userId = userData['id'];
      userRolesData = userRoles;
    });
  }

  List<Widget> _tabMenus() => [
        Tab(
          text: "Profile",
          icon: Icon(Icons.person),
        ),
        Tab(
          text: "Image",
          icon: Icon(Icons.image),
        ),
        Tab(
          text: "Login",
          icon: Icon(Icons.security),
        ),
        Tab(
          text: "Bank",
          icon: Icon(Icons.business),
        ),
        Tab(
          text: "PIN",
          icon: Icon(Icons.lock),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: DefaultTabController(
        length: _tabMenus().length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    pageAppTitle,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  background: Padding(
                    padding: const EdgeInsets.only(top: 58.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Name section
                        userData != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 28.0, top: 7.0),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(userData['avatar_id']),
                                      backgroundColor: cwhite,
                                      minRadius: 33.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          truncate(
                                              userData['surname'] +
                                                  ' ' +
                                                  userData['firstname'],
                                              20,
                                              omission: '...',
                                              position: TruncatePosition.end),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22.0,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.security,
                                                size: 17,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  truncate(userRolesData[0], 20,
                                                      omission: '...',
                                                      position:
                                                          TruncatePosition.end),
                                                  style: TextStyle(
                                                    wordSpacing: 2,
                                                    letterSpacing: 2,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Shimmer.fromColors(
                                baseColor: cwhite,
                                highlightColor: credl5,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 5.0, 10.0, 0.0),
                                      child: Icon(Icons.person_pin),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 160.0,
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                              color: clitegrey,
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Container(
                                          width: 160.0,
                                          height: 10.0,
                                          decoration: BoxDecoration(
                                              color: clitegrey,
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        // Contact Section
                        Container(
                          height: 80,
                          padding: EdgeInsets.only(
                            left: 38.0,
                            right: 38.0,
                            top: 15.0,
                            bottom: 12.0,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              var user = userData;
                              return user != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              user['email'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            Text(
                                              'Email Address',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Container(
                                          color: cwhite,
                                          width: 0.2,
                                          height: 24.0,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              user['phone_number'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            Text(
                                              'Phone Number',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Text('');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: cgrey,
                    labelStyle: TextStyle(fontSize: 13),
                    tabs: _tabMenus(),
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              ProfileInformationScreen(),
              DisplayPictureScreen(),
              PasswordChangeScreen(),
              BankInformationScreen(),
              PinChangeScreen(),
            ],
          ),
        ),
      ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34.0)),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
