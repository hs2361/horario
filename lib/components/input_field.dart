import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final FocusNode? nodeToFocusOnSubmit;
  final TextInputAction textInputAction;
  final bool autoFocus;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final int minLines;
  final TextEditingController? controller;
  final String? initialValue;
  final bool readOnly;

  const InputField(
    this.label, {
    this.initialValue,
    this.hint,
    this.textInputType = TextInputType.text,
    this.focusNode,
    this.nodeToFocusOnSubmit,
    this.textInputAction = TextInputAction.next,
    this.autoFocus = false,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.minLines = 1,
    this.controller,
    this.readOnly = false,
  });

  ThemeData _getInputTheme(BuildContext context) => Theme.of(context)
      .copyWith(primaryColor: Theme.of(context).colorScheme.secondary);

  @override
  Widget build(BuildContext context) => Theme(
        data: _getInputTheme(context),
        child: TextFormField(
          decoration: InputDecoration(labelText: label, hintText: hint),
          autofocus: autoFocus,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          onFieldSubmitted: (value) => nodeToFocusOnSubmit?.requestFocus(),
          validator: validator,
          onSaved: onSaved,
          minLines: minLines,
          maxLines: minLines,
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          obscureText: obscureText,
        ),
      );
}
