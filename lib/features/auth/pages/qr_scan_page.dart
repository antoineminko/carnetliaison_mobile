import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isProcessing = false;

  Future<void> _processQrCode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final parentId = await AuthService.getParentId() ?? 1;

      final response = await ApiClient.instance.post(
        ApiEndpoints.linkQrCode,
        data: {
          'qr_code': code,
          'parent_id': parentId,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        final eleve = response.data['eleve'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enfant lié : ${eleve['prenom']} ${eleve['nom']}')),
          );
          Navigator.pop(context, eleve);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Merci pour votre demande de fusion à cet enfant, mais vous n'êtes pas identifié comme parent. Veuillez contacter l'administration."),
              duration: Duration(seconds: 4),
            ),
          );
          // Pause before allowing another scan to avoid spam
          await Future.delayed(const Duration(seconds: 4));
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion à l\'API.')),
        );
        // Pause before allowing another scan to avoid spam
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanWindowSize = screenWidth * 0.7;
    final scanWindow = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2 - 50), // slightly higher than center
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scanner le QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQrCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          CustomPaint(
            painter: QrOverlayPainter(scanWindow: scanWindow),
            child: const SizedBox.expand(),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Placez le QR Code dans le cadre',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class QrOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  QrOverlayPainter({required this.scanWindow, this.borderRadius = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);
    
    final double cornerLength = 40.0;
    
    // Top Left
    canvas.drawLine(scanWindow.topLeft, scanWindow.topLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topLeft, scanWindow.topLeft + Offset(0, cornerLength), borderPaint);
    
    // Top Right
    canvas.drawLine(scanWindow.topRight, scanWindow.topRight + Offset(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topRight, scanWindow.topRight + Offset(0, cornerLength), borderPaint);
    
    // Bottom Left
    canvas.drawLine(scanWindow.bottomLeft, scanWindow.bottomLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.bottomLeft, scanWindow.bottomLeft + Offset(0, -cornerLength), borderPaint);
    
    // Bottom Right
    canvas.drawLine(scanWindow.bottomRight, scanWindow.bottomRight + Offset(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.bottomRight, scanWindow.bottomRight + Offset(0, -cornerLength), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
