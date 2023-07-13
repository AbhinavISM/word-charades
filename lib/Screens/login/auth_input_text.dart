// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class AuthInputText extends StatelessWidget {
  final TextEditingController textEditingController;
  final String labelText;
  final String hintText;
  const AuthInputText({
    Key? key,
    required this.textEditingController,
    required this.labelText,
    required this.hintText,
    required TextInputType textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      // onChanged: (val) {
      //   employeeid = val;
      // },
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.purple,
        ),
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.purple),
      ),
    );
  }
}
