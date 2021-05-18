import 'dart:async';

import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:functional_listener/functional_listener.dart';
import 'package:get_it/get_it.dart';

class DonationManagerLoggedIn extends DonationManager implements Disposable {
  @override
  late final ValueListenable<bool> loading;

  DonationManagerLoggedIn() {
    upsertDonation = Command.createAsync((donation) async {
      if (donation.id != null) {
        await GetIt.I<NhostService>().updateDonation(donation);
      } else {
        await GetIt.I<NhostService>().addDonation(donation);
      }
      return true;
    }, false);

    deleteDonation = Command.createAsync((donation) async {
      await GetIt.I<NhostService>().deleteDonation(donation);
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }, false);

    upsertUsage = Command.createAsync((usage) async {
      if (usage.id != null) {
        await GetIt.I<NhostService>().updateUsage(usage);
      } else {
        await GetIt.I<NhostService>().addUsage(usage);
      }
      return true;
    }, false);

    deleteUsage = Command.createAsync((usage) async {
      await GetIt.I<NhostService>().deleteUsage(usage);
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }, false);

    loading = upsertDonation!.isExecuting.mergeWith([
      deleteDonation!.isExecuting,
      upsertUsage!.isExecuting,
      deleteUsage!.isExecuting
    ]);
    deleteUsage!.thrownExceptions.listen((error, _) {
      print(error.toString());
    });
  }
  @override
  FutureOr onDispose() {
    stopListeners();
  }
}
