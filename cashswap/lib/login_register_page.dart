import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginRegisterPage extends StatefulWidget {
  final void Function(bool isLoggedIn) onLogin;

  const LoginRegisterPage({super.key, required this.onLogin});

  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedCountryCode = '+1';

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (_isLogin) {
      // Perform login request
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username,
            'password': password,
          }),
        );

        final responseBody = response.body;
        if (response.statusCode == 200) {
          // Notify parent that the user is logged in
          widget.onLogin(true);

          // Handle successful login
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Successful'),
                content: Text('You are now logged in.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Optionally, navigate to another page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Attempt to parse the response as JSON
          String errorMessage = 'Login failed';
          try {
            final responseData = jsonDecode(responseBody);
            errorMessage = responseData['message'] ?? errorMessage;
          } catch (e) {
            // If JSON parsing fails, use the raw response body
            errorMessage = responseBody;
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Failed'),
                content: Text(errorMessage.contains('email not verified')
                    ? 'Your email is not verified. Please check your email for verification instructions.'
                    : errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print('Error logging in: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      final email = _emailController.text;
      final phone = '$_selectedCountryCode${_phoneController.text}';
      final confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        // Show error message
        print('Passwords do not match!');
        return;
      }

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      try {
        // Perform registration request
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/register'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username,
            'password': password,
            'email': email,
            'phoneNumber': phone,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userId = responseData['id'];

          // Inform user to check their email
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Successful'),
                content: Text('Please check your email to verify your account.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Optionally, navigate to the login page or any other page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Failed to register user: ${response.body}');
        }
      } catch (error) {
        print('Error registering user: $error');
      } finally {
        // Hide loading indicator
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (!_isLogin) ...[
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCountryCode,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountryCode = newValue!;
                    });
                  },
                  items: <String>['+1', '+44', '+91', '+84']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isLogin ? 'Login' : 'Register'),
                ),
          TextButton(
            onPressed: _toggleForm,
            child: Text(_isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}
