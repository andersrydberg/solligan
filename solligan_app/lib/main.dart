import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solligan_app/helpers/observation_data_provider.dart';

import 'package:solligan_app/screens/observations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ObservationDataProvider(),
      child: const MaterialApp(
        home: Observations(),
      ),
    );
  }
}
