import 'package:flutter/material.dart';


class AlertFilterBar extends StatefulWidget {
  final Function(String val) onFilterChanged;
  final Function(String val) onOrderChanged;

  const AlertFilterBar({super.key, required this.onFilterChanged, required this.onOrderChanged});

  @override
  State<AlertFilterBar> createState() => _AlertFilterBarState();
}

class _AlertFilterBarState extends State<AlertFilterBar> {
  String _currentFilter = "all";
  String _currentOrder = 'Ascending';
  
  void showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
                padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'SORT BY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  RadioListTile(
                    title: const Text('Ascending'),
                    value: 'Ascending',
                    groupValue: _currentOrder,
                    onChanged: (value) {
                      setState(() {
                        _currentOrder = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Descending'),
                    value: 'Descending',
                    groupValue: _currentOrder,
                    onChanged: (value) {
                      setState(() {
                        _currentOrder = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onOrderChanged(_currentOrder);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'FILTER BY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      FilterChip (
                        label: const Text('All'),
                        selected: _currentFilter == 'all',
                        onSelected: (selected) {
                          setState(() {
                            if (selected) _currentFilter = 'all';
                          });
                        },
                      ),
                      const SizedBox(width: 8.0),
                      FilterChip (
                        label: const Text('Pending'),
                        selected: _currentFilter == 'pending',
                        onSelected: (selected) {
                          setState(() {
                            if (selected) _currentFilter ='pending';
                          });
                        },
                      ),
                      const SizedBox(width: 8.0),
                      FilterChip (
                        label: const Text('Triggered'),
                        selected: _currentFilter == 'triggered',
                        onSelected: (selected) {
                          setState(() {
                            if (selected) _currentFilter ='triggered';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(_currentFilter);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showSortBottomSheet();
                },
                icon: Icon(Icons.sort, color: Colors.grey[300]),
                label: const Text(
                  'Sort',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showFilterBottomSheet();
                },
                icon: Icon(Icons.filter_list, color: Colors.grey[300]),
                label: const Text(
                  'Filter',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
  }
}
