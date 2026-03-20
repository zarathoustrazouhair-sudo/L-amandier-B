import 'package:flutter/material.dart';

class IncidentDetailScreen extends StatelessWidget {
  final String id;
  const IncidentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Incident Detail: $id')));
  }
}
