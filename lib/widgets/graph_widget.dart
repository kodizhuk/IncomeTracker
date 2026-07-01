// graph_card.dart
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class GraphCard extends StatelessWidget {
  final List<Map<String, dynamic>> graphData;
  final Map<String, Color> colorByType;
  final double maxYState;

  const GraphCard({
    super.key,
    required this.graphData,
    required this.colorByType,
    required this.maxYState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 300,
      child: (graphData.isEmpty ||
              !graphData.any((e) => (e['value'] as num) > 0))
          ? const Center(child: Text('No data'))
          : Chart(
              key: ValueKey(
                graphData
                    .map((e) =>
                        '${e['type']}:${e['index']}:${e['value']}')
                    .join('|'),
              ),
              data: graphData,
              variables: {
                'index': Variable(
                  accessor: (Map map) => map['index'].toString(),
                ),
                'type': Variable(
                  accessor: (Map map) => map['type'] as String,
                ),
                'value': Variable(
                  accessor: (Map map) => (map['value'] as num).toInt(),
                  scale: LinearScale(min: 0, max: maxYState * 2),
                ),
              },
              marks: [
                IntervalMark(
                  position: Varset('index') * Varset('value') / Varset('type'),
                  shape: ShapeEncode(value: RectShape(labelPosition: 1)),
                  color: ColorEncode(
                    encoder: (tuple) =>
                        colorByType[tuple['type']] ?? Colors.grey,
                  ),
                  label: LabelEncode(
                    encoder: (tuple) => Label(
                      tuple['value'].toString(),
                      LabelStyle(textStyle: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  modifiers: [StackModifier()],
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
            ),
    );
  }
}
