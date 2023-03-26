import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/mapper/TimeUtil.dart';
import '../component/alert_count_down.dart';
import 'add_alert.dart';
import 'edit_detail.dart';

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
      displayAlerts = allAlerts
          .where((alert) =>
              alert.status.toString().split('.').last == _currentFilter)
          .toList();
    } else {
      displayAlerts = allAlerts;
    }

    setState(() {
      isLoading = false;
    });
  }

  Card buildSlidable(BuildContext context, int position) {
    Alert currentAlert = displayAlerts[position];
    return Card(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ClipRect(
          child: Slidable(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currentAlert.title,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AlertDetailPage(currentAlert.id)),
                                )
                                .then((value) => setState(() {
                                      refreshAllAlerts();
                                    }));
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      currentAlert.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.alarm_sharp),
                        SizedBox(width: 8),
                        Text(
                          "${TimeUtil.convertDatetimeToYMMMED(currentAlert.expireTime)}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text('Important'),
                          backgroundColor: Colors.redAccent[100],
                        ),
                        Chip(
                          label: Text('Repeating'),
                          backgroundColor: Colors.greenAccent[100],
                        ),
                        Chip(
                          label: Text('custom tag'),
                          backgroundColor: Colors.grey[100],
                        ),
                      ],
                    ),
                  )
                ]),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  icon: Icons.skip_next,
                  label: 'Postpone',
                  onPressed: (BuildContext context) {},
                ),
                SlidableAction(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.save,
                  label: 'Delete',
                  onPressed: (BuildContext context) {},
                ),
              ],
            ),
          ),
        ));
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
        body: SlidingUpPanel(
      minHeight: 40,
      maxHeight: 500,
      defaultPanelState: PanelState.OPEN,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      panel: Column(
        children: [
          Container(
            width: 100,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey,
            ),
          ),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Add your filter logic here
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (context) => AddAlertPage()),
                    )
                    .then((value) => setState(() {
                          refreshAllAlerts();
                        }));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
            ),
          ]),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, position) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildSlidable(context, position),
                    ]);
              },
              itemCount: displayAlerts.length,
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.indigo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 0, height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  size: 30,
                ),
                onPressed: () {},
              ),
              Text('Home',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: Text('Next Alert in',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: CountdownTimerWidget(),
            ),
          ],
        ),
      ),
    ));
  }
}
