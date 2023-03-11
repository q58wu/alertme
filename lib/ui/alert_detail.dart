import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:alert_me/ui/form_date_picker.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../usecase/push_notification_service.dart';

class AlertDetailPage extends StatefulWidget{
  final int? id;

  const AlertDetailPage(this.id, {super.key});

  @override
  State createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  _AlertDetailPageState();
  late Alert updatedAlert;
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
    _id = widget.id ?? -1;
    initData();
  }

  Future<void> initData() async {
    Alert current = await AlarmDatabase.instance.readAlert(_id);

    setState(() {
      title = current.title;
      description = current.description;
      isImportant = current.isImportant;
      needToRepeat = current.repeatIntervalTimeInDays != 0 ||
          current.repeatIntervalTimeInWeeks != 0 ||
          current.repeatIntervalTimeInMinutes != 0 ||
          current.repeatIntervalTimeInHours != 0;
      daysToRepeat = current.repeatIntervalTimeInDays;
      weekToRepeat = current.repeatIntervalTimeInWeeks;
      hoursToRepeat = current.repeatIntervalTimeInHours;
      minutesToRepeat = current.repeatIntervalTimeInMinutes;
      nextNotifyDate = current.expireTime;
      nextNotifyTime = TimeOfDay(hour: nextNotifyDate.hour, minute: nextNotifyDate.minute);
      titleTextController.text = title;
      descriptionTextController.text = description;
    });
  }

  TextEditingController titleTextController = TextEditingController.fromValue(const TextEditingValue(text: ""));
  TextEditingController descriptionTextController = TextEditingController.fromValue(const TextEditingValue(text: ""));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alert')
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
                          controller: titleTextController,
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
                        controller: descriptionTextController,
                        onChanged: (value) {
                          description = value;
                        },
                        maxLines: 5,
                      ),
                      Divider(
                        height: 20,
                        color: Theme.of(context).colorScheme.background,
                      ),
                      FormDateAndTimePicker(
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
                          if(_formKey.currentState!.validate()){

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
                              nextNotifyDate = DateTime(nextNotifyDate.year, nextNotifyDate.month,
                                  nextNotifyDate.day, nextNotifyTime.hour, nextNotifyTime.minute);

                              updatedAlert = Alert(
                                  id: _id,
                                  isImportant: isImportant,
                                  title: title,
                                  description: description,
                                  setTime: DateTime.now(),
                                  expireTime: nextNotifyDate,
                                  repeatIntervalTimeInDays: !needToRepeat ? 0 : daysToRepeat,
                                  repeatIntervalTimeInHours: !needToRepeat ? 0 : hoursToRepeat,
                                  repeatIntervalTimeInMinutes: !needToRepeat ? 0 : minutesToRepeat,
                                  repeatIntervalTimeInWeeks: !needToRepeat ? 0 : weekToRepeat);

                              AlarmDatabase.instance
                                  .update(updatedAlert)
                                  .then((value) => (value > 0) ? NotificationService().cancelNotification(_id) : Future.error("Update Failed"))
                                  .then((value) => needToRepeat ? NotificationService().scheduleNotificationFromAlert(updatedAlert) : Future.error("no more notification needed"));

                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 5,
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