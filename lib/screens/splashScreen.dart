import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gct/screens/spinLoading.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'dart:developer' as developer;

import '../providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppProvider _appProvider;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool isOnline = false;

  Future getSharedPrefrences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    print("shared :: ${sharedPreferences.getString('credentials')}");
    
    try {
      if (sharedPreferences.getString('credentials') == '' ||
          sharedPreferences.getString('credentials') == null) {
        Navigator.pushNamed(context, '/login');
      } else {
        Navigator.pushNamed(context, '/login');
      }
    } catch (error) {
      print("error Log In");
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // initScreen();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      try {
        final check = await InternetAddress.lookup('www.google.com');
        if (check.isNotEmpty && check[0].rawAddress.isNotEmpty) {
          setState(() {
            isOnline = true;
          });
        }
      } on SocketException catch (_) {
        setState(() {
          isOnline = false;
       });
      }
    }
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
        body: isOnline
            ? const LoadingSpin()
            : Container(color: Colors.black87,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                 Text("checking for internet Connection ...",style: TextStyle(fontSize: 14,color: Colors.white38),), ],)));
  }
}
