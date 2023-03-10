import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:alert_me/ui/form_date_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../usecase/push_notification_service.dart';

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
  DateTime date = DateTime.now();
  bool isImportant = false;
  bool needToRepeat = false;
  int daysToRepeat = 0;
  int weekToRepeat = 0;
  int minutesToRepeat = 0;
  int hoursToRepeat = 0;
  DateTime nextNotifyDate = DateTime.now();

  Widget saveButton(BuildContext context, GlobalKey<FormState> key) => IconButton(
      icon: const Icon(Icons.save),
      onPressed: () async {
        if(key.currentState!.validate()){

          if(needToRepeat && weekToRepeat == 0 &&
              daysToRepeat == 0 && hoursToRepeat == 0 &&
              minutesToRepeat == 0){
            showTopSnackBar(
              Overlay.of(context)!,
              const CustomSnackBar.error(
                message:
                "Please make sure repeat interval is greater than 0 minutes.",
              ),
            );
          }
          else{
            newAlert = Alert(isImportant: isImportant,
                title: title,
                description: description,
                setTime: DateTime.now(),
                expireTime: date,
                repeatIntervalTimeInDays: daysToRepeat,
                repeatIntervalTimeInHours: hoursToRepeat,
                repeatIntervalTimeInMinutes: minutesToRepeat,
                repeatIntervalTimeInWeeks: weekToRepeat);

                AlarmDatabase.instance.create(newAlert).then((newAlert) =>
                    (newAlert.id != null)
                        ? NotificationService().scheduleNotification(
                            id: newAlert.id!,
                            scheduledNotificationDateTime: date)
                        : Future.error("Insertion Failed"));

                Navigator.of(context).pop();
          }
        }
      }
  );

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
                        Form(
                        key: _formKey,
                        autovalidateMode : AutovalidateMode.onUserInteraction,
                          child:
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty || value.trim().isEmpty) {
                                return 'Task title cannot be empty.';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: 'Enter a title...',
                              labelText: 'Task Title',
                            ),
                            onChanged: (value) {
                              setState(() {
                                title = value;
                              });
                            },
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText: 'Enter a description...',
                            labelText: 'Task Description',
                          ),
                          onChanged: (value) {
                            description = value;
                          },
                          maxLines: 5,
                        ),
                        Divider(
                          height: 20,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        FormDatePicker(
                          date: date,
                          onChanged: (value) {
                            setState(() {
                              date = value;
                            });
                          },
                        ),
                        Divider(
                          height: 20,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Repeat?',
                                style: Theme.of(context).textTheme.bodyLarge),
                            Switch(
                              value: needToRepeat,
                              onChanged: (enabled) {
                                setState(() {
                                  needToRepeat = enabled;
                                });
                              },
                            ),
                          ],
                        ),
                        Offstage(
                          offstage: !needToRepeat,
                          child: Divider(
                          height: 20,
                          color: Theme.of(context).colorScheme.background,
                        )),
                        Offstage(
                            offstage: !needToRepeat,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Repeat every', style: Theme.of(context).textTheme.bodyLarge),
                              ],
                        )),
                        Offstage(
                            offstage: !needToRepeat,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text('$weekToRepeat Week(s)'),
                                  onPressed: () async {
                                    Picker(
                                        adapter: PickerDataAdapter<int>(
                                            pickerData: Iterable<int>.generate(13).toList()
                                        ),
                                        changeToFirst: true,
                                        hideHeader: false,
                                        onConfirm: (Picker picker, List value) {
                                          setState(() {
                                            weekToRepeat = picker.getSelectedValues()[0];
                                          });
                                        }
                                    ).showModal(this.context);
                                  },
                                ),
                                TextButton(
                                  child: Text('$daysToRepeat Day(s)'),
                                  onPressed: () async {
                                    Picker(
                                        adapter: PickerDataAdapter<int>(
                                            pickerData: Iterable<int>.generate(32).toList()
                                        ),
                                        changeToFirst: true,
                                        hideHeader: false,
                                        onConfirm: (Picker picker, List value) {
                                          setState(() {
                                            daysToRepeat = picker.getSelectedValues()[0];
                                          });
                                        }
                                    ).showModal(this.context);
                                  },
                                )
                              ],
                            )),
                        Offstage(
                            offstage: !needToRepeat,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text('$hoursToRepeat Hour(s)'),
                                  onPressed: () async {
                                    Picker(
                                        adapter: PickerDataAdapter<int>(
                                            pickerData: Iterable<int>.generate(25).toList()
                                        ),
                                        changeToFirst: true,
                                        hideHeader: false,
                                        onConfirm: (Picker picker, List value) {
                                          setState(() {
                                            hoursToRepeat = picker.getSelectedValues()[0];
                                          });
                                        }
                                    ).showModal(this.context);
                                  },
                                ),
                                TextButton(
                                  child: Text('$minutesToRepeat Minute(s)'),
                                  onPressed: () async {
                                    Picker(
                                        adapter: PickerDataAdapter<int>(
                                            pickerData: Iterable<int>.generate(61).toList()
                                        ),
                                        changeToFirst: true,
                                        hideHeader: false,
                                        onConfirm: (Picker picker, List value) {
                                          setState(() {
                                            minutesToRepeat = picker.getSelectedValues()[0];
                                          });
                                        }
                                    ).showModal(this.context);
                                  },
                                ),
                              ],
                            )),
                        Divider(
                          height: 20,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Important',
                                style: Theme.of(context).textTheme.bodyLarge),
                            Switch(
                              value: isImportant,
                              onChanged: (enabled) {
                                setState(() {
                                  isImportant = enabled;
                                });
                              },
                            ),
                          ],
                        ),
                        //Button()
                      ].expand(
                            (widget) => [
                          widget,
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )
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