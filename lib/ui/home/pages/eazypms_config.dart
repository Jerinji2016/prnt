import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apis/eazypms.impl.dart';
import '../../../helpers/utils.dart';
import '../../../modals/profile/eazypms.profile.dart';
import '../../../providers/data_provider.dart';
import '../../login/login.dart';
import '../../login/login.interface.dart';
import '../widgets/eazypms_notification_service_panel.dart';
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

    return Builder(
      builder: (context) {
        if (!dataProvider.hasEazypmsProfile) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: LoginWidget(
              title: "Login to eazyPMS",
              impl: this,
            ),
          );
        }

        EazypmsProfile eazypmsProfile = dataProvider.eazypmsProfile;
        return SingleChildScrollView(
          child: Column(
            children: [
              const EazypmsNotificationServicePanel(),
              const SizedBox(height: 12.0),
              LoginDetails(
                name: eazypmsProfile.company.name,
                description: eazypmsProfile.company.description,
                impl: this,
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        );
      },
    );
  }
}
