import 'package:flutter/material.dart';

class SnakePixel extends StatelessWidget {
  const SnakePixel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.lightGreen,
            border: Border.all(
              color: Colors.black,
              width:2,
            ),
            borderRadius: BorderRadius.circular(4)
        ),
      ),
    );
  }
}
