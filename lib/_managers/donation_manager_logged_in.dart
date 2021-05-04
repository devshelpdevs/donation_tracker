import 'dart:async';

import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:get_it/get_it.dart';

class DonationManagerLoggedIn extends DonationManager implements Disposable {
  DonationManagerLoggedIn() {
    startDatabaseListeners();
  }
  @override
  FutureOr ondDispose() {
    stopListeners();
  }
}
