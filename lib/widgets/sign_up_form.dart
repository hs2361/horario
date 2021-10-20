import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:horario/models/auth_user.dart';
import 'package:horario/widgets/birthday_selector.dart';
import 'package:horario/widgets/input_field.dart';
import 'package:provider/provider.dart';

import '../exceptions/firebase_auth_exception_codes.dart';
import '../providers/auth_service.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final twoHoundredYearsBack = const Duration(days: 365 * 200);
  final Color _accentColor = Colors.blueAccent;
  final AuthUser _user = AuthUser();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _bioFocusNode = FocusNode();
  final _birthdayFocusNode = FocusNode();

  var _isLoading = false;

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  Widget _getNameInputField() => InputField(
        "Name",
        nodeToFocusOnSubmit: _emailFocusNode,
        autoFocus: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a name';
          }
        },
        onSaved: (value) => _user.name = value,
      );

  Widget _getEmailInputField() => InputField(
        "E-Mail",
        textInputType: TextInputType.emailAddress,
        focusNode: _emailFocusNode,
        nodeToFocusOnSubmit: _passwordFocusNode,
        validator: (value) {
          if (value == null || value.isEmpty || !value.contains('@')) {
            return 'Invalid email!';
          }
        },
        onSaved: (value) => _user.email = value,
      );

  Widget _getPasswordInputField() => InputField(
        "Password",
        obscureText: true,
        focusNode: _passwordFocusNode,
        nodeToFocusOnSubmit: _confirmPasswordFocusNode,
        validator: (value) {
          if (value != null && value.length < 5) {
            return 'Password is too short!';
          }
        },
        controller: _passwordController,
        onSaved: (value) => _user.password = value,
      );

  Widget _getConfirmPasswordInputField() => InputField(
        "Confirm Password",
        obscureText: true,
        focusNode: _confirmPasswordFocusNode,
        nodeToFocusOnSubmit: _birthdayFocusNode,
        validator: (value) {
          if (value != _passwordController.text) {
            return 'Passwords do not match!';
          }
        },
      );

  Widget _getBioInputField() => InputField(
        "Biography",
        textInputType: TextInputType.multiline,
        hint: "Tell us a bit about yourself",
        focusNode: _bioFocusNode,
        nodeToFocusOnSubmit: _birthdayFocusNode,
        minLines: 3,
        onSaved: (value) => _user.biography = value,
      );

  void _onBirthdayDialogClosed(DateTime? birthDay) {
    if (birthDay == null || birthDay == _user.birthday) {
      return;
    }
    setState(() {
      _user.birthday = birthDay;
      _bioFocusNode.requestFocus();
    });
  }

  Container _getOptionalFields() => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        foregroundDecoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(4)),
        alignment: AlignmentDirectional.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Optional",
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
              ),
            ),
            BirthdaySelector(
              _birthdayFocusNode,
              _user.birthday,
              _bioFocusNode,
              onDateDialogClosed: _onBirthdayDialogClosed,
            ),
            _getBioInputField(),
          ],
        ),
      );

  Widget _getSignUpButton() => _isLoading
      ? const CircularProgressIndicator()
      : ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
            primary: Colors.white,
            onPrimary: Colors.black,
          ),
          child: const Text('SIGN UP'),
        );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthService>(context, listen: false).emailSignUp(_user);
      _showErrorDialog(
          "Verify your email", "Please verify your email before signing in");
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog("Something went wrong", errorMessage);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _bioFocusNode.dispose();
    _birthdayFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      height: 360,
      width: deviceSize.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getNameInputField(),
                    _getEmailInputField(),
                    _getPasswordInputField(),
                    _getConfirmPasswordInputField(),
                    _getOptionalFields(),
                  ],
                ),
              ),
            ),
            _getSignUpButton(),
          ],
        ),
      ),
    );
  }
}
