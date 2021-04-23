import 'package:donation_tracker/donation_manager.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DonationUsages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Subscription(
    //   builder: (QueryResult result) {
    //     if (result.hasException) {
    //       return Text(result.exception.toString());
    //     }

    //     if (result.isLoading) {
    //       return Center(
    //         child: const CircularProgressIndicator(),
    //       );
    //     }

    // final data = useMemoized<TotalData<Usage>>(() {
    //   var total = 0;
    //   final List<Usage> data = result.data![tableUsages]
    //       .map((element) {
    //         final donator = Usage.fromMap(element);
    //         total += donator.amount;
    //         return donator;
    //       })
    //       .cast<Usage>()
    //       .toList();
    //   return TotalData(data, total);
    // }, [result.timestamp]);
    final total = 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        child: Text('Total on current date: ${total.toCurrency()}',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center),
      ),
      Divider(),
      Row(
        children: const [
          Expanded(child: Text('Date')),
          Expanded(child: Text('Amount')),
          Expanded(child: Text('For')),
          Expanded(child: Text('Image')),
        ],
      ),
      ValueListenableBuilder<List<Usage>>(
          valueListenable: GetIt.I<DonationManager>().usageUpdates,
          builder: (context, usages, child) {
            return Expanded(
              child: ListView(
                  children: usages.map(
                (data) {
                  return Row(
                    children: [
                      Expanded(
                          child: Text(
                              data.date?.toDateTime().format() ?? 'missing')),
                      Expanded(child: Text(data.amount.toCurrency())),
                      Expanded(child: Text(data.whatFor)),
                      Expanded(
                        child: InkWell(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 100, maxHeight: 60),
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
                  );
                },
              ).toList()),
            );
          })
    ]);
  }
}
