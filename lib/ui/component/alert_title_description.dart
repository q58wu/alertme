import 'package:flutter/material.dart';

class AlertTitleDescription extends StatelessWidget {
  final TextEditingController? titleController;
  final TextEditingController? descriptionController;
  final GlobalKey<FormState> formKey; // TODO: not sure what's this
  final ValueChanged<String> titleOnChanged;
  final ValueChanged<String> descriptionOnChanged;

  const AlertTitleDescription(
      {super.key,
      required this.titleController,
      required this.descriptionController,
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
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return 'Task title cannot be empty.';
                }
                return null;
              },
              controller: titleController,
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
            controller: descriptionController,
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
        ]);
  }
}
