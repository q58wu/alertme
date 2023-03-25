import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

class AlertOptions extends StatefulWidget {
  final Options options;
  final ValueChanged<Options> optionsOnChange;

  const AlertOptions(
      {super.key, required this.options, required this.optionsOnChange});

  @override
  State<AlertOptions> createState() => AlertOptionsState();
}

class AlertOptionsState extends State<AlertOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Repeat?', style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: widget.options.isRepeat,
                onChanged: (enabled) {
                  widget.optionsOnChange(widget.options.setIsRepeat(enabled));
                },
              ),
            ],
          ),
          Offstage(
              offstage: !widget.options.isRepeat,
              child: Column(
                children: [
                  Divider(
                    height: 20,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              )),
          Offstage(
              offstage: !widget.options.isRepeat,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Repeat every',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              )),
          Offstage(
              offstage: !widget.options.isRepeat,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text('${widget.options.weeks} Week(s)'),
                    onPressed: () async {
                      Picker(
                          adapter: PickerDataAdapter<int>(
                              pickerData: Iterable<int>.generate(13).toList()),
                          changeToFirst: true,
                          hideHeader: false,
                          onConfirm: (Picker picker, List value) {
                            widget.optionsOnChange(widget.options
                                .setRepeatWeeks(picker.getSelectedValues()[0]));
                          }).showModal(this.context);
                    },
                  ),
                  TextButton(
                    child: Text('${widget.options.days} Day(s)'),
                    onPressed: () async {
                      Picker(
                          adapter: PickerDataAdapter<int>(
                              pickerData: Iterable<int>.generate(32).toList()),
                          changeToFirst: true,
                          hideHeader: false,
                          onConfirm: (Picker picker, List value) {
                            widget.optionsOnChange(widget.options
                                .setRepeatDays(picker.getSelectedValues()[0]));
                          }).showModal(this.context);
                    },
                  )
                ],
              )),
          Offstage(
              offstage: !widget.options.isRepeat,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text('${widget.options.hours} Hour(s)'),
                    onPressed: () async {
                      Picker(
                          adapter: PickerDataAdapter<int>(
                              pickerData: Iterable<int>.generate(25).toList()),
                          changeToFirst: true,
                          hideHeader: false,
                          onConfirm: (Picker picker, List value) {
                            widget.optionsOnChange(widget.options
                                .setRepeatHours(picker.getSelectedValues()[0]));
                          }).showModal(this.context);
                    },
                  ),
                  TextButton(
                    child: Text('${widget.options.minutes} Minute(s)'),
                    onPressed: () async {
                      Picker(
                          adapter: PickerDataAdapter<int>(
                              pickerData: Iterable<int>.generate(61).toList()),
                          changeToFirst: true,
                          hideHeader: false,
                          onConfirm: (Picker picker, List value) {
                            widget.optionsOnChange(widget.options
                                .setRepeatMinutes(
                                    picker.getSelectedValues()[0]));
                          }).showModal(this.context);
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
              Text('Important', style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: widget.options.isImportant,
                onChanged: (enabled) {
                  widget
                      .optionsOnChange(widget.options.setIsImportant(enabled));
                },
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
        ]);
  }
}

class Options {
  bool isRepeat = false;
  int weeks = 0;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  bool isImportant = false;

  Options(this.isRepeat, this.weeks, this.days, this.hours, this.minutes,
      this.isImportant);

  Options setIsRepeat(bool isRepeat) {
    this.isRepeat = isRepeat;
    return this;
  }

  Options setRepeatWeeks(int weeks) {
    this.weeks = weeks;
    return this;
  }

  Options setRepeatDays(int days) {
    this.days = days;
    return this;
  }

  Options setRepeatHours(int hours) {
    this.hours = hours;
    return this;
  }

  Options setRepeatMinutes(int minutes) {
    this.minutes = minutes;
    return this;
  }

  Options setIsImportant(bool isImportant) {
    this.isImportant = isImportant;
    return this;
  }
}
