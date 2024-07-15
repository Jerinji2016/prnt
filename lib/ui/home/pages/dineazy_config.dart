import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apis/dineazy.impl.dart';
import '../../../helpers/utils.dart';
import '../../../modals/restaurant.dart';
import '../../../modals/user_profile.dart';
import '../../../providers/data_provider.dart';
import '../../login/login.dart';
import '../../login/login.interface.dart';
import '../widgets/login_details.dart';
import '../widgets/printer_service_status_panel.dart';

class DineazyConfigPage extends StatelessWidget implements LoginInterface, LogoutInterface {
  DineazyConfigPage({super.key});

  final ValueNotifier<String?> _loadingMessage = ValueNotifier(null);

  @override
  ValueNotifier<String?> get loadingMessage => _loadingMessage;

  @override
  Future<void> onLogin(BuildContext context, String username, password) async {
    loadingMessage.value = "Authenticating...";

    try {
      DineazyApiService dineazyApiService = DineazyApiService();
      String token = await dineazyApiService.login(username, password);

      loadingMessage.value = "Fetching Profile...";
      DineazyProfile profile = await dineazyApiService.getProfile(token);
      loadingMessage.value = "Fetching Restaurant...";
      Restaurant restaurant = await dineazyApiService.getRestaurant(
        token,
        profile.companyId,
        profile.revenueCenterId,
      );

      if (context.mounted) {
        showToast(context, "✅ Authentication Successful", color: Colors.green);
        Provider.of<DataProvider>(context, listen: false).saveDineazyData(profile, restaurant);
      }
    } catch (e) {
      debugPrint("_LoginState._onLoginTapped: ❌ERROR: $e");
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Builder(
        builder: (context) {
          if (!dataProvider.hasDineazyProfile) {
            return LoginWidget(
              title: "Login to Dineazy",
              impl: this,
            );
          }

          Restaurant? restaurant = dataProvider.restaurant;
          return Column(
            children: [
              const PrinterServiceStatusPanel(),
              const SizedBox(height: 24.0),
              LoginDetails(
                name: restaurant?.name ?? "Undefined",
                description: restaurant?.description,
                impl: this,
              ),
            ],
          );
        },
      ),
    );
  }
}
