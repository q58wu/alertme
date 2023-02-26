import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:alert_me/ui/form_date_picker.dart';

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
  int daysToRepeat = 0;
  //int monthsToRepeat = 0; // unused
  int weekToRepeat = 0;
  DateTime nextNotifyDate = DateTime.now();

  Widget saveButton() => IconButton(
      icon: const Icon(Icons.save),
      onPressed: () async {
        newAlert = Alert(isImportant: isImportant,
            title: title,
            description: description,
            setTime: DateTime.now(),
            expireTime: date,
            repeatIntervalTimeInDays: weekToRepeat * 7 + daysToRepeat);

        AlarmDatabase.instance.create(newAlert);
        Navigator.of(context).pop();
      }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Alert'),
        actions: [saveButton()],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
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
                        TextFormField(
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
                        FormDatePicker(
                          date: date,
                          onChanged: (value) {
                            setState(() {
                              date = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Repeat every',
                                style: Theme.of(context).textTheme.bodyLarge),
                            /*TextButton(
                              child: Text('$monthsToRepeat Month(s)'),
                              onPressed: () async {
                                  Picker(
                                      adapter: PickerDataAdapter<int>(
                                          pickerData: [1,2,3,4,5,6,7,8,9,10,11,12]
                                      ),
                                      changeToFirst: true,
                                      hideHeader: false,
                                      onConfirm: (Picker picker, List value) {
                                        setState(() {
                                          monthsToRepeat = picker.getSelectedValues()[0];
                                        });
                                      }
                                  ).showModal(this.context);
                              },
                            ),*/
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
      ),
    );
  }
}