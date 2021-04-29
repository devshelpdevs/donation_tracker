import 'package:flutter/material.dart';

class UserPictureWhenHasDate extends StatelessWidget {
  final data;
  final hasDate;
  const UserPictureWhenHasDate({
    Key? key,
    this.data,
    this.hasDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      const SizedBox(height: 4),
      Expanded(
        child: InkWell(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
            child: data.imageLink == null
                ? Container()
                : Padding(
                    padding: hasDate == true
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(8.0),
                    child: Image.network(
                      data.imageLink!,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress
                                        // ignore: lines_longer_than_80_chars
                                        .expectedTotalBytes !=
                                    null
                                ? loadingProgress
                                        // ignore: lines_longer_than_80_chars
                                        .cumulativeBytesLoaded /
                                    loadingProgress
                                        // ignore: lines_longer_than_80_chars
                                        .expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Image.network(
                    data.imageLink!,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress
                                      // ignore: lines_longer_than_80_chars
                                      .expectedTotalBytes !=
                                  null
                              ? loadingProgress
                                      // ignore: lines_longer_than_80_chars
                                      .cumulativeBytesLoaded /
                                  loadingProgress
                                      // ignore: lines_longer_than_80_chars
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
                      child: const Text('Close'),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
      if (!hasDate) const SizedBox(width: 4),
      const SizedBox(height: 2),
      Expanded(child: Text(data.name ?? 'anonymous')),
      const SizedBox(height: 4),
    ];

    if (hasDate)
      return Column(
        children: children,
      );
    return Row(
      children: children,
    );
  }
}
