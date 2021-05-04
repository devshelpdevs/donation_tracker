import 'dart:async';

import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';

class DonationManagerLoggedIn extends DonationManager implements Disposable {
  DonationManagerLoggedIn() {
    startDatabaseListeners();

    upsertDonation = Command.createAsync((donation) async {
      if (donation!.id != null) {
        await GetIt.I<NhostService>().updateDonation(donation);
      } else {
        await GetIt.I<NhostService>().addDonation(donation);
      }
      return true;
    }, false);

    deleteDonation = Command.createAsync((donation) async {
      await GetIt.I<NhostService>().deleteDonation(donation!);
      return true;
    }, false);

    upsertUsage = Command.createAsync((usage) async {
      if (usage!.id != null) {
        await GetIt.I<NhostService>().updateUsage(usage);
      } else {
        await GetIt.I<NhostService>().addUsage(usage);
      }
      return true;
    }, false);

    deleteUsage = Command.createAsync((usage) async {
      await GetIt.I<NhostService>().deleteUsage(usage!);
      return true;
    }, false);
  }
  @override
  FutureOr ondDispose() {
    stopListeners();
  }
}
