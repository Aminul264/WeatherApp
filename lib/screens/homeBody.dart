import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../weather_api/api.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';


class HomeBody extends StatefulWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  var degree = "\u00B0";
  var tempData = "Please Wait...";
  var location = "Current Location";
  var search = "Search";
  var description = "Welcome";
  var longi, lati;
  var humidity = "";
  var icon = "";
  var feelLike = "";
  var visibility = "";
  var pressure = "";
  var sunriseSunset ="";

  TextEditingController textEditingController = TextEditingController();


  void getWeather() async {
    var machine = WeatherInformationMachine();
    Map<String, dynamic> response =
        await machine.getDataWithCity(textEditingController.text);
    if (response["cod"] == 200) {
      double tempDegree = response['main']['temp'] - 273.16;
      double tempFeel = response['main']['feels_like'] - 273.16;
      setState(() {
        location = response["name"] + ", " + response["sys"]["country"];
        tempData = tempDegree.toStringAsPrecision(4);
        description = response['weather'][0]['description'];
        icon = response['weather'][0]['icon'];
        humidity = ': ' + response['main']['humidity'].toString() + ' %';
        feelLike = tempFeel.toStringAsPrecision(4);
        visibility = response['visibility'].toString();
        //print(visibility);
        pressure = response['main']['pressure'].toString();
       // sunriseSunset= getSunriseSunset(60.0, 60.0, 1, DateTime.now());
      });
    } else {
      Fluttertoast.showToast(
          msg: response["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black12,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void loadData() async {
    var serviceStatus = await Geolocator.isLocationServiceEnabled();

    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        if (kDebugMode) {
          print("permission denied");
        }
      } else if (locationPermission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print("forget it. it's reject forever.");
        }
      } else {
        if (kDebugMode) {
          print("permission given");
        }
      }
    } else {
      if (kDebugMode) {
        print("Permission Hold");
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    longi = position.longitude.toStringAsFixed(2);
    lati = position.latitude.toStringAsFixed(2);

    var machine = WeatherInformationMachine();
    var response = await machine.getDataWithLongLat(longi, lati);

    if (response["cod"] == 200) {
      double tempDegree = response['main']['temp'] - 273;

      setState(() {
        tempData = tempDegree.toStringAsPrecision(2);
        location = response["name"];
        description = response['weather'][0]['description'];
      });
    } else {
      Fluttertoast.showToast(
          msg: response["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black12,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: Colors.lightBlue,
    minimumSize: Size(80, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  final ButtonStyle accentFlatButtonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: Colors.lightBlue,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Icon(
                Icons.cloud,
                color: Colors.grey,
                size: 100.0,
              ),
              // Image.network(
              //   'https://openweathermap.org/img/wn/$icon.png',
              //   height: 100,
              //   width: 150,
              //   fit: BoxFit.fitWidth,
              //   Color.fromARGB(255, 15, 147, 59),
              //   opacity: const AlwaysStoppedAnimation( <double>(0.5)),
              // ),
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                location,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal),
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
          Expanded(
              child: Container(
            child: Text(tempData.toString() + degree,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  fontSize: 20,
                )),
          )),
          Expanded(
            child: Container(
              child: Text(
                description,
                // icon,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              width: 200,
              child: TextField(
                  controller: textEditingController,
                  textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: flatButtonStyle,
                  onPressed: getWeather,
                  child: Text(
                    search,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal),
                  )),
            ),
          ),
          Expanded(
            child: Container(
              child: ElevatedButton(
                style: accentFlatButtonStyle,
                onPressed: loadData,
                child: const Text("Current Location Temperature"),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Humidity  $humidity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'feels Like  :' + feelLike.toString() + degree,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              child: Text(
                'Date :${DateFormat('dd-MM-yyy').format(DateTime.now())}',
                style: TextStyle(
                  letterSpacing: 2.0,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                 // color: Colors.grey
                ),
              ),
            ),
          ),
          // Expanded(
          //   child: Container(
          //     child: Text(
          //      // 'Sunset :${getSunriseSunset(60.0, 60.0, 1.0, DateTime.now()).sunrise.toString()}',
          //       style: const TextStyle(
          //         letterSpacing: 2.0,
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //         // color: Colors.grey
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
