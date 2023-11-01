import 'package:flutter/material.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

Future<List<int>> generateImageBytesFromHtml(String content) async {
  return await WebcontentConverter.contentToImage(
    content: content,
    executablePath: WebViewHelper.executablePath(),
  );
}

void showToast(BuildContext context, String message, {Color? color}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: color ?? Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
