import 'dart:async';

import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';

class DonationManager implements ShadowChangeHandlers {
  final ValueListenable<bool> loading = ValueNotifier(false);
  final error = ValueNotifier<String?>(null);
  final totalDonated = ValueNotifier(0);
  final totalUsed = ValueNotifier(0);
  final totalWaiting = ValueNotifier(0);

  final donationUpdates = ValueNotifier(<Donation>[]);
  final usageUpdates = ValueNotifier<List<Usage>>([]);
  final waitingUpdates = ValueNotifier<List<Usage>>([]);

  Command<Donation, bool>? upsertDonation;
  Command<Donation, bool>? deleteDonation;
  Command<Usage, bool>? upsertUsage;
  Command<Usage, bool>? deleteUsage;

  late StreamSubscription donationSubscription;
  late StreamSubscription usageSubscription;
  late StreamSubscription errorSubscription;

  DonationManager() {
    startDatabaseListeners();
  }
  @override
  void onGetShadowed(Object shadowing) {
    stopListeners();
  }

  @override
  void onLeaveShadow(Object shadowing) {
    startDatabaseListeners();
  }

  void startDatabaseListeners() {
    final nhostService = GetIt.I<NhostService>();

    donationSubscription = nhostService.donationTableUpdates.listen((list) {
      totalDonated.value = list.fold<int>(
          0, (previousValue, element) => previousValue + element.amount);

      donationUpdates.value = list;
    });

    usageSubscription = nhostService.usageTableUpdates.listen((list) {
      /// We are using the same table for already used donations and for causes waiting
      final used = list.where((x) => !x.isWaitingCause);
      final waiting = list.where((x) => x.isWaitingCause);

      totalUsed.value = used.fold<int>(
          0, (previousValue, element) => previousValue + element.amount);
      totalWaiting.value = waiting.fold<int>(
          0, (previousValue, element) => previousValue + element.amount);

      usageUpdates.value = used.toList();
      waitingUpdates.value = waiting.toList();
    });

    errorSubscription = nhostService.errorUpdates.listen((event) {
      /// This might be a bit brutal in case there is an error but I don't expect many to happen :-)
      error.value = event.toString();
    });
  }

  Future<void> stopListeners() async {
    await donationSubscription.cancel();
    await usageSubscription.cancel();
    await errorSubscription.cancel();
  }
}
