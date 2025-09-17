import 'package:flutter/material.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: Text('Day ${index + 1}'),
          trailing: const Text('25°C'),
        );
      },
    );
  }
}