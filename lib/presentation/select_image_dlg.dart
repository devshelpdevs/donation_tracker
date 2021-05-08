import 'dart:io';

import 'package:cropper/cropper.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<String?> showSelectImageDlg(
  BuildContext context,
) {
  return showFluidBarModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SelectImageDlg();
    },
    enableDrag: false,
  );
}

class SelectImageDlg extends StatefulWidget {
  @override
  _SelectImageDlgState createState() => _SelectImageDlgState();
}

class _SelectImageDlgState extends State<SelectImageDlg> {
  List<StorageFileInfo> files = [];
  XFile? fileToUpLoad;
  CropController cropController = CropController(scale: 1.0);

  @override
  void initState() {
    GetIt.I<NhostService>().getAvailableFiles().then((files) {
      if (mounted) {
        setState(() {
          this.files = files;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.blue.shade900,
      child: LayoutBuilder(builder: (context, constraints) {
        final imagesize = constraints.maxWidth / 4;
        return fileToUpLoad == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Image',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: files
                            .map<Widget>((e) => ImageEntry(
                                  imagesize: imagesize,
                                  fileInfo: e,
                                  onImageSelected: (fileName) {
                                    Navigator.of(context).pop(fileName);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, right: 8, bottom: 9),
                          child: Text(
                            'Cancel',
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
                      TextButton(
                        onPressed: () async {
                          await upLoadImage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, right: 8, bottom: 9),
                          child: Text(
                            'Upload',
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
                ],
              )
            : Crop(
                helper: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                child: Image.file(
                  File(fileToUpLoad!.path),
                  fit: BoxFit.cover,
                ),
                controller: cropController);
      }),
    );
  }

  Future<void> upLoadImage() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    fileToUpLoad = await openFile(acceptedTypeGroups: [typeGroup]);
    setState(() {});
  }
}

class ImageEntry extends StatelessWidget {
  const ImageEntry({
    Key? key,
    required this.imagesize,
    required this.fileInfo,
    required this.onImageSelected,
  }) : super(key: key);

  final double imagesize;
  final StorageFileInfo fileInfo;
  final ValueChanged<String> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imagesize,
      child: InkWell(
        onTap: () => onImageSelected(fileInfo.fileName),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.network(
                fileInfo.imageLink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fileInfo.fileName.replaceAll('%20', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
