import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthdaySelector extends StatefulWidget {
  final FocusNode focusNode;
  final DateTime? birthday;
  final FocusNode? nodeToFocusNext;
  final bool clickable;
  final void Function(DateTime?)? onDateDialogClosed;
  final GlobalKey<BirthdaySelectorState>? globalKey;

  const BirthdaySelector(
    this.focusNode,
    this.birthday,
    this.nodeToFocusNext, {
    this.globalKey,
    this.clickable = true,
    this.onDateDialogClosed,
  }) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => BirthdaySelectorState();
}

class BirthdaySelectorState extends State<BirthdaySelector> {
  final Color _accentColor = Colors.blueAccent;
  final _startDate = DateTime.now().subtract(const Duration(days: 365 * 200));
  final String _noBirthdayText = 'Select';
  final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
  final String _labelText = 'Birthday';

  late DateTime? dateTime = widget.birthday;

  Future<void> _showBirthdayPicker() async {
    final DateTime? birthDay = await showDatePicker(
      helpText: 'SELECT BIRTHDAY',
      context: context,
      initialDate: widget.birthday ?? DateTime.now(),
      firstDate: _startDate,
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            onPrimary: Colors.white,
            primary: _accentColor,
          ),
          dialogBackgroundColor: Theme.of(ctx).primaryColor,
        ),
        child: child ?? const CircularProgressIndicator(),
      ),
    );
    if (widget.onDateDialogClosed != null) {
      widget.onDateDialogClosed!(birthDay);
    }
    widget.nodeToFocusNext?.requestFocus();
    setState(() => dateTime = birthDay);
  }

  Widget _dateButton() {
    final Text text = Text(
      dateTime == null ? _noBirthdayText : dateFormat.format(dateTime!),
    );
    return widget.clickable
        ? ElevatedButton(onPressed: _onPressed, child: text)
        : OutlinedButton(onPressed: _onPressed, child: text);
  }

  void _onPressed() {
    if (widget.clickable) {
      _showBirthdayPicker();
    }
  }

  void updateBirthday(DateTime? birthday) {
    setState(() => dateTime = birthday);
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _labelText,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          _dateButton()
        ],
      );
}
