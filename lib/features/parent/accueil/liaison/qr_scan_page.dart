import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:app_mobile/features/parent/services/parent_service.dart';

enum ScanPageStatus { scanning, connecting, success, failure }

class QrScanPage extends StatefulWidget {
  final bool isFromLogin;
  const QrScanPage({super.key, this.isFromLogin = false});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> with TickerProviderStateMixin {
  ScanPageStatus _status = ScanPageStatus.scanning;
  bool _isProcessing = false;

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  late AnimationController _chevronController;
  late Animation<double> _chevronAnimation;
  late AnimationController _connectingController;
  late Animation<double> _connectingAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _chevronAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );

    _connectingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _connectingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _connectingController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _chevronController.dispose();
    _connectingController.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _status = ScanPageStatus.connecting;
    });

    _laserController.stop();

    // Démarrer l'animation de la barre de progression (liaison)
    _connectingController.forward(from: 0.0);

    bool apiFinished = false;
    bool animationFinished = false;
    bool apiSuccess = false;
    dynamic apiResult;
    String apiError = '';

    // Écouter la fin de l'animation pour transitionner
    _connectingController.addStatusListener((state) {
      if (state == AnimationStatus.completed) {
        animationFinished = true;
        if (apiFinished) {
          _transitionToResult(apiSuccess, apiResult, apiError);
        }
      }
    });

    try {
      final parentId = await AuthService.getParentId();
      if (parentId == null) {
        apiSuccess = false;
        apiError = 'Session invalide. Veuillez vous reconnecter.';
        apiFinished = true;
        if (animationFinished) {
          _transitionToResult(apiSuccess, null, apiError);
        }
        return;
      }

      int targetParentId = parentId;
      final dio = ApiClient.getInstanceForCode(code);

      // Si le code pointe vers un serveur différent, on utilise la méthode centralisée
      if (dio.options.baseUrl != ApiClient.defaultServerUrl && code.contains('-')) {
        final prefix = code.split('-')[0].toUpperCase();
        final serverParentId = await AuthService.getParentIdForSchool(prefix);
        if (serverParentId != null) {
          targetParentId = serverParentId;
        } else {
          throw Exception("Connexion au second serveur impossible ou compte introuvable.");
        }
      }

      final response = await dio.post(
        ApiEndpoints.linkQrCode,
        data: {
          'qr_code': code,
          'parent_id': targetParentId,
        },
      );

      apiFinished = true;
      if (response.statusCode == 200 && response.data['success']) {
        apiSuccess = true;
        apiResult = response.data['eleve'];
      } else {
        apiSuccess = false;
        apiError = "Vous n'êtes pas reconnu comme parent.";
      }
    } catch (e) {
      apiFinished = true;
      apiSuccess = false;
      apiError = 'Erreur de connexion à l\'API.';
    }

    // Si l'animation est déjà terminée quand l'API répond
    if (animationFinished) {
      _transitionToResult(apiSuccess, apiResult, apiError);
    }
  }

  void _transitionToResult(bool success, dynamic eleve, String error) async {
    if (success && eleve != null) {
      setState(() {
        _status = ScanPageStatus.success;
      });

      final childIdRaw = eleve['id'];
      if (childIdRaw != null) {
        final childId = int.tryParse(childIdRaw.toString());
        if (childId != null) {
          await ParentService.addLocallyVerifiedChild(childId);
        }
      }

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        if (widget.isFromLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('parent_scan_done', true);
          Navigator.pushReplacementNamed(context, '/parent/home');
        } else {
          Navigator.pop(context, eleve);
        }
      }
    } else {
      setState(() {
        _status = ScanPageStatus.failure;
      });
    }
  }

  Widget _buildBottomIndicator() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.face, color: Colors.green[600], size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Enfant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.blue[600], size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Parent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanWindowSize = screenWidth * 0.7;
    final scanWindow = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2 - 50),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    if (_status == ScanPageStatus.success) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Liaison établie\navec succès',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF114c61),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vous êtes maintenant lié à cet enfant.',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _buildBottomIndicator(),
          ],
        ),
      );
    }

    if (_status == ScanPageStatus.failure) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Désolé',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF114c61),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Vous n'êtes pas reconnu(e) comme parent de cet enfant.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Veuillez contacter l'administration.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _status = ScanPageStatus.scanning;
                          _isProcessing = false;
                        });
                        _laserController.repeat(reverse: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2596be),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Réessayer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomIndicator(),
          ],
        ),
      );
    }

    final Color currentBorderColor = _status == ScanPageStatus.connecting
        ? Colors.green
        : const Color(0xFF2596be);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Scanner en arrière-plan
          MobileScanner(
            onDetect: (capture) {
              if (_status != ScanPageStatus.scanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQrCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Overlay blanc avec découpe pour le scanner
          CustomPaint(
            painter: QrOverlayPainter(
              scanWindow: scanWindow,
              borderColor: currentBorderColor,
            ),
            child: const SizedBox.expand(),
          ),

          // Textes en haut de l'écran
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Scanner le QR code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF114c61),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _status == ScanPageStatus.connecting
                      ? 'QR code détecté'
                      : 'Placez le QR code dans le cadre\npour établir la liaison',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _status == ScanPageStatus.connecting
                        ? Colors.blue
                        : Colors.grey[600],
                    fontWeight: _status == ScanPageStatus.connecting
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Éléments du mode Scanning (Laser & Chevrons)
          if (_status == ScanPageStatus.scanning) ...[
            // Ligne de scan laser animée
            AnimatedBuilder(
              animation: _laserAnimation,
              builder: (context, child) {
                return Positioned(
                  left: scanWindow.left + 8,
                  right: scanWindow.right - 8,
                  top:
                      scanWindow.top +
                      (scanWindow.height * _laserAnimation.value),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2596be),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2596be).withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Doubles flèches animées haut/bas
            AnimatedBuilder(
              animation: _chevronAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: scanWindow.top - 45 + (_chevronAnimation.value * 10),
                      left: 0,
                      right: 0,
                      child: const Icon(
                        Icons.keyboard_double_arrow_up,
                        color: Color(0xFF2596be),
                        size: 30,
                      ),
                    ),
                    Positioned(
                      top:
                          scanWindow.bottom +
                          15 -
                          (_chevronAnimation.value * 10),
                      left: 0,
                      right: 0,
                      child: const Icon(
                        Icons.keyboard_double_arrow_down,
                        color: Color(0xFF2596be),
                        size: 30,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          // Éléments du mode Connecting (Barre de liaison animée)
          if (_status == ScanPageStatus.connecting)
            Positioned(
              top: scanWindow.bottom + 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  const Text(
                    'Connexion en cours...',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.face,
                          color: Colors.green[600],
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Stack(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _connectingAnimation,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    widthFactor: _connectingAnimation.value,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Indicateur visuel du bas
          _buildBottomIndicator(),
        ],
      ),
    );
  }
}

class QrOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;
  final Color borderColor;

  QrOverlayPainter({
    required this.scanWindow,
    this.borderRadius = 24.0,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fond blanc opaque autour de la fenêtre
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Dessin des coins arrondis
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30.0;
    final r = borderRadius;

    // Haut Gauche
    final topLeftPath = Path()
      ..moveTo(scanWindow.left, scanWindow.top + cornerLength)
      ..lineTo(scanWindow.left, scanWindow.top + r)
      ..arcToPoint(
        Offset(scanWindow.left + r, scanWindow.top),
        radius: Radius.circular(r),
      )
      ..lineTo(scanWindow.left + cornerLength, scanWindow.top);
    canvas.drawPath(topLeftPath, borderPaint);

    // Haut Droite
    final topRightPath = Path()
      ..moveTo(scanWindow.right - cornerLength, scanWindow.top)
      ..lineTo(scanWindow.right - r, scanWindow.top)
      ..arcToPoint(
        Offset(scanWindow.right, scanWindow.top + r),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(scanWindow.right, scanWindow.top + cornerLength);
    canvas.drawPath(topRightPath, borderPaint);

    // Bas Gauche
    final bottomLeftPath = Path()
      ..moveTo(scanWindow.left, scanWindow.bottom - cornerLength)
      ..lineTo(scanWindow.left, scanWindow.bottom - r)
      ..arcToPoint(
        Offset(scanWindow.left + r, scanWindow.bottom),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(scanWindow.left + cornerLength, scanWindow.bottom);
    canvas.drawPath(bottomLeftPath, borderPaint);

    // Bas Droite
    final bottomRightPath = Path()
      ..moveTo(scanWindow.right - cornerLength, scanWindow.bottom)
      ..lineTo(scanWindow.right - r, scanWindow.bottom)
      ..arcToPoint(
        Offset(scanWindow.right, scanWindow.bottom - r),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(scanWindow.right, scanWindow.bottom - cornerLength);
    canvas.drawPath(bottomRightPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant QrOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.scanWindow != scanWindow;
  }
}
