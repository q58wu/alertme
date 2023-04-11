import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/mapper/TimeUtil.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:alert_me/ui/component/alert_date_time.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:workmanager/workmanager.dart';

import '../../domain/util/WorkManager+AlertHelper.dart';
import '../component/alert_options.dart';
import '../component/alert_title_description.dart';

class AddAlertPage extends StatefulWidget {
  const AddAlertPage({super.key});

  @override
  State createState() => _AddAlertPageState();
}

class _AddAlertPageState extends State<AddAlertPage> {
  late Alert newAlert;
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  TimeOfDay nextNotifyTime = TimeOfDay.now();
  DateTime nextNotifyDate = DateTime.now();
  bool isImportant = false;
  bool needToRepeat = false;
  int daysToRepeat = 0;
  int weekToRepeat = 0;
  int minutesToRepeat = 0;
  int hoursToRepeat = 0;

  Widget saveButton(BuildContext context, GlobalKey<FormState> key) =>
      IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            if (key.currentState!.validate()) {
              if (needToRepeat &&
                  weekToRepeat == 0 &&
                  daysToRepeat == 0 &&
                  hoursToRepeat == 0 &&
                  minutesToRepeat == 0) {
                showTopSnackBar(
                  Overlay.of(context)!,
                  const CustomSnackBar.error(
                    message:
                        "Please make sure repeat interval is greater than 0 minutes.",
                  ),
                );
              }
              else if (needToRepeat &&
                  weekToRepeat == 0 &&
                  daysToRepeat == 0 &&
                  hoursToRepeat == 0 &&
                  minutesToRepeat < 15){
                showTopSnackBar(
                  Overlay.of(context)!,
                  const CustomSnackBar.error(
                    message:
                    "Please make sure repeat interval is at least 15 minutes.",
                  ),
                );
              }
              else {
                var newNextNotifyDate = DateTime(
                    nextNotifyDate.year,
                    nextNotifyDate.month,
                    nextNotifyDate.day,
                    nextNotifyTime.hour,
                    nextNotifyTime.minute);

                newAlert = Alert(
                    isImportant: isImportant,
                    status: AlertStatus.pending,
                    title: title,
                    description: description,
                    setTime: DateTime.now(),
                    expireTime: newNextNotifyDate,
                    repeatIntervalTimeInDays: !needToRepeat ? 0 : daysToRepeat,
                    repeatIntervalTimeInHours:
                        !needToRepeat ? 0 : hoursToRepeat,
                    repeatIntervalTimeInMinutes:
                        !needToRepeat ? 0 : minutesToRepeat,
                    repeatIntervalTimeInWeeks:
                        !needToRepeat ? 0 : weekToRepeat);

                AlarmDatabase.instance
                    .create(newAlert)
                    .then((newAlertCreated) =>  (newAlertCreated.id != null)
                    ?
                onCreateAlertSuccess(newAlertCreated)
                    : Future.error("Insertion Failed"));
              }
            }
          });

  Future<void> onCreateAlertSuccess(Alert newAlertCreated) async {
    await WorkManagerAlertHelper.createNotification(newAlertCreated);
    if (context.mounted) {
      Navigator.of(context).pop(newAlertCreated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Alert'),
        actions: [saveButton(context, _formKey)],
      ),
      body: Scrollbar(
        child: Align(
          alignment: Alignment.topCenter,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...[
                      AlertTitleDescription(
                          formKey: _formKey,
                          titleOnChanged: (value) {
                            setState(() {
                              title = value;
                            });
                          },
                          descriptionOnChanged: (value) {
                            setState(() {
                              description = value;
                            });
                          }),
                      AlertDateTime(
                          date: nextNotifyDate,
                          time: nextNotifyTime,
                          dateOnChanged: (value) {
                            setState(() {
                              nextNotifyDate = value;
                            });
                          },
                          timeOnChanged: (value) {
                            setState(() {
                              nextNotifyTime = value;
                            });
                          }),
                      AlertOptions(
                          options: Options(
                              needToRepeat,
                              weekToRepeat,
                              daysToRepeat,
                              hoursToRepeat,
                              minutesToRepeat,
                              isImportant),
                          optionsOnChange: (value) {
                            setState(() {
                              needToRepeat = value.isRepeat;
                              weekToRepeat = value.weeks;
                              daysToRepeat = value.days;
                              hoursToRepeat = value.hours;
                              minutesToRepeat = value.minutes;
                              isImportant = value.isImportant;
                            });
                          }),
                      //Button()
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
