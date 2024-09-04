import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'dart:math';

void main() {
  final style = switch (Platform.environment['FRAME_GRID_STYLE']) {
    'black_to_white' => FrameGridStyle.blackToWhite,
    'white_to_black' => FrameGridStyle.whiteToBlack,
    String value => (() {
        debugPrint('Unknown style: $value');
        return FrameGridStyle.blackToWhite;
      })(),
    _ => FrameGridStyle.blackToWhite,
  };

  runApp(MyApp(
    style: style,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.style = FrameGridStyle.blackToWhite});

  final FrameGridStyle style;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frame-Skip Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: FrameGrid(
          style: style,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter({
    required this.nx,
    required this.ny,
    this.color = const Color.fromRGBO(50, 50, 50, 1),
  });

  final int nx;
  final int ny;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.width / nx;
    final dy = size.height / ny;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    for (var i = 1; i < nx; i++) {
      final x = i * dx;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var i = 1; i < ny; i++) {
      final y = i * dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.nx != nx ||
        oldDelegate.ny != ny ||
        oldDelegate.color != color;
  }
}

class FilledGridPainter extends CustomPainter {
  FilledGridPainter({
    required this.nx,
    required this.ny,
    required this.filled,
    this.color = Colors.white,
  });

  final int nx;
  final int ny;
  final int filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.width / nx;
    final dy = size.height / ny;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < filled; i++) {
      final x = (i % nx) * dx;
      final y = (i ~/ nx) * dy;
      canvas.drawRect(Rect.fromLTWH(x, y, dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant FilledGridPainter oldDelegate) {
    return oldDelegate.nx != nx ||
        oldDelegate.ny != ny ||
        oldDelegate.filled != filled ||
        oldDelegate.color != color;
  }
}

enum FrameGridStyle {
  blackToWhite,
  whiteToBlack,
}

class FrameGrid extends StatefulWidget {
  const FrameGrid({
    super.key,
    this.style = FrameGridStyle.blackToWhite,
  });

  final FrameGridStyle style;

  @override
  State<FrameGrid> createState() => _FrameGridState();
}

class _FrameGridState extends State<FrameGrid> {
  late int _hz;

  @override
  void initState() {
    super.initState();

    _hz = PlatformDispatcher.instance.implicitView!.display.refreshRate.ceil();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        final nx = sqrt(_hz * size.width / size.height).ceil();
        final ny = (_hz / nx).ceil();

        return SizedBox.expand(
          child: ColoredBox(
            color: switch (widget.style) {
              FrameGridStyle.blackToWhite => Colors.black,
              FrameGridStyle.whiteToBlack => Colors.white,
            },
            child: LayedOutFrameGrid(
              nx: nx,
              ny: ny,
              hz: _hz,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

class LayedOutFrameGrid extends StatefulWidget {
  const LayedOutFrameGrid({
    super.key,
    required this.nx,
    required this.ny,
    required this.hz,
    this.style = FrameGridStyle.blackToWhite,
  });

  final int nx;
  final int ny;
  final int hz;
  final FrameGridStyle style;

  @override
  State<LayedOutFrameGrid> createState() => _LayedOutFrameGridState();
}

class _LayedOutFrameGridState extends State<LayedOutFrameGrid>
    with SingleTickerProviderStateMixin {
  var _counter = 0;
  late Ticker _ticker;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      _incrementCounter();
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker
      ..stop()
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: FilledGridPainter(
        nx: widget.nx,
        ny: widget.ny,
        filled: _counter % (widget.nx * widget.ny),
        color: switch (widget.style) {
          FrameGridStyle.blackToWhite => Colors.white,
          FrameGridStyle.whiteToBlack => Colors.black,
        },
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          isComplex: true,
          painter: GridPainter(
            nx: widget.nx,
            ny: widget.ny,
            color: const Color.fromRGBO(50, 50, 50, 1),
          ),
        ),
      ),
    );
  }
}
