import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/parent/services/parent_service.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class VerifyChildScannerPage extends StatefulWidget {
  final Map<String, dynamic> child;
  final VoidCallback onSuccess;

  const VerifyChildScannerPage({
    super.key,
    required this.child,
    required this.onSuccess,
  });

  @override
  State<VerifyChildScannerPage> createState() => _VerifyChildScannerPageState();
}

enum ScannerState { scanning, connecting, success, error }

class _VerifyChildScannerPageState extends State<VerifyChildScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  ScannerState _state = ScannerState.scanning;

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_state != ScannerState.scanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _verifyCode(code);
      }
    }
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _state = ScannerState.connecting;
    });

    final parentId = await AuthService.getParentId();
    if (parentId == null) {
      setState(() {
        _state = ScannerState.error;
      });
      return;
    }

    final success = await ParentService.verifyChildAccess(
      parentId,
      widget.child['id'] ?? widget.child['raw_id'],
      code,
      schoolPrefix: widget.child['_school_prefix']?.toString(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _state = ScannerState.success;
      });
      // Attendre un peu pour l'animation de succès puis fermer
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _state = ScannerState.error;
      });
    }
  }

  void _showManualEntryModal() {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.keyboard, size: 40, color: AppTheme.seaBlue),
                  const SizedBox(height: 15),
                  const Text(
                    'Saisie manuelle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Entrez le code secret de ${widget.child['prenom'] ?? widget.child['name']}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: 'Code secret (ex: LYNDQ-...)',
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.key),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final code = codeController.text.trim();
                              if (code.isEmpty) {
                                setModalState(
                                  () => errorText =
                                      'Veuillez entrer le code secret',
                                );
                                return;
                              }
                              setModalState(() {
                                isLoading = true;
                                errorText = null;
                              });

                              final parentId = await AuthService.getParentId();
                              if (parentId != null) {
                                final success =
                                    await ParentService.verifyChildAccess(
                                      parentId,
                                      widget.child['id'] ??
                                          widget.child['raw_id'],
                                      code,
                                      schoolPrefix: widget.child['_school_prefix']?.toString(),
                                    );

                                if (!mounted) return;
                                if (success) {
                                  Navigator.pop(
                                    context,
                                  ); // Fermer le modal de saisie
                                  setState(() {
                                    _state = ScannerState.success;
                                  });
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );
                                  if (mounted) {
                                    widget.onSuccess();
                                    Navigator.pop(
                                      context,
                                    ); // Fermer la page du scanner
                                  }
                                } else {
                                  setModalState(() {
                                    isLoading = false;
                                    errorText =
                                        'Code secret incorrect ou erreur serveur.';
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Vérifier',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_state == ScannerState.scanning ||
                _state == ScannerState.connecting) ...[
              const Text(
                'Scanner le QR code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Placez le QR code dans le cadre\npour établir la liaison',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
              ),
              if (_state == ScannerState.connecting)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'QR code détecté',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.seaBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
            const Spacer(),
            // Zone centrale dynamique selon l'état
            _buildCenterArea(),
            const Spacer(),
            // Zone des icônes de bas de page
            _buildBottomBar(),
            const SizedBox(height: 20),
            // Bouton de saisie manuelle (uniquement en état scanning)
            if (_state == ScannerState.scanning || _state == ScannerState.error)
              TextButton(
                onPressed: _showManualEntryModal,
                child: const Text(
                  'Saisir manuellement',
                  style: TextStyle(
                    color: AppTheme.seaBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterArea() {
    if (_state == ScannerState.success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Liaison établie\navec succès',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Vous êtes maintenant lié à cet enfant.',
            style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      );
    }

    if (_state == ScannerState.error) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel, color: Colors.red, size: 80),
          ),
          const SizedBox(height: 30),
          const Text(
            'Désolé',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vous n\'êtes pas reconnu(e) comme parent de cet enfant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Veuillez contacter l\'administration.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _state = ScannerState.scanning;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    // Scanning & Connecting States
    return _buildScannerBox();
  }

  Widget _buildScannerBox() {
    final double size = MediaQuery.of(context).size.width * 0.65;
    final bool isConnecting = _state == ScannerState.connecting;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnecting
                ? Colors.green
                : AppTheme.seaBlue.withOpacity(0.5),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: isConnecting
                  ? Container(
                      color: Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: size * 0.8,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
            ),
            if (!isConnecting)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _scanAnimation.value * (size - 4),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          if (_state == ScannerState.connecting)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Connexion en cours...',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomIcon(Icons.face, 'Enfant', Colors.green),
              if (_state == ScannerState.connecting)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                ),
              _buildBottomIcon(
                Icons.person_outline,
                'Parent',
                AppTheme.seaBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

