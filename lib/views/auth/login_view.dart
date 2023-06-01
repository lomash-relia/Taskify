import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/views/auth/register_view.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/views/home_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final GlobalKey<FormState> _formKey;

  late final AuthService authService;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _isLoading = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final email = emailController.text;
      final password = passwordController.text;
      await authService
          .logInWithUsernameAndPassword(
        email: email,
        password: password,
      )
          .then((value) async {
        if (value == true) {
          final user = FirebaseAuth.instance.currentUser;
          final snapshot = await DatabaseService(uid: user!.uid)
              .gettingUserData(user.email!);

          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          if (mounted) {
            nextScreenReplace(context, page: const HomePage());
          }
        } else {
          showSnack(context, value, Colors.red);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    authService = AuthService();
    _formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Taskify',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      const Text(
                        'Login to access chats',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        'assets/images/taskify.png',
                        scale: 10,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_rounded)),
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Enter Valid Email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_rounded)),
                        // validator: (value) {
                        //   return RegExp(
                        //               r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*?[!@#$&*~]).{8,}$')
                        //           .hasMatch(value!)
                        //       ? null
                        //       : "Enter Valid Password";
                        // },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: login,
                          child: const Text('Log In'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                          onTap: () {
                            nextScreen(context, page: const RegisterView());
                          },
                          child: const Text(
                              'Don\'t have an account? Register Here')),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
