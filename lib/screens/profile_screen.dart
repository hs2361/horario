import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../exceptions/firebase_auth_exception_codes.dart';
import '../providers/auth_service.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';
  final AuthService auth;
  ProfileScreen(this.auth);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool isSigningIn = true;
  bool isEditingName = false;
  String userName = 'Guest';
  String photoUrl = '';
  String email = '';
  late User provider;

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
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  Future<void> _showUpdatePasswordDialog() async {
    String? email = widget.auth.email;
    try {
      await widget.auth.forgotPassword(email ?? "");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Password update email sent"),
            content: Text("Login using your new password"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              )
            ],
          );
        },
      );
      await Provider.of<AuthService>(context, listen: false).signOut();
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog("Something went wrong", errorMessage);
    } catch (error) {
      Navigator.of(context).pop();
      const errorMessage = 'Could not change password.';
      _showErrorDialog("Something went wrong", errorMessage);
    }
  }

  @override
  void didChangeDependencies() {
    setState(() {
      photoUrl = widget.auth.photoUrl ?? "";
    });

    String name = widget.auth.userName;
    userName = name;

    setState(() {
      email = widget.auth.email ?? "";
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? Scaffold(
            appBar: showAppBar(context),
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              children: <Widget>[
                ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoUrl.isEmpty
                          ? AssetImage(
                              'assets/images/default_pfp.png',
                            ) as ImageProvider
                          : NetworkImage(photoUrl),
                    ),
                    title: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: Theme.of(context).accentColor),
                      child: TextFormField(
                        autofocus: true,
                        initialValue: userName,
                        validator: (val) {
                          if ((val ?? "").trim().isEmpty) {
                            return "Enter a name";
                          }
                        },
                        textInputAction: TextInputAction.done,
                        readOnly: !isEditingName,
                        onFieldSubmitted: (name) async {
                          await widget.auth.updateName(name);
                          setState(() {
                            isEditingName = false;
                          });
                        },
                      ),
                    ),
                    subtitle: Text(email),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditingName = true;
                        });
                      },
                    )),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      photoUrl = '';
                    });
                    await widget.auth.signOut();
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                    ),
                    title: Text('Sign Out'),
                  ),
                ),
                InkWell(
                  onTap: _showUpdatePasswordDialog,
                  child: ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Change Password'),
                  ),
                ),
              ],
            ))
        : Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          );
  }
}
