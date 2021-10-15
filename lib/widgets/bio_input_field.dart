import 'package:flutter/material.dart';
import 'package:horario/widgets/input_field.dart';

class BioInputField extends StatelessWidget {
  final String label;
  final String hint;
  final int totalLines;
  final bool readOnly;
  final TextEditingController? controller;
  final Function(String?)? onSaved;

  const BioInputField(
      {this.label = "Bio",
      this.hint = "Tell us a bit about yourself",
      this.totalLines = 3,
      this.readOnly = false,
      this.onSaved,
      this.controller});

  @override
  Widget build(BuildContext context) => InputField(
        label,
        textInputType: TextInputType.multiline,
        hint: hint,
        minLines: totalLines,
        controller: controller,
        onSaved: onSaved,
        readOnly: readOnly,
      );
}
