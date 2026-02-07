import 'package:flutter/material.dart';
import 'package:wanderlog/data/credentials_storage.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';

class ApiKeySettingsDialog extends StatefulWidget {
  final PaymentGatewayApi api;
  final CredentialsStorage storage;

  const ApiKeySettingsDialog({
    super.key,
    required this.api,
    required this.storage,
  });

  @override
  State<ApiKeySettingsDialog> createState() => _ApiKeySettingsDialogState();
}

class _ApiKeySettingsDialogState extends State<ApiKeySettingsDialog> {
  late TextEditingController _apiKeyController;
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: widget.api.getApiKey() ?? '',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      setState(() {
        _message = 'API key cannot be empty';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.storage.saveApiKey(apiKey);
      widget.api.setApiKey(apiKey);

      setState(() {
        _isLoading = false;
        _message = 'API key saved successfully';
        _isSuccess = true;
      });

      // Close dialog after success
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error saving API key: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _clearApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.storage.clearApiKey();
      widget.api.clearApiKey();
      _apiKeyController.clear();

      setState(() {
        _isLoading = false;
        _message = 'API key cleared';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error clearing API key: $e';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('API Key Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your API key to access protected endpoints:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 4,
              obscureText: false,
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color:
                        _isSuccess ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (widget.api.getApiKey() != null && widget.api.getApiKey()!.isNotEmpty)
          TextButton(
            onPressed: _isLoading ? null : _clearApiKey,
            child: const Text('Clear'),
          ),
        FilledButton(
          onPressed: _isLoading ? null : _saveApiKey,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
