import 'package:alert_me/domain/database/alertDatabase.dart';
import 'package:alert_me/domain/model/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
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

  Widget saveButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        newAlert = Alert(isImportant: isImportant,
            title: title,
            description: description,
            setTime: DateTime.now(),
            expireTime: date);

        AlarmDatabase.instance.create(newAlert);
        Navigator.of(context).pop();
      }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form widgets'),
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
                            labelText: 'Title',
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
                            labelText: 'Description',
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