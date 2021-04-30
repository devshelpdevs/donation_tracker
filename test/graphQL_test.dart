import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/nhost_service.dart';
import 'package:graphql/client.dart';
import 'package:test/test.dart';

main() async {
  final server = NhostService();

  test('Insert Donation', () async {
    await server.loginUser('mail@devshelpdevs.org', 'staging');
    final int id = await server.addDonation(Donation(
        amount: 42, date: DateTime.now().toIso8601String(), name: 'TestUser'));
    await server.deleteDonation(id);
  });
  test('Delete Donation not logged in', () async {
    expect(() async => await server.deleteDonation(33),
        throwsA(isA<OperationException>()));
  });
  test('Delete Donation', () async {
    await server.loginUser('mail@devshelpdevs.org', 'staging');
    int id = await server.addDonation(Donation(
        amount: 42, date: DateTime.now().toIso8601String(), name: 'TestUser'));
    await server.deleteDonation(id);
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
