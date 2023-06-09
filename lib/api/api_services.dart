import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gct/models/accidents.dart';
import 'package:gct/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

//import '../traccar_client/traccar_client.dart';

class GctClientService {
  final AppProvider appProvider;
  final _dio = Dio();

  late Accidents accidents;

  GctClientService({required this.appProvider});

  Future<List<Accidents>> getAccidents() async {
    String uri = "http://gctapp.emkatech.tn/accidents";
    try {
      var response = await Dio().get(
        uri,
        options: Options(
          contentType: "application/json",
          headers: <String, dynamic>{
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final accidents = <Accidents>[];
        //   print("RESPONSE:${response.data.length}");
        //  for (final data in response.data) {
        var item = Accidents.fromJson(response.data as Map<String, dynamic>);
        accidents.add(item);
        print("ITEM TOTAL JRS:: ${item.nbr_totale_accidents}");
        //  }

        appProvider.setAccidents(accidents);

        return accidents;
      } else {
        throw Exception("Unexpected Happened !");
      }
    } catch (error) {
      print("Error:$error");

      return appProvider.getAccidents();
    }
  }

  Future<bool> updateAccident({required accidentId, required data}) async {
    String uri = "http://gctapp.emkatech.tn/accidents/$accidentId";
    // final queryParameters = <String, dynamic>{"id": maintenanceId};
    try {
      var response = await Dio().put(
        uri,
        data: data,
        //  queryParameters: queryParameters,
        options: Options(
          contentType: "application/json",
          headers: <String, dynamic>{
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.statusCode == 200) {
        print("ITEM::$data");
        return true;
      } else {
        print("accident Form Not Updated");
        return false;
        //throw Exception("Unexpected Happened !");
      }
    } catch (error) {
      print("Error:$error");
      return false;
    }
  }
}
