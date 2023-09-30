import 'dart:developer';

import 'package:dio/dio.dart';


class GeoRepository {
  

  GeoRepository();
  Future<String> getTile() async {
   //// List<Hotel> hotelList = [];
    try {
      final response = await Dio()
          .get("https://api-maps.yandex.ru/2.1/?apikey=7887dede-6add-4a43-a444-64f11ecd742d&lang=ru_RU");

      log('response ${response.data}');
      final data = response.data;
      
        
        
     return response.data.toString();   
       
     
    } catch (e) {
      log('AAAAAAAAAAAAAAA $e');
      throw Exception();
    }

    
  }
}
