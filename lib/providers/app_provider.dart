import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gct/models/accidents.dart';

class AppProvider with ChangeNotifier {
  late bool isLoggedIn = false;
  List<Accidents> _accidents = [];
  


  bool _loadingAssets = false;
  bool switchToPub = false;



  setAccidents(accidents) {
    _accidents = accidents;
    notifyListeners();
  }

  List<Accidents> getAccidents() => _accidents;



  setloadingAssets(loading) {
    _loadingAssets = loading;
    notifyListeners();
  }

  get loadingAsset => _loadingAssets;


 

}
