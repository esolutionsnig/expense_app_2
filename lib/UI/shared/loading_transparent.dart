import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingTransparent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: SpinKitRipple(
          color: Theme.of(context).primaryColor,
          size: 150.0,
        ),
      ),
    );
  }
}