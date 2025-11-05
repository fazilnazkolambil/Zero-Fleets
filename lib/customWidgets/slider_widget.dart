import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideToConfirm extends StatefulWidget {
  final String label;
  final Future<bool> Function() onConfirmed; // returns true/false
  final double height;
  final double width;
  final Color backgroundColor;
  final Color sliderColor;

  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.height = 65,
    this.width = 280,
    this.backgroundColor = const Color(0xFF1C1C1E),
    this.sliderColor = Colors.white,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _position = 0.0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final double _maxPosition = widget.width - widget.height;

    return Center(
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: _confirmed ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.label,
                  style:
                      Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ),
            ),
            Positioned(
              left: _position,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _position += details.delta.dx;
                    _position = _position.clamp(0, _maxPosition);
                  });
                },
                onHorizontalDragEnd: (_) async {
                  if (_position > _maxPosition * 0.9) {
                    setState(() => _confirmed = true);
                    bool success = await widget.onConfirmed();
                    if (!success) {
                      // reset if validation fails
                      setState(() {
                        _confirmed = false;
                        _position = 0;
                      });
                    }
                  } else {
                    setState(() {
                      _position = 0;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.height - 10,
                    height: widget.height - 10,
                    decoration: BoxDecoration(
                      color: widget.sliderColor,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
