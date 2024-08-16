import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterScreen.dart';
import 'SuccessScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                    errorText: _emailController.text.isNotEmpty &&
                        _emailController.text.contains('@') == false
                        ? 'Enter valid email id'
                        : null,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true || value!.split('@').length != 2) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0), // Add spacing between fields
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                    errorText: _passwordController.text.isNotEmpty &&
                        _passwordController.text.length < 6
                        ? 'Password is too short!'
                        : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true || (value!.length < 6)) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text('Create new account'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
  void _submit() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use')
        {
          _showErrorDialog('The email address is already in use.');
        }
        else if (error.code == 'invalid-credential')
        {
          _showErrorDialog('Invalid email or password.');
        }
        else {
          _showErrorDialog(error.message ?? 'An error occurred');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}