import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horario/exceptions/firebase_auth_exception_codes.dart';
import 'package:horario/providers/auth_service.dart';
import 'package:provider/provider.dart';
// import '../widgets/sign_in_form.dart';
// import '../widgets/sign_up_form.dart';
import 'package:login_fresh/login_fresh.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final Map<String, String> _authDataSingUp = {
    'name': '',
    'email': '',
    'password': '',
  };
  // bool isSigningIn = false; //bool flag to switch between sign in and sign up

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: buildLoginFresh(),
    );
  }

  //Sign In: show error
  void _showErrorDialog(String title, String message, BuildContext context) {
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

  //Sign In: submit
  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final AuthState res =
          await Provider.of<AuthService>(context, listen: false).emailSignIn(
        email: _authData['email'] ?? "",
        password: _authData['password'] ?? "",
      );

      if (res == AuthState.SignedIn) {
        Navigator.of(context).pop();
      } else {
        _showErrorDialog(
          "Email not verified",
          "We have just sent you a verification email. Please verify your email before continuing",
          context,
        );
      }
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog(
        "Something went wrong",
        errorMessage,
        context,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  //Sign Up: show error
  void _showErrorDialogSignUp(String title, String message) {
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

  //Sign Up: submit
  Future<void> _submitSignUp() async {
    // _formKey.currentState?.save
    setState(() {
      _isLoading = true;
    });
    try {
      final AuthState res =
          await Provider.of<AuthService>(context, listen: false).emailSignUp(
        name: _authData['name'] ?? "",
        email: _authData['email'] ?? "",
        password: _authData['password'] ?? "",
      );
      if (res == AuthState.SignedIn) {
        Navigator.of(context).pop();
      } else {
        _showErrorDialogSignUp("Verify your email",
            "We have just sent you a verification email. Please verify your email before continuing");
      }
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialogSignUp("Something went wrong", errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _emailController = TextEditingController();

  //Forget Password: verification send on email
  Future<void> _recoverPassword() async {
    try {
      // final AuthState res =
      await Provider.of<AuthService>(context, listen: false)
          .forgotPassword(_emailController.text);
      Navigator.of(context).pop();
      _showErrorDialog(
        "Password reset mail sent",
        "We have just sent you a link to reset your password. Please check your spam folder too",
        context,
      );
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog(
        "Something went wrong",
        errorMessage,
        context,
      );
    }
  }

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  LoginFresh buildLoginFresh() {
    List<LoginFreshTypeLoginModel> listLogin = [
      LoginFreshTypeLoginModel(
          callFunction: (BuildContext _buildContext) {
            // develop what they want the facebook to do when the user clicks
          },
          logo: TypeLogo.facebook),
      LoginFreshTypeLoginModel(
          callFunction: (BuildContext _buildContext) {
            // develop what they want the Google to do when the user clicks
          },
          logo: TypeLogo.google),
      LoginFreshTypeLoginModel(
        callFunction: (BuildContext _buildContext) {
          Navigator.of(_buildContext).push(
            MaterialPageRoute(
              builder: (_buildContext) => widgetLoginFreshUserAndPassword(),
            ),
          );
        },
        logo: TypeLogo.userPassword,
      ),
    ];

    return LoginFresh(
      pathLogo: 'assets/images/horario.jpg',
      backgroundColor: Colors.black,
      textColor: Colors.black,
      isExploreApp: false,
      functionExploreApp: () {
        // develop what they want the ExploreApp to do when the user clicks
      },
      isFooter: false,
      widgetFooter: widgetFooter(),
      typeLoginModel: listLogin,
      isSignUp: true,
      widgetSignUp: widgetLoginFreshSignUp(),
    );
  }

  Widget widgetLoginFreshUserAndPassword() {
    return LoginFreshUserAndPassword(
      callLogin: (
        BuildContext _context,
        Function isRequest,
        String user,
        String password,
      ) {
        isRequest(true);

        // ignore: prefer_const_constructors
        Future.delayed(Duration(seconds: 2), () {
          print('-------------- function call----------------');
          print(user);
          _authData['email'] = user;
          _authData['password'] = password;
          // print(password);
          print('--------------   end call   ----------------');
          isRequest(false);

          _submit();
        });
      },
      logo: 'assets/images/horario.jpg',
      backgroundColor: Colors.black,
      isFooter: false,
      widgetFooter: widgetFooter(),
      isResetPassword: true,
      widgetResetPassword: widgetResetPassword(),
      isSignUp: true,
      signUp: widgetLoginFreshSignUp(),
    );
  }

  Widget widgetResetPassword() {
    return LoginFreshResetPassword(
      backgroundColor: Colors.black,
      logo: 'assets/images/horario.jpg',
      funResetPassword:
          (BuildContext _context, Function isRequest, String email) {
        isRequest(true);

        // ignore: prefer_const_constructors
        Future.delayed(Duration(seconds: 2), () {
          // print('-------------- function call----------------');
          // print(email);
          // print('--------------   end call   ----------------');
          _authData[email] = email;
          _recoverPassword();
          isRequest(false);
        });
      },
      isFooter: false,
      widgetFooter: widgetFooter(),
    );
  }

  Widget widgetFooter() {
    return LoginFreshFooter(
      logo: 'assets/images/horario.jpg',
      text: 'Power by',
      funFooterLogin: () {
        // develop what they want the footer to do when the user clicks
      },
    );
  }

  Widget widgetLoginFreshSignUp() {
    return LoginFreshSignUp(
        isFooter: false,
        widgetFooter: widgetFooter(),
        logo: 'assets/images/horario.jpg',
        backgroundColor: Colors.black,
        funSignUp: (
          BuildContext _context,
          Function isRequest,
          SignUpModel signUpModel,
        ) {
          isRequest(true);
          Future.delayed(
            Duration(seconds: 2),
            () {
              // print(signUpModel.email);

              _authDataSingUp["email"] = signUpModel.email;
              _authDataSingUp["name"] = signUpModel.name;
              _authDataSingUp["email"] = signUpModel.password;

              isRequest(false);
              _submitSignUp();
            },
          );
        });
  }
}
