import 'package:Expense/UI/shared/color.dart';
import 'package:Expense/UI/shared/loading.dart';
import 'package:Expense/UI/views/Message/compose_message.dart';
import 'package:Expense/core/models/all_users.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyContactScreen extends StatefulWidget {
  static const String routeName = '/material/search';

  @override
  _MyContactScreenState createState() => _MyContactScreenState();
}

class _MyContactScreenState extends State<MyContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  var appPageName = 'Registered Staff';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // AppBar Actions
    List<Widget> actions = List();
    actions.add(
      IconButton(
        tooltip: 'Search users list by their firstname',
        icon: Icon(Icons.search),
        onPressed: () async {
          showSearch(
            context: context,
            delegate: RegisteredUsersSearch(fetchAllUsers()),
          );
        },
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          appPageName,
          style: TextStyle(fontSize: 20.0),
        ),
        actions: actions,
      ),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: FutureBuilder(
          future: fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
            }
            return snapshot.hasData
                ? RegisteredUsersList(allRegisteredUsers: snapshot.data)
                : Loading();
          },
        ),
      ),
    );
  }
}

class RegisteredUsersList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<AllUsers> allRegisteredUsers;
  // Constructor
  RegisteredUsersList({Key key, this.allRegisteredUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.rrect(
      controller: _scrollController,
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          var userData = allRegisteredUsers[index];
          var nameInitial = userData.surname[0].toUpperCase();
          if (userData.avatarUrl.length > 0) {
            nameInitial = "";
          }

          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: userData != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: clitegrey,
                            foregroundColor: cprimary,
                            backgroundImage: NetworkImage(userData.avatarUrl),
                            radius: 25.0,
                            child: Text(
                              nameInitial,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          ),
                          title: Text(
                              userData.surname + '  ' + userData.firstname),
                          subtitle: Text(
                            userData.email,
                            style: TextStyle(fontSize: 12.0),
                          ),
                          trailing: Text(
                            userData.phoneNumber,
                            style: TextStyle(fontSize: 14.0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComposeMessageScreen(
                                    recepientInfo: userData),
                              ),
                            );
                          },
                        )
                      : '',
                ),
              ),
            ),
          );
        },
        itemCount: allRegisteredUsers.length,
      ),
    );
  }
}

class RegisteredUsersSearch extends SearchDelegate<AllUsers> {
  final Future<List<AllUsers>> regUsers;

  RegisteredUsersSearch(this.regUsers);

  @override
  List<Widget> buildActions(BuildContext context) {
    // Widgets to display after the search query in the appbar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // A widget to display before the current query in the appBar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // The results shown after the user submits a search from the search page
    return FutureBuilder(
      future: fetchAllUsers(),
      builder: (context, AsyncSnapshot<List<AllUsers>> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (!snapshot.hasData) {
          return Loading();
        } else {
          // final results = snapshot.data;
          final results = snapshot.data.where((item) => item.surname.toLowerCase().contains(query));

          return ListView(
            children: results
                .map<ListTile>((a) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: clitegrey,
                        foregroundColor: cprimary,
                        backgroundImage: NetworkImage(a.avatarUrl),
                        radius: 25.0,
                        child: Text(
                          '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                      ),
                      title: Text(a.surname + '  ' + a.firstname),
                      subtitle: Text(
                        a.email,
                        style: TextStyle(fontSize: 12.0, color: cgrey),
                      ),
                      trailing: Text(
                        a.phoneNumber,
                        style: TextStyle(fontSize: 14.0, color: cgrey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ComposeMessageScreen(recepientInfo: a),
                          ),
                        );
                        // close(context, a);
                      },
                    ))
                .toList(),
          );
          // return RegisteredUsersList(allRegisteredUsers: results);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions shown in the body of the search page while the user types a query into the search field
    return FutureBuilder(
      future: fetchAllUsers(),
      builder: (context, AsyncSnapshot<List<AllUsers>> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (!snapshot.hasData) {
          return Loading();
        } else {
          // final results = snapshot.data;
          final results = snapshot.data.where((item) => item.surname.toLowerCase().contains(query));

          return ListView(
            children: results
                .map<ListTile>((a) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: clitegrey,
                        foregroundColor: cprimary,
                        backgroundImage: NetworkImage(a.avatarUrl),
                        radius: 25.0,
                        child: Text(
                          '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                      ),
                      title: Text(a.surname + '  ' + a.firstname),
                      subtitle: Text(
                        a.email,
                        style: TextStyle(fontSize: 12.0, color: cgrey),
                      ),
                      trailing: Text(
                        a.phoneNumber,
                        style: TextStyle(fontSize: 14.0, color: cgrey),
                      ),
                      onTap: () {
                        // query = a.surname + ' ' + a.firstname;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ComposeMessageScreen(recepientInfo: a),
                          ),
                        );
                      },
                    ))
                .toList(),
          );
          // return RegisteredUsersList(allRegisteredUsers: results);
        }
      },
    );
  }
}
