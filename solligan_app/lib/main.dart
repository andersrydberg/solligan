import 'package:flutter/material.dart';
import 'helpers/parsers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Senaste observationer'),
          ),
          body: FutureBuilder(
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                final data = snapshot.data
                  ?..removeWhere((element) => element.value == null)
                  ..sort((a, b) => double.parse(b.value!.value)
                      .compareTo(double.parse(a.value!.value)));
                return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    final station = data[index];
                    final name = station.name;
                    final value = station.value?.value.toString();
                    return ListTile(
                      title: Text(name),
                      trailing: Text(value ?? 'värde saknas'),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('Kunde inte ladda temperaturdata'),
                );
              }
            },
            future: getTemperatureData(),
          )),
    );
  }
}
