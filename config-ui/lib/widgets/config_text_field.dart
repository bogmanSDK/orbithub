import 'package:flutter/material.dart';

/// Reusable text field widget for configuration
class ConfigTextField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final String? helpText;
  final String? errorText;
  final TextInputType? keyboardType;
  final int? maxLines;
  
  const ConfigTextField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.obscureText = false,
    this.helpText,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
  });
  
  @override
  State<ConfigTextField> createState() => _ConfigTextFieldState();
}

class _ConfigTextFieldState extends State<ConfigTextField> {
  late TextEditingController _controller;
  late String _initialValue;
  bool _isObscured = false; // All fields can be obscured
  
  @override
  void initState() {
    super.initState();
    _initialValue = widget.value ?? '';
    _controller = TextEditingController(text: _initialValue);
    _isObscured = widget.obscureText; // Start obscured if marked as password
    
    // Add listener to sync controller changes
    _controller.addListener(() {
      if (widget.onChanged != null && _controller.text != widget.value) {
        widget.onChanged!(_controller.text);
      }
    });
    
    if (_initialValue.isNotEmpty) {
      print('ConfigTextField ${widget.label} initialized with: ${_initialValue.substring(0, _initialValue.length.clamp(0, 20))}...');
    }
  }
  
  @override
  void didUpdateWidget(ConfigTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only update if the external value actually changed
    if (widget.value != oldWidget.value) {
      final newValue = widget.value ?? '';
      if (_controller.text != newValue) {
        // Update controller without triggering onChanged
        _controller.removeListener(() {});
        _controller.text = newValue;
        _controller.addListener(() {
          if (widget.onChanged != null) {
            widget.onChanged!(_controller.text);
          }
        });
        print('Updated ${widget.label}: old="${oldWidget.value?.substring(0, 20)}" new="${newValue.substring(0, newValue.length.clamp(0, 20))}"');
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: widget.helpText,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF2196F3), // Blue icon
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              tooltip: _isObscured ? 'Show' : 'Hide',
            ),
          ),
        ),
        if (widget.helpText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helpText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

