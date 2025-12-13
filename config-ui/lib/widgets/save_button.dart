import 'package:flutter/material.dart';

/// Save button widget with status indication
class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  
  const SaveButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : isSuccess
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Icon(Icons.save),
            label: Text(
              isLoading
                  ? 'Saving...'
                  : isSuccess
                      ? 'Saved Successfully'
                      : 'Save Configuration',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess
                  ? const Color(0xFF4CAF50) // Green for success
                  : const Color(0xFF2196F3), // Material Blue
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

