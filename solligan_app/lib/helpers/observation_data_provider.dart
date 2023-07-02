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

const smhiUrlPrefix =
    'https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/';

// enum SortOption { }

class ObservationDataProvider extends ChangeNotifier {
  final Map<String, Parameter> _data = {};
  String _selectedParameter = '1';
  String _searchString = '';
  bool omitMissing = false;

  // getters and setters
  List<Station>? get data => _data[_selectedParameter]?.filteredData;

  void setParameter(String parameter) async {
    if (_selectedParameter == parameter) return;

    _selectedParameter = parameter;
    if (_data.containsKey(parameter)) {
      _data[parameter]!.applyFilters();
    } else {
      _data[parameter] = Parameter(this, parameter);
      await _data[parameter]!.update();
    }
    notifyListeners();
  }

  String get searchString => _searchString;

  set searchString(String searchString) {
    _searchString = searchString;
    _data[_selectedParameter]?.applyFilters();
    notifyListeners();
  }

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

  // other methods
  void init() async {
    debugPrint('ObservationDataProvider.init: entering');

    _data[_selectedParameter] = Parameter(this, _selectedParameter);
    await _data[_selectedParameter]!.update();

    debugPrint('ObservationDataProvider.init: notifying listeners');
    debugPrint('(has listeners?: ${hasListeners.toString()})');
    notifyListeners();
  }

  void requestUpdate() async {
    await _data[_selectedParameter]?.update();
    debugPrint('ObservationDataProvider.requestUpdate: notifying listeners');
    debugPrint('(has listeners?: ${hasListeners.toString()})');
    notifyListeners();
  }
}

class Parameter {
  final ObservationDataProvider _provider;
  final String _parameterId;

  final List<Station> _allData = [];
  final List<Station> _filteredData = [];
  DateTime? _updated;

  Parameter(this._provider, this._parameterId);

  List<Station> get filteredData => _filteredData;

  Future<bool> _updateNeeded() async {
    if (_updated == null) return true;

    if (DateTime.now().difference(_updated!).inHours >= 1) {
      // check if data has been updated on remote server
      final uri = Uri.parse(
          '$smhiUrlPrefix$_parameterId/station-set/all/period/latest-hour.json');
      final json = await getJsonFromUri(uri);
      if (json case {'updated': int updated}) {
        return DateTime.fromMillisecondsSinceEpoch(updated).isAfter(_updated!);
      }
      throw const FormatException('Unexpected json format');
    }
    return false;
  }

  Future<void> _update() async {
    debugPrint('Paramter._update: entering');
    // fetch data
    final uri = Uri.parse(
        '$smhiUrlPrefix$_parameterId/station-set/all/period/latest-hour/data.json');
    final json = await getJsonFromUri(uri);

    if (json case {'updated': int updated, 'station': List stations}) {
      debugPrint('Parameter._update: updating ${stations.length} stations');
      // replace local data
      _allData.clear();
      for (final station in stations) {
        _allData.add(Station.fromJson(station));
      }
      _updated = DateTime.fromMillisecondsSinceEpoch(updated);
      applyFilters();
    } else {
      throw const FormatException('Unexpected json format');
    }
  }

  Future<void> update() async {
    debugPrint('Parameter.update: entering');
    if (await _updateNeeded()) await _update();
  }

  void applyFilters() {
    debugPrint('Parameter.applyFilters: entering');
    _filteredData.clear();
    _filteredData.addAll(_allData);

    // 1. filter by omit missing data option
    if (_provider.omitMissing) {
      _filteredData.removeWhere((station) => station.value == null);
    }

    // 2. filter by search string
    final string = _provider.searchString.toLowerCase();
    if (string != '') {
      _filteredData.retainWhere(
          (station) => station.name.toLowerCase().contains(string));
    }

    // 3. sort
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
