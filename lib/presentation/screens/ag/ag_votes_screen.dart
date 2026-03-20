import 'package:flutter/material.dart';

class AgVotesScreen extends StatelessWidget {
  final String id;
  const AgVotesScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('AG Votes: $id')));
  }
}
