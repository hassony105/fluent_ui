import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'auto_suggest_box.dart';

class NumberBoxPage extends StatefulWidget {
  const NumberBoxPage({Key? key}) : super(key: key);

  @override
  State<NumberBoxPage> createState() => _NumberBoxPageState();
}

class _NumberBoxPageState extends State<NumberBoxPage> with PageMixin {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20.0;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboBoxState>(debugLabel: 'Combobox Key');

  int? numberBoxValue = 0;

  void _valueChanged(int? newValue){
    setState(() {
      numberBoxValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('NumberBox'),
        commandBar: ToggleSwitch(
          checked: disabled,
          onChanged: (v) {
            setState(() => disabled = v);
          },
          content: const Text('Disabled'),
        ),
      ),
      children: [
        const Text('Use a number box to select a number. '
            'The selection can be applied in compact or in inline mode.'),
        subtitle(
          content: const Text(
            'A NumberBox in inline mode',
          ),
        ),
        CardHighlight(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValue,
              onChanged: _valueChanged,
              mode: SpinButtonPlacementMode.inline,
            ),
          ]),
          codeSnippet: '''NumberBox(
  value: numberBoxValue,
  onChanged: _valueChanged,
  mode: SpinButtonPlacementMode.inline,
),
''',
        ),

        subtitle(
          content: const Text(
            'A NumberBox in compact mode',
          ),
        ),
        CardHighlight(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValue,
              onChanged: _valueChanged,
              mode: SpinButtonPlacementMode.compact,
            ),
          ]),
          codeSnippet: '''NumberBox(
  value: numberBoxValue,
  onChanged: _valueChanged,
  mode: SpinButtonPlacementMode.compact,
),
''',
        ),
      ],
    );
  }

  Map<String, Color> colors = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
    'Grey': Colors.grey,
    'Magenta': Colors.magenta,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
  };

  static const fontSizes = <double>[
    8,
    9,
    10,
    11,
    12,
    14,
    16,
    18,
    20,
    24,
    28,
    36,
    48,
    72,
  ];
}
