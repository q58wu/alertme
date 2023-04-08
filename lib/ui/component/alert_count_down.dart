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
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 100,
          child: Center(
              child: Text('You are all clear.\nTry adding some new alerts!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ))));
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Next in: ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    )),
                Text('"${alert.title}"',
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ],
            ),
            Spacer(),
            Text('$_days days, $_hours hours, $_minutes minutes',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            Spacer(),
          ],
        ),
      );
    }
  }
}
