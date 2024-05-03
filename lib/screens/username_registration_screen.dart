import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/home_screen.dart';
import 'package:seegle/models/user_model.dart';
import 'package:seegle/user_provider.dart';
import '../services/auth_service.dart';

class UsernameRegistrationScreen extends StatefulWidget {
  const UsernameRegistrationScreen({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  _UsernameRegistrationScreenState createState() =>
      _UsernameRegistrationScreenState();
}

class _UsernameRegistrationScreenState
    extends State<UsernameRegistrationScreen> {
  final _usernameController = TextEditingController();
  String _errorMessage = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Username")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      setState(() {
                        _isProcessing = true;
                      });
                      await _registerUsername();
                      setState(() {
                        _isProcessing = false;
                      });
                    },
              child: Text(_isProcessing ? 'Processing...' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUsername() async {
    final username = _usernameController.text;
    if (username.isEmpty) {
      setState(() => _errorMessage = "Username cannot be empty");
      return;
    }

    final authService = AuthService();
    bool isAvailable = await authService.isUsernameAvailable(username);
    if (!isAvailable) {
      setState(() => _errorMessage = "Username is already taken");
      return;
    }

    await authService.setUsername(username, widget.user);
    // Provider.of(context)
    Provider.of<UserProvider>(context, listen: false).setUser(widget.user.uid);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    ); // Assuming you navigate to the home screen after this
  }
}
