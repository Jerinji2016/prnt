import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';
import '../home/pages/dineazy_config.dart';
import 'login.interface.dart';

class LoginWidget extends StatefulWidget {
  final String title;
  final LoginInterface impl;

  const LoginWidget({
    super.key,
    required this.title,
    required this.impl,
  });

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      if (widget.impl is DineazyConfigPage) {
        _usernameController.text = "mmukesh1917@gmail.com";
        _passwordController.text = "Mukesh@123";
      } else {
        _usernameController.text = "admin@elaachi.com";
        _passwordController.text = "El@ach1369";
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _onLoginTapped() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    return widget.impl.onLogin(context, username, password);
  }

  void _onShowPasswordTapped() => setState(
        () => _hidePassword = !_hidePassword,
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.impl.loadingMessage,
      builder: (context, value, child) {
        if (value != null) {
          child = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return Center(
          child: SingleChildScrollView(child: child!),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Material(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.shortestSide * 0.75,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        hintText: "Username",
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      obscuringCharacter: "*",
                      style: _hidePassword ? const TextStyle(letterSpacing: 2.5) : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        hintText: "Password",
                        suffixIcon: GestureDetector(
                          onTap: _onShowPasswordTapped,
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    PrimaryButton(
                      onTap: _onLoginTapped,
                      text: "Login",
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
