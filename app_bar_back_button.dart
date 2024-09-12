import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Platform.isAndroid
          ? Icons.arrow_back_sharp
          : Icons.arrow_back_ios_new),
      onPressed: onPressed,
    );
  }
}
