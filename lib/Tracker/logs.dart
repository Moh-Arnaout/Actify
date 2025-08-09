import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  final List<String> activityLogs;

  LogsPage({required this.activityLogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Activity Logs")),
      body: activityLogs.isEmpty
          ? Center(child: Text("No activities recorded yet."))
          : ListView.builder(
              itemCount: activityLogs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.directions_walk),
                  title: Text(activityLogs[index]),
                );
              },
            ),
    );
  }
}
