import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

Future<List<Station>> getTemperatureData() async {
  final url = Uri.parse(
      'https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/1/station-set/all/period/latest-hour/data.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    if (body case {'updated': int updated, 'station': List stations}) {
      return [for (final station in stations) Station.fromJson(station)];
    } else {
      throw const FormatException("Unexpected json format");
    }
  } else {
    debugPrint("status code ${response.statusCode}");
    throw const HttpException('');
  }
}

class Station {
  final String key;
  final String name;
  final String owner;
  final String ownerCategory;
  final String measuringStations;
  final DateTime from;
  final DateTime to;
  final double height;
  final LatLng latLng;
  final Value? value;

  Station(
      {required this.key,
      required this.name,
      required this.owner,
      required this.ownerCategory,
      required this.measuringStations,
      required this.from,
      required this.to,
      required this.height,
      required this.latLng,
      required this.value});

  factory Station.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'key': final key,
          'name': String name,
          'owner': String owner,
          'ownerCategory': String ownerCategory,
          'measuringStations': String measuringStations,
          'from': int from,
          'to': int to,
          'height': double height,
          'latitude': double latitude,
          'longitude': double longitude,
          'value': List valueList,
        }) {
      final fromAsDateTime =
          DateTime.fromMillisecondsSinceEpoch(from, isUtc: true);
      final toAsDateTime = DateTime.fromMillisecondsSinceEpoch(to, isUtc: true);
      final latLng = LatLng(latitude, longitude);

      Value? valueAsObj;
      if (valueList.isNotEmpty) {
        valueAsObj = Value.fromJson(valueList);
      }

      return Station(
          key: key,
          name: name,
          owner: owner,
          ownerCategory: ownerCategory,
          measuringStations: measuringStations,
          from: fromAsDateTime,
          to: toAsDateTime,
          height: height,
          latLng: latLng,
          value: valueAsObj);
    }
    throw const FormatException("Unexpected station format");
  }
}

class Value {
  final DateTime date;
  final dynamic value;
  final String quality;

  Value({required this.date, required this.value, required this.quality});

  factory Value.fromJson(List valueList) {
    if (valueList
        case [
          {
            'date': int date,
            'value': final value,
            'quality': String quality,
          }
        ]) {
      final dateAsDateTime =
          DateTime.fromMillisecondsSinceEpoch(date, isUtc: true);
      return Value(date: dateAsDateTime, value: value, quality: quality);
    }
    throw const FormatException("Unexpected value format");
  }
}
