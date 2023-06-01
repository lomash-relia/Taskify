import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.indigo, width: 2),
  ),
);

void nextScreen(BuildContext context, {required page}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => page,
  ));
}

void nextScreenReplace(BuildContext context, {required page}) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
    builder: (context) => page,
  ));
}

void prevScreen(BuildContext context) {
  Navigator.pop(context);
}

void showSnack(BuildContext context, String text, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: color,
      duration: const Duration(seconds: 7),
    ),
  );
}
