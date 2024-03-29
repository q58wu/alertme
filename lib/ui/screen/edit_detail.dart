import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/ui/component/alert_options.dart';
import 'package:alert_me/ui/component/alert_title_description.dart';
import 'package:flutter/cupertino.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:alert_me/ui/component/alert_date_time.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:workmanager/workmanager.dart';
import '../../domain/mapper/TimeUtil.dart';
import '../../domain/util/WorkManager+AlertHelper.dart';
import '../../usecase/push_notification_service.dart';

class AlertDetailPage extends StatefulWidget {
  final Alert alert;

  const AlertDetailPage({required this.alert, super.key});

  @override
  State createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  _AlertDetailPageState();

  late Alert updatedAlert;
  late Alert currentAlert;
  int _id = 0;
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  bool isImportant = false;
  bool needToRepeat = false;
  int daysToRepeat = 0;
  int weekToRepeat = 0;
  int minutesToRepeat = 0;
  int hoursToRepeat = 0;
  DateTime nextNotifyDate = DateTime.now();
  TimeOfDay nextNotifyTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    currentAlert = widget.alert;

    _id = currentAlert.id ?? -1;
    title = currentAlert.title;
    description = currentAlert.description;
    isImportant = currentAlert.isImportant;
    daysToRepeat = currentAlert.repeatIntervalTimeInDays;
    weekToRepeat = currentAlert.repeatIntervalTimeInWeeks;
    hoursToRepeat = currentAlert.repeatIntervalTimeInHours;
    minutesToRepeat = currentAlert.repeatIntervalTimeInMinutes;
    needToRepeat = daysToRepeat != 0 ||
        weekToRepeat != 0 ||
        hoursToRepeat != 0 ||
        minutesToRepeat != 0;
    nextNotifyDate = currentAlert.expireTime;
    nextNotifyTime =
        TimeOfDay(hour: nextNotifyDate.hour, minute: nextNotifyDate.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Alert')),
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
                          title: title,
                          description: description,
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
                        time: TimeOfDay(
                            hour: nextNotifyTime.hour,
                            minute: nextNotifyTime.minute),
                        dateOnChanged: (value) {
                          setState(() {
                            nextNotifyDate = value;
                          });
                        },
                        timeOnChanged: (value) {
                          setState(() {
                            nextNotifyTime = value;
                          });
                        },
                      ),
                      AlertOptions(
                          options: Options(needToRepeat, weekToRepeat, daysToRepeat, hoursToRepeat, minutesToRepeat, isImportant),
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
                      EasyButton(
                        idleStateWidget: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        loadingStateWidget: const CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        useEqualLoadingStateWidgetDimension: true,
                        useWidthAnimation: false,
                        width: 250.0,
                        height: 40.0,
                        borderRadius: 4.0,
                        elevation: 2.0,
                        contentGap: 6.0,
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
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
                            } else {
                              nextNotifyDate = DateTime(
                                  nextNotifyDate.year,
                                  nextNotifyDate.month,
                                  nextNotifyDate.day,
                                  nextNotifyTime.hour,
                                  nextNotifyTime.minute);

                              updatedAlert = Alert(
                                  id: _id,
                                  status: AlertStatus.pending,
                                  isImportant: isImportant,
                                  title: title,
                                  description: description,
                                  setTime: DateTime.now(),
                                  expireTime: nextNotifyDate,
                                  repeatIntervalTimeInDays:
                                      !needToRepeat ? 0 : daysToRepeat,
                                  repeatIntervalTimeInHours:
                                      !needToRepeat ? 0 : hoursToRepeat,
                                  repeatIntervalTimeInMinutes:
                                      !needToRepeat ? 0 : minutesToRepeat,
                                  repeatIntervalTimeInWeeks:
                                      !needToRepeat ? 0 : weekToRepeat);

                              // Cancel previous in-flight notification and create a new one
                              if (updatedAlert != currentAlert) {
                                AlarmDatabase.instance
                                    .update(updatedAlert)
                                    .then((value) => (value > 0)
                                        ? WorkManagerAlertHelper
                                            .updateExistingNotification(updatedAlert)
                                        : Future.error);
                              }

                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
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
