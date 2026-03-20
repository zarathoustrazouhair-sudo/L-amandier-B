import 'package:flutter/material.dart';

class AgPresenceScreen extends StatelessWidget {
  final String id;
  const AgPresenceScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('AG Presence: $id')));
  }
}
