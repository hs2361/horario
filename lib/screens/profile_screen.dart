import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:horario/components/bio_input_field.dart';
import 'package:horario/components/birthday_selector.dart';
import 'package:horario/components/input_field.dart';
import 'package:horario/models/user.dart';
import 'package:horario/providers/user_service.dart';
import 'package:provider/provider.dart';
import '../exceptions/firebase_auth_exception_codes.dart';
import '../providers/auth_service.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';
  final AuthService auth;
  final UserService userService;

  const ProfileScreen(this.auth, this.userService);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FocusNode _bioFocusNode = FocusNode();
  final FocusNode _birthdayFocusNode = FocusNode();
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _bioInputController = TextEditingController();
  final GlobalKey<BirthdaySelectorState> _birthdayKey = GlobalKey();

  bool _isLoading = true;
  bool _hasValidName = true;
  bool _isEditModeEnabled = false;

  late String photoUrl;
  User? user;

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

  Future<void> _showUpdatePasswordDialog() async {
    final String? email = widget.auth.email;
    try {
      await widget.auth.forgotPassword(email ?? "");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Password update email sent"),
            content: const Text("Login using your new password"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              )
            ],
          );
        },
      );
      await Provider.of<AuthService>(context, listen: false).signOut();
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog("Something went wrong", errorMessage);
    } catch (error) {
      Navigator.of(context).pop();
      const errorMessage = 'Could not change password.';
      _showErrorDialog("Something went wrong", errorMessage);
    }
  }

  void _toggleEditingMode() {
    setState(() => _isEditModeEnabled = !_isEditModeEnabled);
  }

  bool _isReadOnly() => !_isEditModeEnabled;

  Future<void> _saveChanges() async {
    if (_nameInputController.text.isEmpty) {
      setState(() => _hasValidName = false);
      return;
    }
    setState(() => _isLoading = true);
    user!.name = _nameInputController.text;
    user!.biography = _bioInputController.text;
    await widget.userService.updateUser(user!);
    await widget.auth.updateName(user!.name!);
    _toggleEditingMode();

    setState(() {
      _isLoading = false;
      _hasValidName = true;
    });
  }

  void _enableEdit() {
    _toggleEditingMode();
  }

  void _updateBirthdayField() {
    _birthdayKey.currentState?.updateBirthday(user!.birthday);
  }

  void _cancelEdit() {
    _toggleEditingMode();
    setState(() {
      user = widget.userService.user;
      _hasValidName = true;
    });

    _bioInputController.text = user!.biography ?? "";
    _nameInputController.text = user!.name!;
    _updateBirthdayField();
  }

  Widget _editSaveButtons() {
    void Function()? onEditButtonPress = _enableEdit;
    String text = "Edit Profile";
    Color primaryColor = Colors.white;
    Color onPrimaryColor = Colors.black;

    final List<Widget> buttons = [];
    if (_isEditModeEnabled) {
      buttons.add(
        TextButton(
          onPressed: _cancelEdit,
          child: const Text("Cancel"),
        ),
      );

      text = "Save Profile";
      primaryColor = Colors.blueAccent;
      onPrimaryColor = Colors.white;
      onEditButtonPress = _saveChanges;
    }

    buttons.add(
      ElevatedButton(
        onPressed: onEditButtonPress,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
          primary: primaryColor,
          onPrimary: onPrimaryColor,
        ),
        child: Text(text),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.userService.loadUser(widget.auth).then((user) {
      _nameInputController.text = user.name!;
      _bioInputController.text = user.biography ?? "";
      setState(() {
        this.user = user;
        _isLoading = false;
      });
      _updateBirthdayField();
    });
  }

  @override
  void didChangeDependencies() {
    setState(() {
      photoUrl = widget.auth.photoUrl ?? "";
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bioFocusNode.dispose();
    _birthdayFocusNode.dispose();
    _bioInputController.dispose();
    _nameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: showAppBar(context),
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoUrl.isEmpty
                          ? const AssetImage(
                              'assets/images/default_pfp.png',
                            ) as ImageProvider
                          : NetworkImage(photoUrl),
                    ),
                    title: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: Theme.of(context).accentColor),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          errorText: _hasValidName ? null : "Enter a name",
                        ),
                        controller: _nameInputController,
                        textInputAction: TextInputAction.done,
                        readOnly: !_isEditModeEnabled,
                        onSubmitted: (name) {
                          if ((name.isEmpty && _hasValidName) ||
                              (name.isNotEmpty && !_hasValidName)) {
                            setState(() => _hasValidName = name.isNotEmpty);
                          }
                        },
                      ),
                    ),
                    subtitle: Text(widget.auth.email!),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: BirthdaySelector(
                      _birthdayFocusNode,
                      user?.birthday,
                      _bioFocusNode,
                      globalKey: _birthdayKey,
                      clickable: !_isReadOnly(),
                      onDateDialogClosed: (birthday) =>
                          user?.birthday = birthday,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: BioInputField(
                      readOnly: _isReadOnly(),
                      controller: _bioInputController,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _editSaveButtons(),
            ),
            const Divider(),
            InkWell(
              onTap: () async {
                setState(() {
                  photoUrl = '';
                });
                await widget.auth.signOut();
              },
              child: const ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                ),
                title: Text('Sign Out'),
              ),
            ),
            InkWell(
              onTap: _showUpdatePasswordDialog,
              child: const ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Change Password'),
              ),
            ),
          ],
        ),
      );
}
