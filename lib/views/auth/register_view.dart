import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthService authService;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController emailController;
  late final TextEditingController nameController;
  late final TextEditingController passwordController;
  bool _isLoading = false;

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailAndPassword(
        fullName: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      )
          .then((value) async {
        if (value == true) {
          //save in shared preference
          await HelperFunctions.saveUserLoggedInStatus(value);
          await HelperFunctions.saveUserNameSF(nameController.text);
          await HelperFunctions.saveUserEmailSF(emailController.text);
          if (mounted) {
            nextScreenReplace(context, page: const HomePage());
          }
        } else {
          setState(() {
            showSnack(context, value, Colors.red);
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
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Form(
          key: _formKey,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Register Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Image.asset(
                        'assets/images/registerTaskify.png',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person)),
                        validator: (value) {
                          return RegExp(r'^[a-z A-Z,.\-]+$').hasMatch(value!)
                              ? null
                              : "Enter Appropriate Name";
                        },
                      ),
                      const SizedBox(
                        height: 10,
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
                          onPressed: register,
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                          onTap: () {
                            prevScreen(context);
                          },
                          child: const Text(
                              'Already Registered? Login To Continue')),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
