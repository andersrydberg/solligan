import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solligan_app/helpers/dataclasses.dart';

const List<String> monthsSwedish = [
  '',
  'januari',
  'februari',
  'mars',
  'april',
  'maj',
  'juni',
  'juli',
  'augusti',
  'september',
  'oktober',
  'november',
  'december'
];

class ObservationDataProvider extends ChangeNotifier {
  final Map<String, Parameter> _data = {};
  String? _selectedParameter;

  void setParameter(String parameter) async {
    if (_selectedParameter == parameter) return;

    _selectedParameter = parameter;
    if (!_data.containsKey(parameter)) _data[parameter] = Parameter(parameter);
    if (await _data[parameter]!.update()) notifyListeners();
  }

  void requestUpdate() {
    _data[_selectedParameter]?.update();
  }

  List<Station>? get data => _data[_selectedParameter]?.filteredData;

  String? get readableDate {
    DateTime? updated = _data[_selectedParameter]?._updated;
    if (updated == null) return null;
    final now = DateTime.now();
    switch (now.difference(updated).inDays) {
      case 0:
        return 'idag';
      case 1:
        return 'igår';
    }
    return '${updated.day} ${monthsSwedish[updated.month]}';
  }

  String? get readableTime {
    DateTime? updated = _data[_selectedParameter]?._updated;
    if (updated == null) return null;
    return 'kl. ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}';
  }
}

class Parameter {
  final String parameterId;

  final List<Station> _allData = [];
  final List<Station> _filteredData = [];
  DateTime? _updated;

  Parameter(this.parameterId);

  List<Station> get filteredData => _filteredData;

  bool _checkForUpdate() {
    if (_updated == null) return true;
    return DateTime.now().difference(_updated!).inHours >= 1;
  }

  Future<bool> _update() async {
    final latestHourUri = Uri.parse(
        'https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/$parameterId/station-set/all/period/latest-hour.json');
    final latestHourJson = await getJsonFromUri(latestHourUri);
    if (latestHourJson case {'updated': int updated}) {
      final remoteUpdated = DateTime.fromMillisecondsSinceEpoch(updated);
      if (_updated == null || remoteUpdated.isAfter(_updated!)) {
        final dataUri = Uri.parse(
            'https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/$parameterId/station-set/all/period/latest-hour/data.json');
        final dataJson = await getJsonFromUri(dataUri);
        if (dataJson case {'updated': int updated, 'station': List stations}) {
          _allData.clear();
          for (final station in stations) {
            _allData.add(Station.fromJson(station));
          }
          _updated = DateTime.fromMillisecondsSinceEpoch(updated);
          _filterData();
          return true;
        }
        throw const FormatException("Unexpected json format");
      }
      return false;
    }
    throw const FormatException("Unexpected json format");
  }

  // returns true if data was updated
  Future<bool> update() async {
    if (!_checkForUpdate()) return false;
    return _update();
  }

  // TODO
  void _filterData() {
    _filteredData.clear();
    _filteredData.addAll(_allData);
  }
}

Future<dynamic> getJsonFromUri(Uri uri) async {
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint("status code ${response.statusCode}");
    throw const HttpException('');
  }
}
