import 'dart:html';
import 'dart:math' as Math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'dart:js_util' ;
import 'package:rxdart/utils.dart' as utils;
import 'package:map/map.dart';
import 'package:test_geo/google_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final _longtitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _zoomController = TextEditingController();

  double longtitude = 0;
  double latitude = 0;
  double zoom = 19;

  double X=0;
  double Y =0;

  bool validateLong = true;
  bool validateLat = true;
  bool validateZoom = true;

  

  
  double c_pi180 = Math.pi / 180;
   
  int x=0;
  int y =0;
  @override
  Widget build(BuildContext context) {

    double radius = 6378137;
  double equator = 2 * Math.pi * radius;
  double subequator = 1 / equator;
  double halfEquator = equator / 2;
  

  


    return Scaffold(
        backgroundColor: Colors.white,

        // body: Container(child:
        // CachedNetworkImage(imageUrl: "https://yandex.ru/maps/?ll=30.352853%2C60.370459&z=14")),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.next_plan, size: 32),

        body: Center(
          child: Container(
            height: 600,
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                  style: TextStyle(color:Colors.blue),
                  controller: _longtitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter longtitude",
                    hintStyle: TextStyle(color: Colors.blue),

                    /// errorText: ((_key.currentState?.validate()!=null)&&(_key.currentState!.validate())) ? "fndfk": "add",
                    fillColor: (validateLong == true)
                        ? Color.fromARGB(255, 246, 246, 249)
                        : Color.fromARGB((255 * 0.75).toInt(), 235, 87, 87),
                    filled: true,
                    labelText: "longtitude",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                TextFormField(
                  style: TextStyle(color:Colors.blue),
                  controller: _latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter latitude",
                    hintStyle: TextStyle(color: Colors.blue),
                    

                    /// errorText: ((_key.currentState?.validate()!=null)&&(_key.currentState!.validate())) ? "fndfk": "add",
                    fillColor: (validateLat == true)
                        ? Color.fromARGB(255, 246, 246, 249)
                        : Color.fromARGB((255 * 0.75).toInt(), 235, 87, 87),
                    filled: true,
                    labelText: "Latitude",
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                TextFormField(
                  style: TextStyle(color:Colors.blue),
                  controller: _zoomController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter zoom",
                    hintStyle: TextStyle(color: Colors.blue),

                    /// errorText: ((_key.currentState?.validate()!=null)&&(_key.currentState!.validate())) ? "fndfk": "add",
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
                ElevatedButton(onPressed: () {
                
                    
                  double pixelsPerMeter = Math.pow(2, zoom ) * subequator;
                  double mercX=0;
                  double mercY=0;
                  mercX =  cycleRestrict(double.parse(_longtitudeController.text) * c_pi180, -Math.pi, Math.pi)*radius;
                  mercY = latToY(double.parse(_latitudeController.text));

                  x = ((halfEquator+mercX)*pixelsPerMeter).toInt();
                  y = ((halfEquator- mercY)*pixelsPerMeter).toInt();

                    //  x = N(double.parse(_latitudeController.text)+0)*Math.cos(double.parse(_latitudeController.text)*Math.cos(double.parse(_longtitudeController.text))) ;
                    //  y = N(double.parse(_latitudeController.text)+0)*Math.cos(double.parse(_latitudeController.text)*Math.sin(double.parse(_longtitudeController.text)));

                     setState(() {
                       
                     }); 

                  
                }, child: Text("Submit")),
                Text("X - ${x}", style: TextStyle(color: Colors.black),),
                Text("Y - ${y}", style: TextStyle(color: Colors.black),),
                Container(
                  height: 250,
                  width: 250,
                  color: Colors.white,
                  child: CachedNetworkImage(
                      imageUrl:
                          "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${x}&y=${y}&z=19&scale=1&lang=ru_RU",
                      fit: BoxFit.cover),
                )
              ],
            ),
          ),
        ));
  }

  double cycleRestrict(double value, double min, double max)
  {
   
     return value - ((value - min)/(max - min)).toDouble().floor() * (max-min);    
}



double latToY(double lat)
{
   var epsilon = 1e-10;
   double radius = 6378137;
   double e = 0.0818191908426;
    // epsilon чтобы не получить (-)Infinity
    var latitude = restrict(lat, -90 + epsilon, 90 - epsilon) * c_pi180;
    var esinLat = e * Math.sin(latitude);

    // Для широты -90 получается 0, и в результате по широте выходит -Infinity
    var tan_temp = Math.tan(Math.pi * 0.25 + latitude * 0.5);
    var pow_temp = Math.pow(Math.tan(Math.pi * 0.25+ Math.asin(esinLat) * 0.5), e);
    var U = tan_temp / pow_temp;

    return radius * Math.log(U);
}

double restrict  (value, min, max) {
  return Math.max(Math.min(value, max), min);
}
  
  double N(double lat)
  {
     double a = 6378245;
    double b =6356863;

    double e = (Math.pow(a, 2).toDouble()- Math.pow(b, 2).toDouble())/(Math.pow(a, 2).toDouble());

     return a/(Math.pow((1-e*Math.pow(Math.sin(lat), 2)), 0.5));

  }
  
}
