import 'package:flutter/material.dart';

class Mytextfields extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? icon;

  const Mytextfields({
    super.key,
    required this.label,
    this.controller,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
        prefixIconColor: Colors.black,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
