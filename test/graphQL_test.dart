import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/nhost_service.dart';
import 'package:test/test.dart';

main() async {
  final server = NhostService();

  test('Insert Donation', () async {
    final result = await server.loginUser('mail@devshelpdevs.org', 'staging');
    await server.addDonation(Donation(
        amount: 42, date: DateTime.now().toIso8601String(), name: 'TestUser'));
  });
  test('login success', () async {
    final result = await server.loginUser('mail@devshelpdevs.org', 'staging');
    expect(result, true);
  });
  test('login fails', () async {
    final result = await server.loginUser('mail@devshelpdevs.org', 'wrong');
    expect(result, false);
  });
}
