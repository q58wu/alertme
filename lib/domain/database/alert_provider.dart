import 'dart:ffi';

import 'package:flutter/material.dart';
import '../model/alert.dart';
import 'alertDatabase.dart';

class AlertProvider extends ChangeNotifier {
  List<Alert> _items = [];
  List<Alert> get items => _items;

  String _filter = "all";
  String _sortOrder = 'Ascending';
  // TODO Kejun: need to improve above

  Future insertDatabase(Alert alert) async {
    AlarmDatabase.instance.create(alert);
    _items.add(alert);

    notifyListeners();
  }

  Future<void> retrieveAlerts({bool shouldNotify = true}) async {
    final dataList = await AlarmDatabase.instance.readAllAlerts();
    _items = dataList;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    _filter = filter;
    runFilter();
    runSort();
    notifyListeners();
  }

  void runFilter() {
    if (_filter == "all") {
      retrieveAlerts(shouldNotify: false);
    } else if (_filter == "pending" || _filter == "triggered") {
      retrieveAlerts(shouldNotify: false);
      _items= _items.where((alert) => alert.status.toString().split('.').last == _filter).toList();
    }
  }

  Future<void> setOrder(String order) async {
    _sortOrder = order;
    runSort();
    notifyListeners();
  }

  void runSort() {
    if (_sortOrder == 'Ascending') {
      _items.sort((a, b) => a.expireTime.compareTo(b.expireTime));
    } else if (_sortOrder == 'Descending') {
      _items.sort((a, b) => -a.expireTime.compareTo(b.expireTime));
    }
  }
}
