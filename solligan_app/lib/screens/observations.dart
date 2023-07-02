import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solligan_app/helpers/observation_data_provider.dart';

class Observations extends StatefulWidget {
  const Observations({super.key});

  @override
  State<Observations> createState() => _ObservationsState();
}

class _ObservationsState extends State<Observations>
    with TickerProviderStateMixin {
  final _textFieldController = TextEditingController();
  late final _iconAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final _rotateAnimation =
      Tween<double>(begin: 360.0, end: 0.0).animate(_iconAnimationController);

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
            children: [
              Text(dataModel.readableDate ?? ''),
              Text(dataModel.readableTime ?? ''),
            ],
          ),
          AnimatedUpdateIcon(
            animation: _rotateAnimation,
            callback: () {
              _iconAnimationController.forward();
              dataModel.requestUpdate().then((updated) {
                _iconAnimationController.stop();
                _iconAnimationController.reset();
                if (!updated) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Inga nya observationer än...'),
                  ));
                }
              });
            },
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const OptionsBottomSheet(),
              );
            },
            icon: const Icon(Icons.tune),
          ),
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

class OptionsBottomSheet extends StatefulWidget {
  const OptionsBottomSheet({super.key});

  @override
  State<OptionsBottomSheet> createState() => _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<OptionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final dataModel = Provider.of<ObservationDataProvider>(context);
    SortOption? selected = dataModel.selectedSortOption;
    bool? checked = dataModel.omitMissing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CheckboxListTile(
          title: const Text('Dölj saknade värden'),
          value: checked,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              checked = value;
            });
            if (value != null) dataModel.omitMissing = value;
          },
        ),
        const ListTile(
          title: Text('Sortera stationerna:'),
        ),
        RadioListTile(
          title: const Text('i bokstavsordning'),
          value: SortOption.alphabetic,
          groupValue: selected,
          onChanged: (value) {
            setState(() {
              selected = value;
            });
            if (value != null) dataModel.selectedSortOption = value;
          },
        ),
        RadioListTile(
          title: const Text('från nord till syd'),
          value: SortOption.northToSouth,
          groupValue: selected,
          onChanged: (value) {
            setState(() {
              selected = value;
            });
            if (value != null) dataModel.selectedSortOption = value;
          },
        ),
        RadioListTile(
          title: const Text('från syd till nord'),
          value: SortOption.southToNorth,
          groupValue: selected,
          onChanged: (value) {
            setState(() {
              selected = value;
            });
            if (value != null) dataModel.selectedSortOption = value;
          },
        ),
        RadioListTile(
          title: const Text('från högst värde till lägst'),
          value: SortOption.highToLow,
          groupValue: selected,
          onChanged: (value) {
            setState(() {
              selected = value;
            });
            if (value != null) dataModel.selectedSortOption = value;
          },
        ),
        RadioListTile(
          title: const Text('från lägst värde till högst'),
          value: SortOption.lowToHigh,
          groupValue: selected,
          onChanged: (value) {
            setState(() {
              selected = value;
            });
            if (value != null) dataModel.selectedSortOption = value;
          },
        ),
      ],
    );
  }
}

class AnimatedUpdateIcon extends AnimatedWidget {
  final VoidCallback callback;
  final Animation<double> animation;

  const AnimatedUpdateIcon(
      {Key? key, required this.animation, required this.callback})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
        icon: const Icon(Icons.update),
        onPressed: callback,
      ),
    );
  }
}
