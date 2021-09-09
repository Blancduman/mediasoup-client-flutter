import 'package:flutter/material.dart';

class Dragger extends StatefulWidget {
  final Widget child;
  final Widget child2;

  const Dragger({Key? key, required this.child, required this.child2}) : super(key: key);

  @override
  _Dragger createState() => _Dragger();
}

class _Dragger extends State<Dragger> {
  Offset position = Offset(10, 100);

  void setOffset(DragUpdateDetails details) => setState(() { position = details.globalPosition + Offset(-90, -90); });

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: widget.child,
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanUpdate: setOffset,
              child: widget.child2,
            ),
          )
        ],
      ),
    );
  }
}

// Draggable(
// feedback: widget.child2,
// // onDragEnd: (details) => setState(() => position = details.offset),
// onDragUpdate: setOffset,
// childWhenDragging: Opacity(
// opacity: 0,
// child: widget.child2,
// ),
// child: widget.child2,
// ),