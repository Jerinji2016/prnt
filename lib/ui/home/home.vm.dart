import 'package:flutter/material.dart';

import '../messages/messages.dart';
import '../setup_printers/setup_printers.dart';

class HomeViewModal extends ChangeNotifier {
  void onMessagesIconTapped(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      );

  void onSetupPrinterTapped(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupPrintersScreen()),
      );
}
