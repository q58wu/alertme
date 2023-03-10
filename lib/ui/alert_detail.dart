import 'dart:developer';

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
  DateTime date = DateTime.now();
  bool isImportant = false;
  bool needToRepeat = false;
  int daysToRepeat = 0;
  //int monthsToRepeat = 0; // unused
  int weekToRepeat = 0;
  DateTime nextNotifyDate = DateTime.now();


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
      needToRepeat = current.repeatIntervalTimeInDays != 0;
      daysToRepeat = current.repeatIntervalTimeInDays;

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
        title: Text('${date}')
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
                              TextButton(
                                child: Text('$weekToRepeat Week(s)'),
                                onPressed: () async {
                                  Picker(
                                      adapter: PickerDataAdapter<int>(
                                          pickerData: [1,2,3,4,5,6,7,8,9,10,11,12]
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
                                          pickerData: [1,2,3,4,5,6,7,8,9,10,11,
                                            12,13,14,15,16,17,18,19,20,21,22,
                                            23,24,25,26,27,28,29,30,31]
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

                            if(needToRepeat && weekToRepeat == 0 && daysToRepeat == 0){
                              showTopSnackBar(
                                Overlay.of(context)!,
                                const CustomSnackBar.error(
                                  message:
                                  "Please make sure repeat interval is greater than 0 day.",
                                ),
                              );
                            }
                            else{
                              updatedAlert = Alert(
                                  id: _id,
                                  isImportant: isImportant,
                                  title: title,
                                  description: description,
                                  setTime: DateTime.now(),
                                  expireTime: date,
                                  repeatIntervalTimeInDays: weekToRepeat * 7 + daysToRepeat);

                              AlarmDatabase.instance
                                  .update(updatedAlert)
                                  .then((value) => (value > 0) ? NotificationService().cancelNotification(_id) : Future.error("Update Failed"))
                                  .then((value) => NotificationService().scheduleNotificationFromAlert(updatedAlert));

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