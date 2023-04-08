import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/ui/screen/edit_detail.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/database/alert_provider.dart';
import '../component/alert_control_bar.dart';
import '../component/alert_count_down.dart';
import 'add_alert.dart';

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
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void dispose() {
    AlarmDatabase.instance.close();
    super.dispose();
  }

  Card buildSlidableCard(BuildContext context, int position,
      Animation<double> animation, AlertProvider alertProvider) {
    Alert currentAlert = alertProvider.items[position];
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
                                          AlertDetailPage(alert: currentAlert)),
                                )
                                .then((value) => setState(() {
                                      alertProvider.retrieveAlerts();
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
                  onPressed: (BuildContext context) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return buildDeleteAlertDialog(
                              context, position, animation, alertProvider);
                        });
                  },
                ),
              ],
            ),
          ),
        ));
  }

  AlertDialog buildDeleteAlertDialog(BuildContext context, int position,
      Animation animation, AlertProvider alertProvider) {
    Alert currentAlert = alertProvider.items[position];
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
            removeItemWithAnimation(
                context, position, animation, alertProvider);
            await AlarmDatabase.instance.delete(currentAlert.id!).then(
                (value) =>
                    NotificationService().cancelNotification(currentAlert.id!));
            await alertProvider.retrieveAlerts();
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
      body: FutureBuilder(
          future: Provider.of<AlertProvider>(context, listen: false)
              .retrieveAlerts(),
          builder: (context, snapshot) => (snapshot.connectionState ==
                  ConnectionState.waiting)
              ? const Center(child: CircularProgressIndicator())
              : Consumer<AlertProvider>(
                  builder: (context, alertProvider, child) => SlidingUpPanel(
                        minHeight: 80,
                        maxHeight: 200,
                        defaultPanelState: PanelState.CLOSED,
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
                            AlertFilterBar(
                              onFilterChanged: (String filter) {
                                alertProvider.setFilter(filter);
                              },
                              onOrderChanged: (String order) {
                                alertProvider.setOrder(order);
                              },
                              onAddPressed: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddAlertPage()),
                                    )
                                    .then((value) => setState(() {
                                          Provider.of<AlertProvider>(context,
                                                  listen: false)
                                              .retrieveAlerts();
                                        }));
                              },
                            ),
                            CountdownTimerWidget()
                          ],
                        ),
                        body: Column(
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: AnimatedList(
                                key: alertProvider.listKey,
                                initialItemCount: alertProvider.items.length,
                                itemBuilder: (context, position, animation) {
                                  if (position < alertProvider.items.length) {
                                    // last item needs padding for bottom sheet
                                    if (position ==
                                        alertProvider.items.length - 1) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 80),
                                        child: buildListItem(context, position,
                                            animation, alertProvider),
                                      );
                                    } else {
                                      return buildListItem(context, position,
                                          animation, alertProvider);
                                    }
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ))), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildListItem(BuildContext context, int position,
      Animation<double> animation, AlertProvider alertProvider) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSlidableCard(context, position, animation, alertProvider)
          ]),
    );
  }

  void removeItemWithAnimation(BuildContext context, int position,
      Animation animation, AlertProvider alertProvider) {
    builder(context, animation) {
      return buildListItem(context, position, animation, alertProvider);
    }

    alertProvider.listKey.currentState?.removeItem(position, builder);
  }
}
