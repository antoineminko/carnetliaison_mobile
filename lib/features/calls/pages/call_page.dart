import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/calls/services/webrtc_service.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

/// Page d'appel vocal ou vidéo
class CallPage extends StatefulWidget {
  final int callId;
  final String callType; // 'audio' ou 'video'
  final String callerName;
  final bool isIncoming; // true si c'est un appel entrant
  final Map<String, dynamic>? callData; // Données de l'appel si entrant

  const CallPage({
    super.key,
    required this.callId,
    required this.callType,
    required this.callerName,
    this.isIncoming = false,
    this.callData,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final WebRTCService _webRTCService = WebRTCService();
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isConnecting = true;
  bool _isConnected = false;
  String _callStatus = 'Connexion...';
  int _callDuration = 0;
  Timer? _durationTimer;
  String? _myRole;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _webRTCService.initRenderers();

    // Callbacks
    _webRTCService.onLocalStream = (stream) {
      setState(() {});
    };

    _webRTCService.onRemoteStream = (stream) {
      setState(() {
        _isConnecting = false;
        _isConnected = true;
        _callStatus = 'Connecté';
        _startDurationTimer();
      });
    };

    _webRTCService.onConnectionStateChange = (state) {
      setState(() {
        _callStatus = _getConnectionStatusLabel(state);
      });
    };

    _webRTCService.onCallEnded = () {
      _endCallAndPop();
    };

    if (widget.isIncoming && widget.callData != null) {
      // Appel entrant - rejoindre
      final offer = widget.callData!['offer'];
      if (offer != null) {
        await _webRTCService.joinCall(
          widget.callId,
          offer,
          widget.callType == 'video',
        );
      }
    } else {
      // Appel sortant - démarrer
      final result = await _webRTCService.startCall(
        widget.callId,
        widget.callType == 'video',
      );

      if (result['success']) {
        // Envoyer l'offre au serveur
        await _sendOfferToServer(result['offer']);
      }
    }

    // Polling pour recevoir les candidats ICE et réponses
    _startSignalingPolling();
  }

  Future<void> _sendOfferToServer(dynamic offer) async {
    try {
      await ApiClient.instance.post('/calls/${widget.callId}/offer', data: offer);
    } catch (e) {
      print('❌ [CallPage] Erreur envoi offer: $e');
    }
  }

  void _startSignalingPolling() {
    // Toutes les 2 secondes, récupérer les candidats ICE et la réponse
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || _isConnected) {
        timer.cancel();
        return;
      }

      try {
        final response = await ApiClient.instance.get(
          '/calls/${widget.callId}/signaling',
        );

        if (response.data != null) {
          final data = response.data;

          // Traiter les candidats ICE
          if (data['ice_candidates'] != null) {
            for (final candidate in data['ice_candidates']) {
              await _webRTCService.addRemoteIceCandidate(candidate);
            }
          }

          // Traiter la réponse (si appelant)
          if (!widget.isIncoming && data['answer'] != null) {
            await _webRTCService.setRemoteAnswer(data['answer']);
          }
        }
      } catch (e) {
        // Ignorer les erreurs de polling
      }
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  String _getConnectionStatusLabel(String state) {
    switch (state) {
      case 'RTCPeerConnectionState.RTCPeerConnectionStateConnecting':
        return 'Connexion...';
      case 'RTCPeerConnectionState.RTCPeerConnectionStateConnected':
        return 'Connecté';
      case 'RTCPeerConnectionState.RTCPeerConnectionStateDisconnected':
        return 'Déconnecté';
      case 'RTCPeerConnectionState.RTCPeerConnectionStateFailed':
        return 'Échec de connexion';
      case 'RTCPeerConnectionState.RTCPeerConnectionStateClosed':
        return 'Appel terminé';
      default:
        return 'En cours...';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMute() async {
    _webRTCService.toggleMute();
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  Future<void> _toggleVideo() async {
    _webRTCService.toggleVideo();
    setState(() {
      _isVideoOff = !_isVideoOff;
    });
  }

  Future<void> _toggleSpeaker() async {
    // Pour iOS/Android, utiliser audio_session ou flutter_sound
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  Future<void> _endCall() async {
    _durationTimer?.cancel();

    // Notifier le serveur
    try {
      await ApiClient.instance.put('/calls/${widget.callId}/end');
    } catch (e) {
      print('❌ [CallPage] Erreur end call API: $e');
    }

    await _webRTCService.endCall();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _endCallAndPop() {
    _durationTimer?.cancel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _webRTCService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = widget.callType == 'video';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vidéo distante (plein écran pour vidéo, caché pour audio)
          if (isVideo)
            Positioned.fill(
              child: _webRTCService.remoteRenderer != null
                  ? RTCVideoView(
                      _webRTCService.remoteRenderer!,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.seaBlue.withOpacity(0.3),
                              child: const Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.callerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            )
          else
            // Fond pour appel audio
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!,
                    Colors.black,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar animé
                    Container(
                      width: 150,
                      height: 150,
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
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      widget.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isConnected
                          ? _formatDuration(_callDuration)
                          : _callStatus,
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Vidéo locale (picture-in-picture)
          if (isVideo && !_isVideoOff)
            Positioned(
              top: 50,
              right: 20,
              width: 120,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _webRTCService.localRenderer != null
                      ? RTCVideoView(
                          _webRTCService.localRenderer!,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : Container(color: Colors.grey[800]),
                ),
              ),
            ),

          // Overlay pour appel vidéo (nom et durée)
          if (isVideo)
            Positioned(
              top: 50,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isConnected
                        ? _formatDuration(_callDuration)
                        : _callStatus,
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.white70,
                      fontSize: 14,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Contrôles (en bas)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Indicateur de connexion
                  if (_isConnecting)
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _callStatus,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  // Boutons de contrôle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Microphone
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Muet' : 'Micro',
                        color: _isMuted ? Colors.red : Colors.white,
                        backgroundColor: _isMuted ? Colors.red.withOpacity(0.3) : Colors.white24,
                        onPressed: _toggleMute,
                      ),

                      // Vidéo (uniquement pour appel vidéo)
                      if (isVideo)
                        _buildControlButton(
                          icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                          label: _isVideoOff ? 'Cam off' : 'Caméra',
                          color: _isVideoOff ? Colors.red : Colors.white,
                          backgroundColor: _isVideoOff ? Colors.red.withOpacity(0.3) : Colors.white24,
                          onPressed: _toggleVideo,
                        ),

                      // Haut-parleur (audio uniquement)
                      if (!isVideo)
                        _buildControlButton(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          label: _isSpeakerOn ? 'HP' : 'Oreille',
                          color: _isSpeakerOn ? Colors.white : Colors.grey,
                          backgroundColor: Colors.white24,
                          onPressed: _toggleSpeaker,
                        ),

                      // Raccrocher
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'Raccrocher',
                        color: Colors.white,
                        backgroundColor: Colors.red,
                        size: 70,
                        onPressed: _endCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    double size = 60,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: size == 70 ? 35 : 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
