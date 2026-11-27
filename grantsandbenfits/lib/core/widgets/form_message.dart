import 'package:flutter/material.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';

class FormMessage extends StatelessWidget {
  const FormMessage({required this.message, required this.isError, super.key});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.danger : AppColors.forestDark;
    final background = isError ? AppColors.dangerSurface : AppColors.successSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: color, height: 1.35)),
    );
  }
}

/// Hidden field. Automated clients that fill every input fail the request.
class HoneypotField extends StatelessWidget {
  const HoneypotField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Offstage(
        child: TextField(
          controller: controller,
          enableSuggestions: false,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Website'),
        ),
      ),
    );
  }
}
