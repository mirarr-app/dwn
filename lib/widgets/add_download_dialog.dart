import 'package:flutter/material.dart';

class AddDownloadDialog extends StatefulWidget {
  const AddDownloadDialog({super.key});

  @override
  State<AddDownloadDialog> createState() => _AddDownloadDialogState();
}

class _AddDownloadDialogState extends State<AddDownloadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _batchUrlsController = TextEditingController();
  bool _isBatchMode = false;

  @override
  void dispose() {
    _urlController.dispose();
    _batchUrlsController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  List<String> _parseBatchUrls(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isBatchMode) {
        final urls = _parseBatchUrls(_batchUrlsController.text);
        Navigator.of(context).pop(urls);
      } else {
        Navigator.of(context).pop([_urlController.text.trim()]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Download'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode selector
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Single URL'),
                    icon: Icon(Icons.link),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Batch URLs'),
                    icon: Icon(Icons.list),
                  ),
                ],
                selected: {_isBatchMode},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isBatchMode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Single URL input
              if (!_isBatchMode)
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Download URL',
                    hintText: 'https://example.com/file.zip',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a URL';
                    }
                    if (!_isValidUrl(value)) {
                      return 'Please enter a valid HTTP/HTTPS URL';
                    }
                    return null;
                  },
                  autofocus: true,
                  onFieldSubmitted: (_) => _submit(),
                ),

              // Batch URLs input
              if (_isBatchMode)
                TextFormField(
                  controller: _batchUrlsController,
                  decoration: const InputDecoration(
                    labelText: 'Download URLs (one per line)',
                    hintText: 'https://example.com/file1.zip\nhttps://example.com/file2.zip',
                    prefixIcon: Icon(Icons.list),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one URL';
                    }
                    final urls = _parseBatchUrls(value);
                    if (urls.isEmpty) {
                      return 'Please enter at least one valid URL';
                    }
                    final invalidUrls = urls.where((url) => !_isValidUrl(url));
                    if (invalidUrls.isNotEmpty) {
                      return 'Some URLs are invalid: ${invalidUrls.take(2).join(', ')}${invalidUrls.length > 2 ? '...' : ''}';
                    }
                    return null;
                  },
                  autofocus: true,
                ),

              const SizedBox(height: 8),

              // Help text
              Text(
                _isBatchMode
                    ? 'Enter one URL per line. All downloads will be added to the queue.'
                    : 'Enter a valid HTTP or HTTPS URL to download.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isBatchMode ? 'Add All' : 'Add'),
        ),
      ],
    );
  }
}

