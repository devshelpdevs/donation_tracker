import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class DonationUsages extends StatelessWidget with GetItMixin {
  final ValueNotifier<List<Usage>> usageUpdates;
  final bool hasUsageDates;

  DonationUsages(
      {Key? key, required this.usageUpdates, required this.hasUsageDates})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final usages =
        watch<ValueListenable<List<Usage>>, List<Usage>>(target: usageUpdates);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        DefaultTextStyle.merge(
          style: tableHeaderStyle,
          child: Row(
            children: [
              if (hasUsageDates) Expanded(child: Text('Date')),
              Expanded(child: Text('Amount')),
              Expanded(child: Text('Usage')),
              Spacer(),
              Expanded(child: Text('Receiver')),
              Spacer(),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasUsageDates)
                      Expanded(
                          child: Text(
                              data.date?.toDateTime().format() ?? 'missing')),
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
                    Expanded(
                      child: InkWell(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 100, maxHeight: 100),
                          child: data.imageLink == null
                              ? Container()
                              : Image.network(
                                  data.imageLink!,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  fit: BoxFit.contain,
                                ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Image.network(
                                  data.imageLink!,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
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
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList()),
        )
      ]),
    );
  }
}
