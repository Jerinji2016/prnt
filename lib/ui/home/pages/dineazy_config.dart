import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apis/dineazy.impl.dart';
import '../../../helpers/utils.dart';
import '../../../modals/profile/dineazy.profile.dart';
import '../../../providers/data_provider.dart';
import '../../login/login.dart';
import '../../login/login.interface.dart';
import '../widgets/dineazy_notification_service_panel.dart';
import '../widgets/login_details.dart';

class DineazyConfigPage extends StatelessWidget implements LoginInterface, LogoutInterface {
  DineazyConfigPage({super.key});

  final ValueNotifier<String?> _loadingMessage = ValueNotifier(null);

  @override
  ValueNotifier<String?> get loadingMessage => _loadingMessage;

  @override
  Future<void> onLogin(BuildContext context, String username, password) async {
    loadingMessage.value = "Authenticating...";

    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      DineazyApiService dineazyApiService = DineazyApiService();
      String token = await dineazyApiService.login(username, password);

      loadingMessage.value = "Fetching Profile...";
      DineazyProfile profile = await dineazyApiService.getProfile(token);
      // loadingMessage.value = "Fetching Restaurant...";
      // Restaurant restaurant = await dineazyApiService.getRestaurant(
      //   token,
      //   profile.companyId,
      //   profile.revenueCenterId,
      // );

      if (context.mounted) {
        showToast(context, "✅ Authentication Successful", color: Colors.green);
        dataProvider.saveDineazyData(profile);
      }
    } catch (e) {
      debugPrint("DineazyConfigPage._onLoginTapped: ❌ERROR: $e");
      if (context.mounted) {
        showToast(context, "❌ ${e.toString()}", color: Theme.of(context).colorScheme.error);
      }
    }

    loadingMessage.value = null;
  }

  @override
  void onLogoutTapped(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.logoutOfDineazy();
  }

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    debugPrint("DineazyConfigPage.build: 🐞");

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Builder(
        builder: (context) {
          debugPrint("DineazyConfigPage.build: 🐞");

          if (!dataProvider.hasDineazyProfile) {
            return LoginWidget(
              title: "Login to Dineazy",
              impl: this,
            );
          }

          DineazyRevenueCenter restaurant = dataProvider.dineazyProfile.revenueCenter;
          return Column(
            children: [
              const DineazyNotificationServicePanel(),
              const SizedBox(height: 24.0),
              LoginDetails(
                name: restaurant.name,
                description: restaurant.description,
                impl: this,
              ),
            ],
          );
        },
      ),
    );
  }
}
