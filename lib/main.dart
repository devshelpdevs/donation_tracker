import 'package:donation_tracker/_managers/authentication_manager.dart';
import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:donation_tracker/presentation/donations.dart';
import 'package:donation_tracker/presentation/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  GetIt.I.registerSingleton(NhostService());
  GetIt.I.registerSingleton(AuthenticationManager());
  GetIt.I.registerSingleton(DonationManager());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usage overview of DevsHelpDevs\'donations',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with GetItStateMixin, SingleTickerProviderStateMixin {
  late final controller =
      TabController(initialIndex: 0, length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    rebuildOnScopeChanges();

    final isReady = allReady();

    final numDonations =
        watchX((DonationManager m) => m.donationUpdates).length;
    final numUsed = watchX((DonationManager m) => m.usageUpdates).length;
    final numWait = watchX((DonationManager m) => m.waitingUpdates).length;

    return Scaffold(
      floatingActionButton: controller.index != 2
          ? FloatingActionButton(
              backgroundColor: const Color(0xff115FA7),
              onPressed: () async {
                switch (controller.index) {
                  case 0:
                    await showAddEditDonationDlg(context);
                    break;
                  case 0:
                    await showAddEditUsageDlg(context);
                    break;
                  default:
                    assert(false, 'We should never get here');
                }
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ))
          : null,
      body: SafeArea(
        child: isReady
            ? Container(
                color: backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    SizedBox(
                      height: 8,
                    ),
                    TabBar(
                        onTap: (index) => setState(() {}),
                        tabs: [
                          Tab(
                            child: Text('Received Donations'.toUpperCase() +
                                ' ($numDonations)'),
                          ),
                          Tab(
                            child:
                                Text('Used for'.toUpperCase() + ' ($numUsed)'),
                          ),
                          Tab(
                            child: Text('Waiting for Help'.toUpperCase() +
                                ' ($numWait)'),
                          )
                        ],
                        controller: controller),
                    Expanded(
                      child: TabBarView(
                        controller: controller,
                        children: [
                          Donations(),
                          DonationUsages(
                            usageUpdates:
                                GetIt.I<DonationManager>().usageUpdates,
                            hasUsageDates: true,
                          ),
                          DonationUsages(
                            usageUpdates:
                                GetIt.I<DonationManager>().waitingUpdates,
                            hasUsageDates: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _Header extends StatelessWidget with GetItMixin {
  _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedIn = get<AuthenticationManager>().isLoggedIn;
    print(loggedIn ? 'Logged in' : 'logged out');

    final totalDonated = watchX((DonationManager m) => m.totalDonated);
    final totalUsed = watchX((DonationManager m) => m.totalUsed);
    final totalWaiting = watchX((DonationManager m) => m.totalWaiting);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onDoubleTap: () {
                        get<AuthenticationManager>().loginCommand(
                            LoginCredentials(
                                'mail@devshelpdevs.org', 'staging'));
                      },
                      onTap: () async {
                        await launch('https://www.devshelpdevs.org');
                      },
                      child: SvgPicture.asset(
                        'assets/images/devshelpdevs-logo.svg',
                        height: 100,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await launch('https://paypal.me/pools/c/8xPwkVP3th');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 8, right: 8, bottom: 9),
                        child: Text(
                          'Donate here',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xff115FA7),
                        side: BorderSide(
                            color: const Color(0xff115FA7), width: 3),
                        shape: StadiumBorder(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Donation Tracker',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    SizedBox(),
                    if (loggedIn)
                      TextButton(
                        onPressed: () {
                          get<AuthenticationManager>().logoutCommand();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, right: 8, bottom: 9),
                          child: Text(
                            'Log out',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xff115FA7),
                          side: BorderSide(
                              color: const Color(0xff115FA7), width: 3),
                          shape: StadiumBorder(),
                        ),
                      ),
                  ],
                ),
              ),
              _TotalLine(
                value: totalDonated,
                valueName: 'donated',
              ),
              _TotalLine(
                value: totalUsed,
                valueName: 'used',
              ),
              _TotalLine(
                value: totalWaiting,
                valueName: 'waiting',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    Key? key,
    required this.value,
    required this.valueName,
  }) : super(key: key);

  final int value;
  final valueName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 100, child: Text('Total $valueName:')),
          SizedBox(
            width: 100,
            child: Text(
              '${value.toCurrency()}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
