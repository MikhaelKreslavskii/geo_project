import 'dart:html';
import 'dart:math' as Math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final _formKey = GlobalKey<FormState>();

  final _longtitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _zoomController = TextEditingController();

  bool validateLong = true;
  bool validateLat = true;
  bool validateZoom = true;

  int x = 0;
  int y = 0;
  int zoom = 19;

  final double c_pi180 = Math.pi / 180;

  @override
  Widget build(BuildContext context) {
    const double radius = 6378137;
    const double equator = 2 * Math.pi * radius;
    const double subequator = 1 / equator;
    const double halfEquator = equator / 2;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Form(
            key: _formKey,
            child: Container(
              height: 600,
              width: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Найти тайл",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                  TextFormField(
                    validator: _validatorLat,
                    style: TextStyle(color: Colors.blue),
                    controller: _latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 109, 109, 109)),
                      hintText: "Введите широту",
                      hintStyle: TextStyle(color: Colors.blue),
                      fillColor: (validateLat == true)
                          ? Color.fromARGB(255, 246, 246, 249)
                          : Color.fromARGB((255 * 0.75).toInt(), 235, 87, 87),
                      filled: true,
                      labelText: "Широта",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.blue),
                    controller: _longtitudeController,
                    validator: _validatorLong,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 109, 109, 109)),
                      hintText: "Введите долготу",
                      hintStyle: TextStyle(color: Colors.blue),

                     
                      fillColor: (validateLong == true)
                          ? Color.fromARGB(255, 246, 246, 249)
                          : Color.fromARGB((255 * 0.75).toInt(), 235, 87, 87),
                      filled: true,
                      labelText: "Долгота",

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.blue),
                    controller: _zoomController,
                    validator: _validatorZoom,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 109, 109, 109)),
                      hintText: "Введите приближение (zoom)",
                      hintStyle: TextStyle(color: Colors.blue),

                      
                      fillColor: (validateZoom == true)
                          ? Color.fromARGB(255, 246, 246, 249)
                          : Color.fromARGB((255 * 0.75).toInt(), 235, 87, 87),
                      filled: true,
                      labelText: "Zoom",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          double pixelsPerMeter =
                              Math.pow(2, double.parse(_zoomController.text)) *
                                  subequator;
                          double mercX = 0;
                          double mercY = 0;
                          mercX = cycleRestrict( double.parse(_longtitudeController.text) * c_pi180, -Math.pi,  Math.pi) * radius;
                          mercY = latToY(double.parse(_latitudeController.text));

                          x = ((halfEquator + mercX) * pixelsPerMeter).toInt();
                          y = ((halfEquator - mercY) * pixelsPerMeter).toInt();

                          zoom = int.parse(_zoomController.text);

                          setState(() {});
                        }
                      },
                      child: Text("Submit")),
                  Text(
                    "X - ${x}",
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Y - ${y}",
                    style: TextStyle(color: Colors.black, fontSize: 24 ,fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 250,
                    width: 250,
                    color: Colors.white,
                    child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return CircularProgressIndicator();
                        },
                        errorWidget: (context, url, error) {
                          return Text(
                            "На данный момент нужный тайл не найден",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          );
                        },
                        imageUrl:
                            "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${x}&y=${y}&z=${zoom}&scale=1&lang=ru_RU",
                        fit: BoxFit.cover),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  double cycleRestrict(double value, double min, double max) {
    return value -
        ((value - min) / (max - min)).toDouble().floor() * (max - min);
  }

  double latToY(double lat) {
    var epsilon = 1e-10;
    double radius = 6378137;
    double e = 0.0818191908426;
    // epsilon чтобы не получить (-)Infinity
    var latitude = restrict(lat, -90 + epsilon, 90 - epsilon) * c_pi180;
    var esinLat = e * Math.sin(latitude);

    // Для широты -90 получается 0, и в результате по широте выходит -Infinity
    var tan_temp = Math.tan(Math.pi * 0.25 + latitude * 0.5);
    var pow_temp =
        Math.pow(Math.tan(Math.pi * 0.25 + Math.asin(esinLat) * 0.5), e);
    var U = tan_temp / pow_temp;

    return radius * Math.log(U);
  }

  double restrict(value, min, max) {
    return Math.max(Math.min(value, max), min);
  }

  String? _validatorLat(String? value) {
    if (value!.isEmpty) {
      validateLat = false;
      setState(() {});

      return "Введите широту";
    }

    if (!isNumeric(value)) {
      validateLat = false;
      setState(() {});

      return "Введите число";
    }

    validateLat = true;
    setState(() {});
    return null;
  }

  String? _validatorLong(String? value) {
    if (value!.isEmpty) {
      validateLong = false;
      setState(() {});

      return "Введите долготу";
    }

    if (!isNumeric(value)) {
      validateLong = false;
      setState(() {});

      return "Введите число";
    }

    validateLong = true;
    setState(() {});
    return null;
  }

  String? _validatorZoom(String? value) {
    if (value!.isEmpty) {
      validateZoom = false;
      setState(() {});

      return "Введите zoom";
    }

    if (!isNumeric(value)) {
      validateZoom = false;
      setState(() {});

      return "Введите число";
    }

    validateZoom = true;
    setState(() {});
    return null;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
