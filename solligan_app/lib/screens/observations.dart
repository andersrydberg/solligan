import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solligan_app/helpers/constants.dart';
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
      AnimationController(vsync: this, duration: const Duration(seconds: 20));
  // animate 40 revolutions in 20 seconds
  late final _rotateAnimation = Tween<double>(begin: 0.0, end: 80 * math.pi)
      .animate(_iconAnimationController);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObservationDataProvider>().init();
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataModel = context.watch<ObservationDataProvider>();
    const parameters = weatherParameters;

    return Scaffold(
      appBar: AppBar(
        title: Text(parameters[dataModel.selectedParameter]!['title']!),
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
                    showCloseIcon: true,
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
                if (dataModel.showCircularProgressIndicator) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = dataModel.data!;
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
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Column(
                children: [
                  ListTile(
                    title: Text(
                      'Välj parameter',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Builder(builder: (context) {
                    String selected = dataModel.selectedParameter;
                    return Wrap(
                      spacing: 5.0,
                      children: [
                        for (final entry in parameters.entries)
                          ChoiceChip(
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value['title']!,
                                ),
                                Text(
                                  entry.value['summary']!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            selected: entry.key == selected,
                            onSelected: (value) {
                              if (value) {
                                dataModel.selectedParameter = entry.key;
                              }
                              Scaffold.of(context).closeDrawer();
                            },
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
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

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
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
            ListTile(
              title: Text(
                'Sortera stationerna:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
        ),
      ),
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
