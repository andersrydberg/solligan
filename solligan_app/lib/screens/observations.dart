import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solligan_app/helpers/observation_data_provider.dart';

class Observations extends StatefulWidget {
  const Observations({super.key});

  @override
  State<Observations> createState() => _ObservationsState();
}

class _ObservationsState extends State<Observations> {
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObservationDataProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataModel = context.watch<ObservationDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperatur'),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(dataModel.readableDate ?? ''),
              Text(dataModel.readableTime ?? ''),
            ],
          ),
          IconButton(
              onPressed: dataModel.requestUpdate,
              icon: const Icon(Icons.update))
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _textFieldController,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (string) => dataModel.searchString = string,
            decoration: InputDecoration(
              labelText: 'Sök station',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _textFieldController.clear();
                  dataModel.searchString = '';
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          Expanded(
            child: Builder(
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
                    final value = station.value?.value;
                    return ListTile(
                      title: Text(name),
                      trailing: Text(value ?? 'värde saknas'),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: ListView(
          children: const <Widget>[
            Text('Hello'),
            Text('World!'),
          ],
        ),
      ),
    );
  }
}
