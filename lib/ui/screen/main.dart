import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/ui/screen/add_alert.dart';
import 'package:alert_me/ui/screen/edit_detail.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzl;

import '../../domain/database/alert_provider.dart';
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AlertProvider(),
          ),
        ],
        builder: (context, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.green,
                fontFamily: 'Gilroy',
              ),
              home: const MyHomePage(title: 'Alert 🕗 Me'),
            ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {
    AlarmDatabase.instance.close();
    super.dispose();
  }

  Slidable buildSlidable(BuildContext context, Alert currentAlert, AlertProvider alertProvider) {
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
                  return buildDeleteAlertDialog(currentAlert, alertProvider);
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
              alertProvider.retrieveAlerts();
            });
          },
        ),
      ],
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                    builder: (context) => AlertDetailPage(alert: currentAlert)),
              )
              .then((value) => setState(() {
                    alertProvider.retrieveAlerts();
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

  AlertDialog buildDeleteAlertDialog(Alert currentAlert, AlertProvider alertProvider) {
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
              alertProvider.retrieveAlerts();
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
      body: FutureBuilder(
          future: Provider.of<AlertProvider>(context, listen: false)
              .retrieveAlerts(),
          builder: (context, snapshot) => (snapshot.connectionState ==
                  ConnectionState.waiting)
              ? const Center(child: CircularProgressIndicator())
              : Consumer<AlertProvider>(
                  builder: (context, alertProvider, child) => Column(
                        children: [
                          AlertFilterBar(
                            onFilterChanged: (String filter) {
                              // TODO Kejun: filter vs sort?
                              alertProvider.setFilter(filter);
                            },
                            onOrderChanged: (String order) {},
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, position) {
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      buildSlidable(
                                          context,
                                          alertProvider.items[position],
                                          alertProvider),
                                      Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      )
                                    ]);
                              },
                              itemCount: alertProvider.items.length,
                            ),
                          ),
                        ],
                      ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (context) => AddAlertPage()),
              )
              .then((value) => setState(() {
                    Provider.of<AlertProvider>(context, listen: false)
                        .retrieveAlerts();
                  }));
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
