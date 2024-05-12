import 'package:flutter/material.dart';
import 'package:flutter_example/core/constants/network_constants.dart';
import 'package:flutter_example/core/models/result_model.dart';
import 'package:flutter_example/modules/file/interfaces/file_service_interface.dart';
import 'package:flutter_example/shared/stores/file_store.dart';
import 'package:flutter_example/shared/widgets/example_button.dart';
import 'package:signals/signals_flutter.dart';

mixin FileViewMixin on State<FileView> {
  void showMaxDownloadsReachedSnackBar();

  Future<void> downloadFile() async {
    final tasks = [
      widget.fileService.downloadFile(NetworkConstants.imageUrl, 'smallImage'),
      widget.fileService.downloadFile(NetworkConstants.largeImageUrl, 'largeImage'),
    ];

    final results = await Future.wait(tasks);

    for (final result in results) {
      if (result is Failure) {
        showMaxDownloadsReachedSnackBar();
        break;
      }
    }
  }

  Future<void> downloadFileSmall() async {
    final result = await widget.fileService.downloadFile(NetworkConstants.imageUrl, 'smallImage');

    if (result is Failure) showMaxDownloadsReachedSnackBar();
  }

  Future<void> downloadFileLarge() async {
    final result = await widget.fileService.downloadFile(NetworkConstants.largeImageUrl, 'largeImage');
    if (result is Failure) showMaxDownloadsReachedSnackBar();
  }
}

class FileView extends StatefulWidget {
  final IFileService fileService;
  final FileStore fileStore;

  const FileView({super.key, required this.fileService, required this.fileStore});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> with FileViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          ExampleButton(onPressed: downloadFile, text: 'Download Files Concurrently'),
          ExampleButton(onPressed: downloadFileSmall, text: 'Download Small File'),
          ExampleButton(onPressed: downloadFileLarge, text: 'Download Large File'),
          DownloadsListWidget(fileStore: widget.fileStore),
        ],
      ),
    );
  }

  @override
  void showMaxDownloadsReachedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Max downloads reached. Please wait for some downloads to complete.'),
      ),
    );
  }
}

class DownloadsListWidget extends StatelessWidget {
  final FileStore fileStore;

  const DownloadsListWidget({
    super.key,
    required this.fileStore,
  });

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: fileStore.fileDownloadQueue.value.length,
        itemBuilder: (context, index) {
          final fileName = fileStore.fileDownloadQueue.value[index].fileName;
          final progress = fileStore.fileDownloadQueue.value[index].progress;

          return ListTile(
            title: Text(fileName),
            trailing: progress < 100 ? Text('$progress%') : const Icon(Icons.download_done),
          );
        },
      ),
    );
  }
}
