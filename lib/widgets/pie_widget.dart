// pie_card.dart
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/widget_previews.dart';


class PieCard extends StatelessWidget {
  final List<Map<String, dynamic>> pieData;
  final Map<String, Color> colorByType;

  const PieCard({
    super.key,
    required this.pieData,
    required this.colorByType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 350,
      height: 300,
      child: pieData.isEmpty
          ? const Center(child: Text('No data'))
          : Chart(
              key: ValueKey(
                pieData.map((e) => '${e['type']}:${e['value']}').join('|'),
              ),
              data: pieData,
              variables: {
                'type': Variable(
                  accessor: (Map map) => map['type'] as String,
                ),
                'value': Variable(
                  accessor: (Map map) => map['value'] as num,
                ),
              },
              transforms: [
                Proportion(variable: 'value', as: 'percent'),
              ],
              marks: [
                IntervalMark(
                  position: Varset('percent') / Varset('type'),
                  label: LabelEncode(
                    encoder: (tuple) => Label(tuple['value'].toString()),
                  ),
                  color: ColorEncode(
                    encoder: (tuple) =>
                        colorByType[tuple['type']] ?? Colors.grey,
                  ),
                  modifiers: [StackModifier()],
                ),
              ],
              coord: PolarCoord(
                transposed: true,
                dimCount: 1,
                dimFill: 1.05,
              ),
            ),
    );
  }
}

@Preview(name: 'PieChart')
Widget pieCardPreview() {
  return PieCard(
    pieData: const [
      {'type': 'Company1', 'index': 0, 'value': 120},
      {'type': 'Company2', 'index': 1, 'value': 14},
    ],
    colorByType: const {
      'Company1': Colors.blue,
      'Company2': Colors.orange,
    },
  );
}
