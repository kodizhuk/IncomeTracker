// graph_card.dart
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/widget_previews.dart';

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
    //find the max value for to scale the Graph
    final maxValue = graphData
        .map((e) => e['value'] as num)
        .fold<num>(0, (prev, v) => v > prev ? v : prev)
        .toDouble();
    final scaleMax = maxValue ;

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
                  scale: LinearScale(min: 0, max: scaleMax),
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
                  // label: LabelEncode(
                  //   encoder: (tuple) => Label(
                  //     tuple['value'].toString(),
                  //     LabelStyle(textStyle: const TextStyle(fontSize: 10)),
                  //   ),
                  // ),
                  modifiers: [StackModifier()],
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                AxisGuide(
                  tickLine: TickLine(length: 5),
                  grid: PaintStyle(
                    strokeColor: const Color.fromARGB(31, 255, 255, 255),
                    strokeWidth: 2,
                  ),// grid color

                ),
              ],
            ),
    );
  }
}

@Preview(name: 'GraphCard')
Widget graphCardPreview() {
  return GraphCard(
    graphData: const [
      {'type': 'A', 'index': 0, 'value': 10},
      {'type': 'A', 'index': 1, 'value': 14},
      {'type': 'B', 'index': 0, 'value': 7},
      {'type': 'B', 'index': 1, 'value': 18},
      {'type': 'C', 'index': 3, 'value': 0},
      {'type': 'D', 'index': 4, 'value': 0},
      {'type': 'E', 'index': 5, 'value': 0},
      {'type': 'F', 'index': 6, 'value': 0},
    ],
    colorByType: const {
      'A': Colors.blue,
      'B': Colors.orange,
    },
    maxYState: 30,
  );
}
