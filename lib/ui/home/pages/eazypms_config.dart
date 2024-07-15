import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apis/eazypms.impl.dart';
import '../../../helpers/utils.dart';
import '../../../modals/profile/eazypms.profile.dart';
import '../../../providers/data_provider.dart';
import '../../login/login.dart';
import '../../login/login.interface.dart';
import '../widgets/login_details.dart';

class EazyPMSConfigPage extends StatelessWidget implements LoginInterface, LogoutInterface {
  EazyPMSConfigPage({super.key});

  final ValueNotifier<String?> _loadingMessage = ValueNotifier(null);

  @override
  ValueNotifier<String?> get loadingMessage => _loadingMessage;

  @override
  Future<void> onLogin(BuildContext context, String username, password) async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    loadingMessage.value = "Authenticating...";

    try {
      EazypmsApiService eazyPMSApiService = EazypmsApiService();
      String token = await eazyPMSApiService.login(username, password);

      loadingMessage.value = "Fetching Profile...";
      EazypmsProfile profile = await eazyPMSApiService.getProfile(token);

      if (context.mounted) {
        showToast(context, "✅ Authentication Successful", color: Colors.green);
        dataProvider.saveEazypmsData(profile);
      }
    } catch (e) {
      debugPrint("EazyPMSConfigPage._onLoginTapped: ❌ERROR: $e");
      if (context.mounted) {
        showToast(context, "❌ ${e.toString()}", color: Theme.of(context).colorScheme.error);
      }
    }

    loadingMessage.value = null;
  }

  @override
  void onLogoutTapped(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.logoutOfEazyPMS();
  }

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Builder(
        builder: (context) {
          if (!dataProvider.hasEazypmsProfile) {
            return LoginWidget(
              title: "Login to eazyPMS",
              impl: this,
            );
          }

          EazypmsProfile eazypmsProfile = dataProvider.eazypmsProfile;
          return Column(
            children: [
              const SizedBox(height: 24.0),
              LoginDetails(
                name: "Undefined",
                description: "Undefined",
                impl: this,
              ),
            ],
          );
        },
      ),
    );
  }
}
