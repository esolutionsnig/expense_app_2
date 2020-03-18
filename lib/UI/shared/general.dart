import 'package:flutter/material.dart';

// Header Image
Widget header(String imageLocation) {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imageLocation),
        fit: BoxFit.cover,
      ),
    ),
    alignment: Alignment.center,
    padding: EdgeInsets.only(
      top: 150.0,
      bottom: 100.0,
    ),
  );
}

// Page Title
Widget title(BuildContext context) {
  return Container(
    child: Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'EXPENSE',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'APP',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '.',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Page Title
Widget pageTitle(String title) {
  return Center(
    child: Padding(
      padding: EdgeInsets.only(
        top: 25.0,
        bottom: 5.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          // color: cwhite,
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

// Page Title Bold
Widget pageHeaderBold(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 25.0,
      fontWeight: FontWeight.w700,
    ),
  );
}

// Page Title
Widget pageHeader(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 25.0,
    ),
  );
}
