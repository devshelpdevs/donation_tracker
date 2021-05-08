import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:test/test.dart';

main() {
  test('login success', () async {
    final server = NhostService();
    await server.loginUser('mail@devshelpdevs.org', 'staging');
    final fileList = await server.getAvailableFiles();
    fileList.forEach((element) {
      print(element.fileName);
    });
  });
}
