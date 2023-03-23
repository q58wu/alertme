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

  // Future<void> retrieveAlerts() async {
  //   retrieveAlerts(true);
  // }

  Future<void> retrieveAlerts({bool shouldNotify = true}) async {
    final dataList = await AlarmDatabase.instance.readAllAlerts();
    _items = dataList;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  // TODO kejun: filter vs sort?? use enum instead of string
  Future<void> setFilter(String filter) async {
    _filter = filter;
    // TODO kejun: need improve here, there is no status as "all", so needed to separate logic...
    if (_filter == "all") {
      retrieveAlerts(shouldNotify: false);
    } else if (_filter == "pending" || _filter == "triggered") {
      retrieveAlerts(shouldNotify: false);
      _items= _items.where((alert) => alert.status.toString().split('.').last == _filter).toList();
    } else if (_filter == 'Ascending') {
      _items.sort((a, b) => a.expireTime.compareTo(b.expireTime));
    } else if (_filter == 'Descending') {
      _items.sort((a, b) => -a.expireTime.compareTo(b.expireTime));
    }
    notifyListeners();
  }
}
