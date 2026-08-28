import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String?)? onChangedCallback;
  const TextInputWidget(
      {super.key,
      required this.controller,
      required this.label,
      this.onChangedCallback});

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: const Color.fromARGB(255, 244, 244, 244),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
      onChanged: widget.onChangedCallback,
    );
  }
}
