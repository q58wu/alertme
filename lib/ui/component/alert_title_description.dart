import 'package:flutter/material.dart';

class AlertTitleDescription extends StatelessWidget {
  final String? title;
  final String? description;
  final GlobalKey<FormState> formKey; // TODO kejun: not sure what's this
  final ValueChanged<String> titleOnChanged;
  final ValueChanged<String> descriptionOnChanged;

  const AlertTitleDescription({super.key,
    this.title,
    this.description,
    required this.formKey,
    required this.titleOnChanged,
    required this.descriptionOnChanged});

  @override
  Widget build(BuildContext context) {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().isEmpty) {
                  return 'Task title cannot be empty.';
                }
                return null;
              },
              initialValue: title,
              decoration: const InputDecoration(
                filled: true,
                hintText: 'Enter a title...',
                labelText: 'Task Title',
              ),
              onChanged: (value) {
                titleOnChanged(value);
              },
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          TextFormField(
            initialValue: description,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              hintText: 'Enter a description...',
              labelText: 'Task Description',
            ),
            onChanged: (value) {
              descriptionOnChanged(value);
            },
            maxLines: 5,
          ),
          const SizedBox(
            height: 24,
          ),
          Divider(
            height: 20,
            color: Theme.of(context).colorScheme.background,
          ),
          const SizedBox(
            height: 12,
          ),
          ]
    );

  }
}