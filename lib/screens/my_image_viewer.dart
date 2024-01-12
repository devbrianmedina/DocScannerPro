import 'dart:io';

import 'package:flutter/material.dart';

class MyImageViewer extends StatefulWidget {
  final File imageFile;

  MyImageViewer({required this.imageFile});

  @override
  _MyImageViewerState createState() => _MyImageViewerState();
}

class _MyImageViewerState extends State<MyImageViewer> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset(0.0, 0.0);
  Offset _previousOffset = Offset(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
          _previousOffset = details.focalPoint;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
            // Calculate translation based on the change in focal point
            _position += details.focalPoint - _previousOffset;

            // Obtain image dimensions
            double imageWidth = context.size!.width;
            double imageHeight = context.size!.height;

            // Apply constraints to prevent panning outside the image bounds
            double maxX = imageWidth / 2 * (_scale - 1);
            double maxY = imageHeight / 2 * (_scale - 1);

            _position = Offset(
              _position.dx.clamp(-maxX, maxX),
              _position.dy.clamp(-maxY, maxY),
            );

            _previousOffset = details.focalPoint;
          });
        },
        onDoubleTap: () {
          setState(() {
            if (_scale == 1.0) {
              _scale = 2.0;
            } else if (_scale == 2.0) {
              _scale = 4.0;
            } else {
              _scale = 1.0;
              _position = const Offset(0.0, 0.0);
            }
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          // Limit the maximum and minimum scale
          _scale = _scale.clamp(1.0, 5.0);
        },
        child: Center(
          child: Transform.scale(
            scale: _scale,
            child: Transform.translate(
              offset: _position,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _scale = 1.0;
            _position = const Offset(0.0, 0.0);
          });
        },
        tooltip: "Restablecer imagen",
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
