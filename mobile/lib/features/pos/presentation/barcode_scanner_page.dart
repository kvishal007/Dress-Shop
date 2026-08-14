import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';

/// Full-screen QR/barcode scanner using the device's live camera.
/// Returns the scanned code string via [Navigator.pop], or null if closed
/// without a successful scan.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
  );

  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  /// Some laptop webcams don't report a facing mode the browser recognizes,
  /// which can make one of the two facing constraints fail even though the
  /// camera itself works fine. Try the rear/environment constraint first,
  /// then fall back to the front/user-facing one before giving up.
  Future<void> _startCamera() async {
    await _controller.start(cameraDirection: CameraFacing.back);
    if (!mounted) return;
    if (_controller.value.error?.errorCode == MobileScannerErrorCode.unsupported) {
      await _controller.start(cameraDirection: CameraFacing.front);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code.trim().isEmpty) return;
    _handled = true;
    Navigator.pop(context, code.trim());
  }

  String _messageFor(MobileScannerErrorCode code) {
    switch (code) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission is required to scan products.';
      case MobileScannerErrorCode.unsupported:
        return 'No camera was detected. Please check your laptop camera.';
      default:
        return 'Unable to start the camera. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off, color: Colors.white54, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      _messageFor(error.errorCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _startCamera,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              'Point your camera at the product QR code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
