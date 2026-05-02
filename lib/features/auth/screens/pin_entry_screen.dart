import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';

enum PinPurpose { set, verify }

class PinEntryScreen extends ConsumerStatefulWidget {
  final PinPurpose purpose;
  final VoidCallback onAuthenticated;

  const PinEntryScreen({
    super.key,
    required this.purpose,
    required this.onAuthenticated,
  });

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final List<String> _pin = [];
  String? _firstPin; // Used during 'set' purpose for confirmation
  bool _isConfirming = false;
  String _error = '';

  void _handleNumberPress(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(number);
        _error = '';
      });
      if (_pin.length == 4) {
        _submitPin();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _error = '';
      });
    }
  }

  Future<void> _submitPin() async {
    final enteredPin = _pin.join();
    final authService = ref.read(authServiceProvider);

    if (widget.purpose == PinPurpose.verify) {
      final success = await authService.verifyFallbackPin(enteredPin);
      if (success) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _pin.clear();
          _error = 'Incorrect PIN. Try again.';
        });
      }
    } else {
      // Purpose: set
      if (!_isConfirming) {
        setState(() {
          _firstPin = enteredPin;
          _isConfirming = true;
          _pin.clear();
        });
      } else {
        if (enteredPin == _firstPin) {
          await authService.setFallbackPin(enteredPin);
          widget.onAuthenticated();
        } else {
          setState(() {
            _pin.clear();
            _error = 'PINs do not match. Start over.';
            _isConfirming = false;
            _firstPin = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String title = '';
    if (widget.purpose == PinPurpose.verify) {
      title = 'Enter App PIN';
    } else {
      title = _isConfirming ? 'Confirm New PIN' : 'Set 4-Digit App PIN';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.lock_person_rounded, size: 64, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _error,
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
            ],
            const Spacer(),
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                );
              }),
            ),
            const Spacer(),
            // Numeric Keypad
            _buildKeypad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          _buildKeypadRow(row),
        _buildKeypadRow(['', '0', 'backspace']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) {
        if (val.isEmpty) return const SizedBox(width: 80);
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => val == 'backspace' ? _handleBackspace() : _handleNumberPress(val),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              child: val == 'backspace'
                  ? const Icon(Icons.backspace_outlined, size: 28)
                  : Text(
                      val,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
