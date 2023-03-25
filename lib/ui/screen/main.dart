import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
          title: Text(currentAlert.title),
          subtitle: Text(currentAlert.expireTime.toIso8601String()),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'More',
            color: Colors.black45,
            icon: Icons.more_horiz,
            onTap: () => print('More'),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => print('Delete'),
          ),
        ],
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
        body: SlidingUpPanel(
          minHeight: 200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          panel: Column(
            children: [
              Container(
                width: 100,
                height: 8,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
                ),
              ),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    showTopSnackBar(
                      Overlay.of(context)!,
                      const CustomSnackBar.error(
                        message:
                            "Please make sure repeat interval is greater than 0 minutes.",
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Add your filter logic here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                )
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
          body: Center(
            child: Text("This is the Widget behind the sliding panel"),
          ),
        ));
  }
}
