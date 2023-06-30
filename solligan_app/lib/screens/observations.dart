import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solligan_app/helpers/observation_data_provider.dart';

class Observations extends StatefulWidget {
  const Observations({super.key});

  @override
  State<Observations> createState() => _ObservationsState();
}

class _ObservationsState extends State<Observations> {
  @override
  void initState() {
    super.initState();
    context.read<ObservationDataProvider>().setParameter('1');
  }

  @override
  Widget build(BuildContext context) {
    final dataModel = context.watch<ObservationDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senaste observationer'),
      ),
      body: Builder(
        builder: (context) {
          final data = dataModel.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: data.length,
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
        },
      ),
    );
  }
}
