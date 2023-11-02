import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_manager.dart';
import '../helpers/utils.dart';
import '../modals/user_profile.dart';
import '../providers/data_provider.dart';
import '../widgets.dart';
import 'pub_sub.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  String? _loadingMessage;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      _usernameController.text = "mmukesh1917@gmail.com";
      _passwordController.text = "Mukesh@123";
    }
  }

  @override
  void dispose() {
    super.dispose();

    _usernameController.dispose();
    _passwordController.dispose();
  }

  void _onLoginTapped() async {
    setState(() => _loadingMessage = "Authenticating...");

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      ApiManager apiManager = ApiManager();
      String token = await apiManager.login(username, password);

      setState(() => _loadingMessage = "Fetching Profile...");

      UserProfile profile = await apiManager.getProfile(token);
      if (mounted) {
        DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.setProfile(profile);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PubSubScreen()),
        );
      }
    } catch (e) {
      debugPrint("_LoginState._onLoginTapped: ❌ERROR: $e");
      if (mounted) {
        showToast(context, e.toString());
      }
    }

    setState(() => _loadingMessage = null);
  }

  void _onShowPasswordTapped() => setState(
        () => _hidePassword = !_hidePassword,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      body: Center(
        child: Builder(builder: (context) {
          if (_loadingMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16.0),
                  Text(
                    _loadingMessage!,
                    style: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    "Please Login to continue",
                    style: TextStyle(
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
                        const SizedBox(height: 4.0),
                        PrimaryTextButton(
                          text: "Go Back",
                          onTap: () => Navigator.pop(context),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
