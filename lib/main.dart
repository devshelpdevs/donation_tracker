import 'package:donation_tracker/_managers/authentication_manager.dart';
import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/presentation/button.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:donation_tracker/presentation/donations.dart';
import 'package:donation_tracker/presentation/edit_donation_dlg.dart';
import 'package:donation_tracker/presentation/edit_usage_dlg.dart';
import 'package:donation_tracker/presentation/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:layout/layout.dart';
import 'package:routemaster/routemaster.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  Routemaster.setPathUrlStrategy();

  GetIt.I.registerSingleton(NhostService());
  GetIt.I.registerSingleton(AuthenticationManager());
  GetIt.I.registerSingleton(DonationManager());

  runApp(MyApp());
}

final routes = RouteMap(
  routes: {
    '/': (_) => Redirect('/donated'),
    '/:tab': (route) => MaterialPage(
          child: Layout(
              child: MyHomePage(
            activeTab: route.pathParameters['tab'] ?? 'donated',
          )),
        ),
  },
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShiftRightFixer(
      child: MaterialApp.router(
        title: 'Usage overview of DevsHelpDevs',
        theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (BuildContext context) => routes,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  final String activeTab;

  MyHomePage({Key? key, required this.activeTab}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with GetItStateMixin, SingleTickerProviderStateMixin {
  late final TabController controller;
  @override
  void initState() {
    int initialTab = 0;
    switch (widget.activeTab) {
      case 'donated':
        initialTab = 0;
        break;
      case 'used':
        initialTab = 1;
        break;
      case 'waiting':
        initialTab = 2;
        break;
      default:
        initialTab = 1;
    }
    controller =
        TabController(length: 3, vsync: this, initialIndex: initialTab);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rebuildOnScopeChanges();
    final hasWriteAcess = get<NhostService>().hasWriteAccess;

    final isReady = allReady();

    final numDonations =
        watchX((DonationManager m) => m.donationUpdates).length;
    final numUsed = watchX((DonationManager m) => m.usageUpdates).length;
    final numWait = watchX((DonationManager m) => m.waitingUpdates).length;

    final isLoading = watchX((DonationManager m) => m.loading);

    return Scaffold(
      floatingActionButton: hasWriteAcess
          ? FloatingActionButton(
              backgroundColor: const Color(0xff115FA7),
              onPressed: () async {
                switch (controller.index) {
                  case 0:
                    await showAddEditDonationDlg(context);
                    break;
                  case 1:
                    await showAddEditUsageDlg(context, waiting: false);
                    break;
                  case 2:
                    await showAddEditUsageDlg(context, waiting: true);
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
      body: Theme(
        data: Theme.of(context).copyWith(
          tabBarTheme: TabBarTheme.of(context).copyWith(
            labelStyle: TextStyle(
              fontSize: context.layout.value(xs: 14, md: 16),
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: context.layout.value(xs: 12, md: 16),
            ),
          ),
        ),
        child: SafeArea(
          child: isReady
              ? Stack(
                  children: [
                    Container(
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
                                  child: Text(context.layout
                                          .value(
                                              xs: 'Donations',
                                              md: 'Received Donations')
                                          .toUpperCase() +
                                      ' ($numDonations)'),
                                ),
                                Tab(
                                  child: Text(context.layout
                                          .value(xs: 'Used', md: 'Used for')
                                          .toUpperCase() +
                                      ' ($numUsed)'),
                                ),
                                Tab(
                                  child: Text(context.layout
                                          .value(
                                              xs: 'Waiting',
                                              md: 'Waiting for Help')
                                          .toUpperCase() +
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
                                  usageReceived: true,
                                ),
                                DonationUsages(
                                  usageUpdates:
                                      GetIt.I<DonationManager>().waitingUpdates,
                                  usageReceived: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget with GetItMixin {
  _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedIn = get<AuthenticationManager>().isLoggedIn;

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
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onDoubleTap: () async {
                          if (isProduction) {
                            final credentials = await showLoginDialog(
                                context: context,
                                userNamePrefill: 'mail@devshelpdevs.org');
                            if (credentials != null) {
                              get<AuthenticationManager>().loginCommand(
                                LoginCredentials(
                                    credentials.userName, credentials.password),
                              );
                            }
                          } else {
                            get<AuthenticationManager>().loginCommand(
                                LoginCredentials(
                                    'mail@devshelpdevs.org', 'staging'));
                          }
                        },
                        onTap: () async {
                          await launch('https://www.devshelpdevs.org');
                        },
                        child: SvgPicture.asset(
                          'assets/images/devshelpdevs-logo.svg',
                          height: 100,
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        child: Button(
                          onPressed: () async {
                            await launch(
                                'https://paypal.me/pools/c/8xPwkVP3th');
                          },
                          text: 'Donate here',
                        ),
                      ),
                    ),
                    if (context.layout.value(xs: false, lg: true))
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Donation Tracker',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(),
                    if (loggedIn)
                      Flexible(
                        child: FittedBox(
                          child: Button(
                            onPressed: () {
                              get<AuthenticationManager>().logoutCommand();
                            },
                            text: 'Log out',
                          ),
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

class ShiftRightFixer extends StatefulWidget {
  ShiftRightFixer({required this.child});
  final Widget child;
  @override
  State<StatefulWidget> createState() => _ShiftRightFixerState();
}

class _ShiftRightFixerState extends State<ShiftRightFixer> {
  final FocusNode focus =
      FocusNode(skipTraversal: true, canRequestFocus: false);
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focus,
      onKey: (_, RawKeyEvent event) {
        return event.physicalKey == PhysicalKeyboardKey.shiftRight
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
