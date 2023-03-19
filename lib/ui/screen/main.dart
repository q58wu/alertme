import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/ui/screen/add_alert.dart';
import 'package:alert_me/ui/screen/edit_detail.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzl;

import '../component/alert_filter_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeDatabase([]);
  tzl.initializeTimeZones();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Gilroy',
      ),
      home: const MyHomePage(title: 'Alert 🕗 Me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Alert> allAlerts = [];
  List<Alert> displayAlerts = [];

  String _currentFilter = "all";
  String _sortOrder = 'ascending';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshAllAlerts();
  }

  @override
  void dispose() {
    AlarmDatabase.instance.close();
    super.dispose();
  }

  Future refreshAllAlerts() async {
    setState(() => isLoading = true);

    allAlerts = await AlarmDatabase.instance.readAllAlerts();
    debugPrint(_currentFilter);
    if (_currentFilter != "all") {
      displayAlerts= allAlerts.where((alert) => alert.status.toString().split('.').last == _currentFilter).toList();
    } else {
      displayAlerts = allAlerts;
    }

    setState(() {
      isLoading = false;
    });
  }

  Slidable buildSlidable(BuildContext context, int position) {
    Alert currentAlert = displayAlerts[position];
    return Slidable(
      actionPane: const SlidableScrollActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: currentAlert.isImportant
              ? Theme.of(context).backgroundColor
              : Theme.of(context).selectedRowColor,
          icon: Icons.delete,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildDeleteAlertDialog(currentAlert);
                });
          },
        ),
        IconSlideAction(
          caption: 'Renew',
          color: currentAlert.isImportant
              ? Theme.of(context).backgroundColor
              : Theme.of(context).selectedRowColor,
          icon: Icons.access_time,
          onTap: () async {
            Alert updatedAlert = currentAlert.copy(
                expireTime: currentAlert.expireTime.add(Duration(
              days: currentAlert.repeatIntervalTimeInDays +
                  currentAlert.repeatIntervalTimeInWeeks * 7,
              minutes: currentAlert.repeatIntervalTimeInMinutes,
              hours: currentAlert.repeatIntervalTimeInHours,
            )));

            await AlarmDatabase.instance.update(updatedAlert);
            setState(() {
              //TODO:: can possibly just update the updated item here.
              refreshAllAlerts();
            });
          },
        ),
      ],
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                    builder: (context) => AlertDetailPage(currentAlert.id)),
              )
              .then((value) => setState(() {
                    refreshAllAlerts();
                  }));
        },
        leading: const FaIcon(
          FontAwesomeIcons.airbnb,
        ),
        title: Text(
          currentAlert.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          "Next on ${TimeUtil.convertDatetimeToYMMMED(currentAlert.expireTime)}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(
          Icons.alarm,
          color: Colors.grey,
          size: 20,
        ),
        tileColor:
            currentAlert.isImportant ? Colors.pink.shade50 : Colors.white10,
        dense: false,
      ),
    );
  }

  AlertDialog buildDeleteAlertDialog(Alert currentAlert) {
    return AlertDialog(
      title: const Text("Delete Alert"),
      titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      actionsOverflowButtonSpacing: 20,
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey),
            ),
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            await AlarmDatabase.instance.delete(currentAlert.id!).then(
                (value) =>
                    NotificationService().cancelNotification(currentAlert.id!));
            setState(() {
              refreshAllAlerts();
            });
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
          ),
          child: const Text("Delete"),
        )
      ],
      content: const Text("Are you sure to delete the alert?"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Setting"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("About"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              //TODO
            } else if (value == 1) {
              //TODO
            }
          })
        ],
      ),
      body: Center(
          child: Column(children: [
        AlertFilterBar(
          onFilterChanged: (String filter) {
            _currentFilter = filter;
            refreshAllAlerts();
          },
          onOrderChanged: (String order) {

          },
        ),
        Expanded(
            child: ListView.builder(
          itemBuilder: (context, position) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildSlidable(context, position),
                  Divider(
                    color: Theme.of(context).colorScheme.background,
                  )
                ]);
          },
          itemCount: displayAlerts.length,
        ))
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (context) => AddAlertPage()),
              )
              .then((value) => setState(() {
                    refreshAllAlerts();
                  }));
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
