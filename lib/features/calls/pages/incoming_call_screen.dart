import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/calls/pages/call_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';

/// Écran d'appel entrant (plein écran comme un vrai appel)
class IncomingCallScreen extends StatefulWidget {
  final int callId;
  final String callType; // 'audio' ou 'video'
  final String callerName;
  final int conversationId;
  final Map<String, dynamic>? callData;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callType,
    required this.callerName,
    required this.conversationId,
    this.callData,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _ringDuration = 0;
  Timer? _ringTimer;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation pour l'avatar
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);

    // Timer pour le timeout de l'appel (30 secondes)
    _ringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _ringDuration++;
      });

      // Timeout après 30 secondes
      if (_ringDuration >= 30) {
        _rejectCall('timeout');
      }
    });
  }

  Future<void> _acceptCall() async {
    _ringTimer?.cancel();
    _pulseController.stop();

    // Accepter l'appel via API
    try {
      await ApiClient.instance.put('/calls/${widget.callId}/accept');
    } catch (e) {
      print('❌ [IncomingCall] Erreur acceptation: $e');
    }

    // Naviguer vers la page d'appel
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            callId: widget.callId,
            callType: widget.callType,
            callerName: widget.callerName,
            isIncoming: true,
            callData: widget.callData,
          ),
        ),
      );
    }
  }

  Future<void> _rejectCall([String reason = 'user']) async {
    _ringTimer?.cancel();
    _pulseController.stop();

    // Rejeter l'appel via API
    try {
      await ApiClient.instance.put('/calls/${widget.callId}/reject', data: {
        'reason': reason,
      });
    } catch (e) {
      print('❌ [IncomingCall] Erreur rejet: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = widget.callType == 'video';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a237e), // Bleu foncé
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Type d'appel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : Icons.phone,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isVideo ? 'Appel vidéo entrant' : 'Appel vocal entrant',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Avatar avec animation de pulsation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.seaBlue,
                            AppTheme.seaBlue.withOpacity(0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.seaBlue.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Nom de l'appelant
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Status
              Text(
                'Sonnerie...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),

              // Timer de sonnerie
              Text(
                '${_ringDuration}s',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),

              const Spacer(),

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Refuser
                    _buildActionButton(
                      icon: Icons.call_end,
                      label: 'Refuser',
                      color: Colors.red,
                      onPressed: () => _rejectCall('user'),
                    ),

                    // Accepter
                    _buildActionButton(
                      icon: isVideo ? Icons.videocam : Icons.phone,
                      label: 'Accepter',
                      color: Colors.green,
                      onPressed: _acceptCall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Message de swipe (style iOS)
              Text(
                'Glisser pour répondre',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
