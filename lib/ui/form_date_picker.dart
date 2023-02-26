import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  State<FormDatePicker> createState() => FormDatePickerState();
}

class FormDatePickerState extends State<FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Notify me on',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    intl.DateFormat.yMd().format(widget.date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    child: const Text('Pick'),
                    onPressed: () async {
                      var newDate = await showDatePicker(
                        context: context,
                        initialDate: widget.date,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      // Don't change the date if the date picker returns null.
                      if (newDate == null) {
                        return;
                      }
                      widget.onChanged(newDate);
                    },
                  )
                ]
            ),
          ],
    );
  }
}
