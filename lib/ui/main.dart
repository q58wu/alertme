import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/ui/add_alert.dart';
import 'package:alert_me/usecase/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';

void main() {
  NotificationService().initNotification();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alert🕗Me',
      theme: ThemeData(
        primarySwatch: Colors.green,
        selectedRowColor: Colors.pink.shade200,
        fontFamily: 'Shantell_Sans'
      ),
      home: const MyHomePage(title: 'Alert🕗Me'),
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
  List<Alert> allAlert = [];
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

    allAlert = await AlarmDatabase.instance.readAllAlerts();

    setState(() {
      isLoading = false;
    });
  }

  Slidable buildSlidable(BuildContext context, int position) {
    Alert currentAlert = allAlert[position];
    return
      Slidable(
      actionPane: const SlidableScrollActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: currentAlert.isImportant ? Theme.of(context).backgroundColor :Theme.of(context).selectedRowColor,
          icon: Icons.delete,
          onTap: () async {
            await AlarmDatabase.instance.delete(currentAlert.id!);
            setState(() { refreshAllAlerts(); });
          },
        ),
        IconSlideAction(
          caption: 'Renew',
          color: currentAlert.isImportant ? Theme.of(context).backgroundColor :Theme.of(context).selectedRowColor,
          icon: Icons.access_time,
          onTap: () {},
        ),
      ],
      child: ListTile(
        leading: const FaIcon(
          FontAwesomeIcons.airbnb,
        ),
        title: Text(
          currentAlert.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          TimeUtil.convertDatetimeToYMMMED(currentAlert.expireTime),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(
          Icons.alarm,
          color: Colors.grey,
          size: 20,
        ),
        tileColor: currentAlert.isImportant ? Colors.pink.shade300 : Colors.white10,
        dense: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
        itemBuilder: (context, position) {
          return
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  buildSlidable(context, position),
                  Divider(
                    color: Theme.of(context).colorScheme.background,
                  )
                ]
          );
        },
        itemCount: allAlert.length,
      )),
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
