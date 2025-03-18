import 'package:cinecast_fyp/screens/home_screen.dart';
import 'package:cinecast_fyp/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //firebase
  final _auth = FirebaseAuth.instance;

  //string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        //reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color.fromARGB(255, 2, 22, 52),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );

    final passwordField = TextFormField(
        style: TextStyle(color: Colors.white),
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password (Min. 6 Character)");
          }
          return null;
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ));

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.deepPurple,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
          onPressed: () {
            signIn(emailController.text, passwordController.text);
          },
          child: Text(
            "Log In",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "CineCast",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 34, 2, 60)),
                    ),
                    SizedBox(height: 50),
                    emailField,
                    SizedBox(height: 24),
                    passwordField,
                    SizedBox(height: 34),
                    loginButton,
                    SizedBox(height: 14),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen()));
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
                  Fluttertoast.showToast(msg: "Welcome"),
                  if (mounted)
                    {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      ),
                    }
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address is invalid.";

            break;
          case "wrong-password":
            errorMessage = "Wrong Password.";
            break;
          case "user-not-found":
            errorMessage = "User Not Found.";
            break;
          case "user-disabled":
            errorMessage = "User Disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too Many Requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "Unknown Error.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }
}
