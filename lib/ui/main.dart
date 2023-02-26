import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:alert_me/ui/add_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlertMe',
      theme: ThemeData(
        primarySwatch: Colors.green,
        /*useMaterial3: true*/
      ),
      home: const MyHomePage(title: 'AlertMe'),
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
    return Slidable(
      actionPane: const SlidableScrollActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Renew',
          color: Colors.blue,
          icon: Icons.access_time_filled,
          onTap: () {
            print('SlidableActionWidget pressed ...');
          },
        ),
      ],
      child: ListTile(
        leading: const FaIcon(
          FontAwesomeIcons.airFreshener,
        ),
        title: Text(
          currentAlert.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          TimeUtil.convertDatetimeToYMMMED(currentAlert.expireTime),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Icon(
          Icons.alarm,
          color: Colors.grey,
          size: 20,
        ),
        tileColor: Colors.white10,
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
          return buildSlidable(context, position);
        },
        itemCount: allAlert.length,
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddAlertPage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
