import 'package:donation_tracker/_managers/authentication_manager.dart';
import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:donation_tracker/presentation/edit_usage_dlg.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:layout/layout.dart';

import 'dialogs.dart';

class DonationUsages extends StatelessWidget with GetItMixin {
  final ValueNotifier<List<Usage>> usageUpdates;
  final bool usageReceived;

  DonationUsages(
      {Key? key, required this.usageUpdates, required this.usageReceived})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final loggedIn = get<AuthenticationManager>().isLoggedIn;
    final usages =
        watch<ValueListenable<List<Usage>>, List<Usage>>(target: usageUpdates);

    return Padding(
      padding: context.layout.value(
        xs: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        md: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (context.layout.value(xs: false, md: true))
          DefaultTextStyle.merge(
            style: tableHeaderStyle,
            child: Row(
              children: [
                if (usageReceived) Expanded(child: Text('Date')),
                Expanded(child: Text('Amount')),
                Expanded(child: Text('Usage')),
                Spacer(),
                Expanded(child: Text('Receiver')),
                if (loggedIn) Expanded(child: Text('Hidden Name')),
                Spacer(),
                Spacer(),
                if (loggedIn) Spacer()
              ],
            ),
          ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView(
              children: usages.map(
            (data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: context.layout.value(xs: false, sm: true)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (usageReceived)
                            Expanded(
                                child: Text(data.date?.toDateTime().format() ??
                                    'missing')),
                          Expanded(
                              child: Text(
                            data.amount.toCurrency(),
                            textAlign: TextAlign.justify,
                          )),
                          Expanded(child: Text(data.whatFor)),
                          Spacer(),
                          Expanded(
                            child: Text(data.name ?? 'anonymous'),
                          ),
                          if (loggedIn)
                            Expanded(
                              child: Text(data.hiddenName ?? 'anonymous'),
                            ),
                          Expanded(
                            child: _EnlargableImage(
                              imageLink: data.imageLink,
                            ),
                          ),
                          Expanded(
                            child: _EnlargableImage(
                              imageLink: data.imageReceiverLink,
                            ),
                          ),
                          if (loggedIn)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await showAddEditUsageDlg(context,
                                          usage: data, waiting: !usageReceived);
                                    },
                                    icon: Icon(Icons.edit)),
                                IconButton(
                                  onPressed: () async {
                                    final shouldDelete = await showQueryDialog(
                                        context,
                                        'Warning!',
                                        'Do you really want to delete this entry?');
                                    if (shouldDelete) {
                                      get<DonationManager>().deleteUsage!(data);
                                    }
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                        ],
                      )
                    : Card(
                        color: Colors.blue.shade900,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (usageReceived)
                                    Text(data.date?.toDateTime().format() ??
                                        'missing'),
                                  Text(
                                    data.amount.toCurrency(),
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(data.whatFor),
                              SizedBox(height: 16),
                              Text(data.name ?? 'anonymous'),
                              SizedBox(height: 8),
                              if (loggedIn)
                                Text(data.hiddenName ?? 'anonymous'),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _EnlargableImage(
                                    imageLink: data.imageLink,
                                  ),
                                  _EnlargableImage(
                                    imageLink: data.imageReceiverLink,
                                  ),
                                ],
                              ),
                              if (loggedIn)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await showAddEditUsageDlg(context,
                                              usage: data,
                                              waiting: !usageReceived);
                                        },
                                        icon: Icon(Icons.edit)),
                                    IconButton(
                                      onPressed: () async {
                                        final shouldDelete = await showQueryDialog(
                                            context,
                                            'Warning!',
                                            'Do you really want to delete this entry?');
                                        if (shouldDelete) {
                                          get<DonationManager>()
                                              .deleteUsage!(data);
                                        }
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
              );
            },
          ).toList()),
        )
      ]),
    );
  }
}

class _EnlargableImage extends StatelessWidget {
  final String? imageLink;
  const _EnlargableImage({
    Key? key,
    this.imageLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
        child: imageLink == null
            ? Container()
            : Image.network(
                imageLink!,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                fit: BoxFit.contain,
              ),
      ),
      onTap: imageLink != null
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Image.network(
                      imageLink!,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      fit: BoxFit.contain,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      )
                    ],
                  );
                },
              );
            }
          : null,
    );
  }
}
