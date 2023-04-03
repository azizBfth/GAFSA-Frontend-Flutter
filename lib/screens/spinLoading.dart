import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gct/api/api_services.dart';
import 'package:gct/screens/homeArgs.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'dart:convert';

import '../providers/app_provider.dart';



class LoadingSpin extends StatefulWidget {
  const LoadingSpin({Key? key}) : super(key: key);

  @override
  _LoadingSpinState createState() => _LoadingSpinState();
}

class _LoadingSpinState extends State<LoadingSpin> {
  late AppProvider _appProvider;
  late int _tripsLength = 0;
  late int _tripsByTimeLength = 0;

  int scrollIndex = 0;



  Future<void> initScreen() async {
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    await GctClientService(appProvider: _appProvider)
        .getAccidents()
        .then((value) => {

              Navigator.pushNamed(context, '/myHome' ),
              
            });

  }



  @override
  void initState() {
    super.initState();
    //  navigate();
    initScreen();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _appProvider = Provider.of<AppProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: SpinKitFadingFour(
            color: Colors.blue,
            size: 50.0,
          ),
        ),
      ),
    );
  }
}
