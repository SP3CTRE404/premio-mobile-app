import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/custom_toast.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _isScanning = true;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() => _isScanning = false);
        Navigator.pop(context, barcode.rawValue);
        break;
      }
    }
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && mounted) {
      final BarcodeCapture? capture = await _controller.analyzeImage(image.path);
      
      if (capture != null && capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty && mounted) {
          Navigator.pop(context, barcode.rawValue);
        }
      } else if (mounted) {
        CustomToast.show(context: context, message: 'No QR code found in the selected image.', isError: false);
      }
    }
  }

  Widget _buildCornerBorder({required bool top, required bool left}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.white, width: 5) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.white, width: 5) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.white, width: 5) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.white, width: 5) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(24) : Radius.zero,
          topRight: top && !left ? const Radius.circular(24) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(24) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Dark overlay with cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.2),
                  child: Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Brackets Layer (Slightly above center)
          Align(
            alignment: const Alignment(0, -0.2),
            child: SizedBox(
              height: 280,
              width: 280,
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _buildCornerBorder(top: true, left: true)),
                  Positioned(top: 0, right: 0, child: _buildCornerBorder(top: true, left: false)),
                  Positioned(bottom: 0, left: 0, child: _buildCornerBorder(top: false, left: true)),
                  Positioned(bottom: 0, right: 0, child: _buildCornerBorder(top: false, left: false)),
                ],
              ),
            ),
          ),
          
          // Foreground UI (Text and Buttons)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Placeholder to account for the shifted box
                const SizedBox(height: 280),
                
                const Spacer(flex: 1),
                const Text(
                  'Align the QR code to fit inside the frame.\nPinch to zoom for better focus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                ),
                
                const Spacer(flex: 4),
                
                // Bottom Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: _isTorchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded, 
                      label: 'Flashlight',
                      onTap: () {
                        setState(() {
                          _isTorchOn = !_isTorchOn;
                          _controller.toggleTorch();
                        });
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.photo_outlined,
                      label: 'Scan from\nGallery',
                      onTap: _scanFromGallery,
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
