import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class AlertDateTime extends StatefulWidget {
  final DateTime date; // MM/DD/YYYY
  final TimeOfDay time; // HH/MM
  final ValueChanged<DateTime> dateOnChanged;
  final ValueChanged<TimeOfDay> timeOnChanged;

  const AlertDateTime(
      {super.key,
      required this.date,
      required this.time,
      required this.dateOnChanged,
      required this.timeOnChanged});

  @override
  State<AlertDateTime> createState() => AlertDateTimeState();
}

class AlertDateTimeState extends State<AlertDateTime> {
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
                      widget.dateOnChanged(newDate);
                    },
                  )
                ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    child: const Text('Pick'),
                    onPressed: () async {
                      var newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      // Don't change the date if the date picker returns null.
                      if (newTime == null) {
                        return;
                      }
                      widget.timeOnChanged(newTime);
                    },
                  )
                ]
            ),
            Divider(
              height: 20,
              color: Theme.of(context).colorScheme.background,
            ),
          ],
    );
  }
}
