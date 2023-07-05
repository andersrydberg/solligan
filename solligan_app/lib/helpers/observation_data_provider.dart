import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solligan_app/helpers/dataclasses.dart';
import 'package:solligan_app/helpers/constants.dart';

enum SortOption { alphabetic, northToSouth, southToNorth, highToLow, lowToHigh }

class ObservationDataProvider extends ChangeNotifier {
  final Map<String, Parameter> _data = {};
  String _selectedParameter = '1';
  String _searchString = '';
  bool _omitMissing = false;
  SortOption _selectedSortOption = SortOption.alphabetic;

  bool showCircularProgressIndicator = true;

  // getters and setters
  List<Station>? get data => _data[_selectedParameter]?.filteredData;

  String get selectedParameter => _selectedParameter;

  set selectedParameter(String parameter) {
    if (_selectedParameter == parameter) return;

    _selectedParameter = parameter;
    if (_data.containsKey(parameter)) {
      _data[parameter]!.applyFilters();
      notifyListeners();
    } else {
      showCircularProgressIndicator = true;
      notifyListeners();
      _data[parameter] = Parameter(this, parameter);
      _data[parameter]!.update().then((_) {
        showCircularProgressIndicator = false;
        notifyListeners();
      });
    }
  }

  String get searchString => _searchString;

  set searchString(String searchString) {
    _searchString = searchString;
    _data[_selectedParameter]?.applyFilters();
    notifyListeners();
  }

  bool get omitMissing => _omitMissing;

  set omitMissing(bool value) {
    _omitMissing = value;
    _data[_selectedParameter]?.applyFilters();
    notifyListeners();
  }

  SortOption get selectedSortOption => _selectedSortOption;

  set selectedSortOption(SortOption option) {
    _selectedSortOption = option;
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
    _data[_selectedParameter] = Parameter(this, _selectedParameter);
    await _data[_selectedParameter]!.update();
    showCircularProgressIndicator = false;
    notifyListeners();
  }

  Future<bool> requestUpdate() async {
    final updated = await _data[_selectedParameter]!.update();
    if (updated) {
      notifyListeners();
      return true;
    }
    return false;
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

  Future<bool> update() async {
    debugPrint('Parameter.update: entering');
    if (await _updateNeeded()) {
      await _update();
      return true;
    }
    return false;
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
    switch (_provider.selectedSortOption) {
      case SortOption.alphabetic:
        // already "sorted" (do nothing)
        break;
      case SortOption.northToSouth:
        _filteredData
            .sort((a, b) => b.latLng.latitude.compareTo(a.latLng.latitude));
      case SortOption.southToNorth:
        _filteredData
            .sort((a, b) => a.latLng.latitude.compareTo(b.latLng.latitude));
      case SortOption.highToLow:
        _filteredData.sort((a, b) {
          final aValue = a.value?.value;
          final bValue = b.value?.value;
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return 1;
          if (bValue == null) return -1;
          return double.parse(bValue).compareTo(double.parse(aValue));
        });
      case SortOption.lowToHigh:
        _filteredData.sort((a, b) {
          final aValue = a.value?.value;
          final bValue = b.value?.value;
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return 1;
          if (bValue == null) return -1;
          return double.parse(aValue).compareTo(double.parse(bValue));
        });
    }
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
