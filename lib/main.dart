import 'package:Expense/UI/shared/color.dart';
// import 'package:Expense/blocs/theme.dart';
import 'package:Expense/builder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

final ThemeData _icmsLightTheme = _buildLightTheme();
// final ThemeData _icmsDarkTheme = _buildDarkTheme();

ThemeData _buildLightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: caccent,
    primaryColor: cprimary,
    buttonColor: caccent,
    scaffoldBackgroundColor: cscaffold,
    cardColor: cwhite,
    textSelectionColor: cgrey,
    errorColor: cred,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.accent,
    ),
    primaryIconTheme: base.iconTheme.copyWith(color: caccent),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: TextTheme(title: TextStyle(color: caccent)),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base
    .copyWith(
      headline: base.headline.copyWith(
        fontWeight: FontWeight.w500,
      ),
      title: base.title.copyWith(fontSize: 18.0),
      caption: base.caption.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      ),
      body2: base.body2.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      ),
    )
    .apply(
      fontFamily: 'Quicksand',
      displayColor: ctext,
      bodyColor: ctext,
    );
}

// ThemeData _buildDarkTheme() {
//   final ThemeData base = ThemeData.dark();
//   return base.copyWith(
//     accentColor: cdarkaccent,
//     primaryColor: cdarkprimary,
//     buttonColor: cdarkprimary,
//     scaffoldBackgroundColor: cdarkscaffoldcolor,
//     cardColor: cdarkcardcolor,
//     textSelectionColor: clitegrey,
//     errorColor: cred,
//     buttonTheme: ButtonThemeData(
//       textTheme: ButtonTextTheme.accent,
//     ),
//     primaryIconTheme: base.iconTheme.copyWith(color: cwhite),
//     textTheme: _buildDarkTextTheme(base.textTheme),
//     primaryTextTheme: TextTheme(title: TextStyle(color: cwhite)),
//     accentTextTheme: _buildDarkTextTheme(base.accentTextTheme),
//   );
// }

// TextTheme _buildDarkTextTheme(TextTheme base) {
//   return base
//     .copyWith(
//       headline: base.headline.copyWith(
//         fontWeight: FontWeight.w500,
//       ),
//       title: base.title.copyWith(fontSize: 18.0),
//       caption: base.caption.copyWith(
//         fontWeight: FontWeight.w400,
//         fontSize: 14.0,
//       ),
//       body2: base.body2.copyWith(
//         fontWeight: FontWeight.w500,
//         fontSize: 16.0,
//       ),
//     )
//     .apply(
//       fontFamily: 'Quicksand',
//       displayColor: cwhite,
//       bodyColor: cwhite,
//     );
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Prevent screen from rotating
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _icmsLightTheme,
      home: BuilderPage(),
    );
  }
}
