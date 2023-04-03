import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gct/models/accidents.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather.dart';

import '../api/api_services.dart';
import '../providers/app_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  _MyHomePageState();

  late AppProvider _appProvider;

  String? weather;
  late String? temperature = "30";
  var now = DateTime.now();

  late Timer timer;
  late Timer refreshTimer;
  late String _timeString;

  final Color dataBgColor = const Color.fromARGB(235, 22, 67, 140);
  late List<Accidents> _accidentsList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nbTotaleAccidentsController = TextEditingController(),
      nbrJrsSansAccidentsController = TextEditingController(),
      messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getWeather().then((value) {
      setState(() {
        if (value != null)
          temperature = (value.temperature?.celsius?.toStringAsFixed(0));
      });
    });
    _timeString = _formatDateTime(DateTime.now());
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    refreshTimer = Timer.periodic(
        const Duration(minutes: 60),
        (Timer t) => getWeather().then((value) {
              setState(() {
                if (value != null) {
                  temperature =
                      (value.temperature?.celsius?.toStringAsFixed(0));
                }
              });
            }));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    refreshTimer.cancel();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    print("_getTime $_timeString");
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  Future<dynamic> getWeather({counter = 0}) async {
    double lat = 33.3395367;
    double lon = 10.48969389999;
    WeatherFactory wf = WeatherFactory("92f1cfabd3ff63e1be3a6cc350d43018");

    try {
      Weather w = await wf.currentWeatherByLocation(lat, lon);

      if (mounted) {
        setState(() {});
      }
      return w;
    } catch (error) {
      if (counter < 3) {
        counter += 1;
        return getWeather(counter: counter);
      } else {
        print('verify your connection !!WEATHER!! counter:$counter');

        return null;
      }
    }
  }

  Widget buildEditableFormField(
      {TextEditingController? controller, String? columnName, String? value}) {
    // Determine the keyboard type
    // final keyboardType = TextInputType.number;
    // Determine the keyboard input type
    // final inputFormatter = FilteringTextInputFormatter.allow(RegExp('[0-9]'));

    return Expanded(
      child: Row(
        children: [
          Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(columnName!)),
          Container(
            width: 300,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              controller: controller,
              keyboardType: columnName == "MESSAGE"
                  ? TextInputType.text
                  : TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                columnName == "MESSAGE"
                    ? FilteringTextInputFormatter.allow(RegExp(r'.'))
                    : FilteringTextInputFormatter.digitsOnly
              ],

              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: columnName,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '** Obligatoire';
                }
                return null;
              },

              // keyboardType: keyboardType,
              // inputFormatters: [inputFormatter],
              enabled: true,
            ),
          )
        ],
      ),
    );
  }

  Future _updateAccident(accidentId, data) async {
    await GctClientService(appProvider: _appProvider)
        .updateAccident(accidentId: accidentId, data: data)
        .then((value) => _onRefresh());
  }

  // onRefresh //
  void _onRefresh() async {
    await _getAccidents().then((value) =>
        {_appProvider.setAccidents(_accidentsList), setState(() {})});
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Accidents>> _getAccidents() async {
    _accidentsList =
        await GctClientService(appProvider: _appProvider).getAccidents();
    return _accidentsList;
  }

  void showUpdateCarte(
    BuildContext context,
  ) {
    nbTotaleAccidentsController.text =
        _accidentsList.elementAt(0).nbr_totale_accidents.toString();
    nbrJrsSansAccidentsController.text =
        _accidentsList.elementAt(0).nbr_jours_sans_accident.toString();
    messageController.text = _accidentsList.elementAt(0).message.toString();

    print(
        "Nbr Jrs SansAccident ${_accidentsList.elementAt(0).nbr_jours_sans_accident}");
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //API CALL

                      var item = {
                        "name": "GCT",
                        "nbr_jours_sans_accident":
                            int.parse(nbrJrsSansAccidentsController.text),
                        "nbr_totale_accidents":
                            int.parse(nbTotaleAccidentsController.text),
                        "message": messageController.text
                      };

                      _updateAccident("63f48c54144ba124c86383fe", item);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Enregistrer')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'))
            ],
            content: SizedBox(
              height: 400,
              width: 400,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /*  buildEditableFormField(
                          controller: barcodeIDController, columnName: 'ID'), */
                      buildEditableFormField(
                          controller: nbTotaleAccidentsController,
                          columnName: 'Nbr Totale des Accidents'),
                      buildEditableFormField(
                          controller: nbrJrsSansAccidentsController,
                          columnName: 'Nbr Jrs Sans Accidents'),
                      buildEditableFormField(
                          controller: messageController, columnName: 'MESSAGE'),
                    ],
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    _accidentsList = _appProvider.getAccidents();

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Row(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                height: 50,
                                child: const Text(
                                  "التاريخ \n   ",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(20),
                                color: Colors.grey[600],
                                child: Text(
                                  "${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            children: [
                              Container(
                                child: Image.asset("assets/images/gct_logo.png",
                                    scale: 1, fit: BoxFit.scaleDown),
                              ),
                              const SizedBox(
                                height: 150,
                                child: Text(
                                  "\nGroupe Chimique Tunisien \n المجمع الكیمیائي التونسي ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.green,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                height: 50,
                                child: const Text(
                                  "التوقيت \n   ",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.all(20),
                                  color: Colors.grey[600],
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        temperature.toString() + "°C",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            color: Colors.orange,
                                            decoration: TextDecoration.none),
                                      ),
                                      Text(
                                        _timeString,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            color: Colors.white,
                                            decoration: TextDecoration.none),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        )
                      ]),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Row(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 150,
                                child: Text(
                                  "Nombre des jours sans accidents de travail \n عدد الأيام بدون حوادث شغل",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(20),
                                color: Colors.grey[600],
                                child: Text(
                                  _accidentsList
                                      .elementAt(0)
                                      .nbr_jours_sans_accident
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/1.png",
                                        scale: 1, fit: BoxFit.scaleDown),
                                    Image.asset("assets/images/2.png",
                                        scale: 1, fit: BoxFit.scaleDown),
                                    Image.asset("assets/images/3.png",
                                        scale: 1, fit: BoxFit.scaleDown)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.red,
                                  margin: const EdgeInsets.all(20),
                                  padding: const EdgeInsets.all(50),
                                  child: const Text(
                                    "ارتداء وسائل الوقایة اجباري",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                                Container(
                                    child: IconButton(
                                  iconSize: 50,
                                  color: Colors.blue,
                                  onPressed: () {
                                    showUpdateCarte(context);
                                  },
                                  icon: Icon(
                                    Icons.border_color_outlined,
                                  ),
                                ))
                              ],
                            )),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 150,
                                child: Text(
                                  "Nombre totale des accidents de travail \n العدد الجملي لحوادث الشغل",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(20),
                                color: Colors.grey[600],
                                child: Text(
                                  _accidentsList
                                      .elementAt(0)
                                      .nbr_totale_accidents
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/4.png",
                                        scale: 1, fit: BoxFit.scaleDown),
                                    Image.asset("assets/images/5.png",
                                        scale: 1, fit: BoxFit.scaleDown),
                                    Image.asset("assets/images/6.png",
                                        scale: 1, fit: BoxFit.scaleDown)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  ],
                ))));
  }
}
