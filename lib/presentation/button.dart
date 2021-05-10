import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const Button({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8, right: 8, bottom: 9),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xff115FA7),
        side: BorderSide(color: const Color(0xff115FA7), width: 3),
        shape: StadiumBorder(),
      ),
    );
  }
}
