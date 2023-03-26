import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/database/alertDatabase.dart';
import '../../domain/model/alert.dart';

class CountdownTimerWidget extends StatefulWidget {
  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late DateTime _expireTime;
  late Duration _duration;
  String? _days;
  String? _hours;
  String? _minutes;
  late Alert alert;

  @override
  initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    setState(() async {
      var alerts = await AlarmDatabase.instance.readAllAlerts();
      alert = alerts.first;
      _expireTime = alert.expireTime;
      _duration = _expireTime.difference(DateTime.now());
      _timer = Timer.periodic(Duration(minutes: 1), (timer) {
        setState(() {
          _duration = _expireTime.difference(DateTime.now());
          print(_duration);
          _days = (_duration.inDays).toString();
          _hours = (_duration.inHours % 24).toString().padLeft(2, '0');
          _minutes = (_duration.inMinutes % 60).toString().padLeft(2, '0');
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_days == null) {
      return Text('Expired');
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 150,
        child: Row(
          children: [
            Text('$_days days\n$_hours hours\n$_minutes minutes',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w200,
                )),
            const VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
