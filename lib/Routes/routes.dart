import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/homeArgs.dart';
import '../screens/home_page.dart';
import '../screens/spinLoading.dart';
import '../screens/splashScreen.dart';



class routeGenerator {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    final args = setting.arguments;
    switch (setting.name) {
      case '/loadingSpin':
        return MaterialPageRoute(builder: (_) => LoadingSpin());
        case '/checkConnection':
        return MaterialPageRoute(builder: (_) => SplashScreen());
 
case '/myHome':
    return CupertinoPageRoute(builder: (BuildContext context) {
          return MyHomePage(
           
          );
        });
        
    
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
