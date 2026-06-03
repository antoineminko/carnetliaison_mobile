import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;


  Function(MediaStream?)? onLocalStream;
  Function(MediaStream?)? onRemoteStream;
  Function(RTCIceCandidate)? onIceCandidate;
  Function(String)? onConnectionStateChange;
  Function()? onCallEnded;


  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ],
  };

  Future<void> initRenderers() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();
  }

 
  Future<Map<String, dynamic>> startCall(int callId, bool isVideo) async {
    try {
    
      _peerConnection = await createPeerConnection(_configuration);

   
      _localStream = await _getUserMedia(isVideo);
      _localRenderer?.srcObject = _localStream;
      onLocalStream?.call(_localStream);

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      _peerConnection!.onIceCandidate = (candidate) {
        onIceCandidate?.call(candidate);
        _sendIceCandidate(callId, candidate);
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer?.srcObject = _remoteStream;
          onRemoteStream?.call(_remoteStream);
        }
      };

      _peerConnection!.onConnectionState = (state) {
        onConnectionStateChange?.call(state.toString());
      };
      final offer = await _peerConnection!.createOffer({
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': isVideo,
        },
        'optional': [],
      });

      await _peerConnection!.setLocalDescription(offer);

      return {
        'success': true,
        'offer': offer.toMap(),
      };
    } catch (e) {
      print('❌ [WebRTC] Erreur startCall: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rejoindre un appel (côté receveur)
  Future<bool> joinCall(int callId, dynamic offer, bool isVideo) async {
    try {
      // 1. Créer la connexion peer
      _peerConnection = await createPeerConnection(_configuration);

      // 2. Obtenir le flux local
      _localStream = await _getUserMedia(isVideo);
      _localRenderer?.srcObject = _localStream;
      onLocalStream?.call(_localStream);

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

  
      _peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(callId, candidate);
      };


      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer?.srcObject = _remoteStream;
          onRemoteStream?.call(_remoteStream);
        }
      };

      // 5. Définir l'offre distante
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      // 6. Créer la réponse
      final answer = await _peerConnection!.createAnswer({
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': isVideo,
        },
        'optional': [],
      });

      await _peerConnection!.setLocalDescription(answer);

      // 7. Envoyer la réponse au serveur
      await _sendAnswer(callId, answer);

      return true;
    } catch (e) {
      print('❌ [WebRTC] Erreur joinCall: $e');
      return false;
    }
  }

  /// Définir la réponse distante (côté appelant)
  Future<void> setRemoteAnswer(dynamic answer) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
    } catch (e) {
      print('❌ [WebRTC] Erreur setRemoteAnswer: $e');
    }
  }

  /// Ajouter un candidat ICE distant
  Future<void> addRemoteIceCandidate(dynamic candidate) async {
    try {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        ),
      );
    } catch (e) {
      print('❌ [WebRTC] Erreur addRemoteIceCandidate: $e');
    }
  }

  /// Couper le micro
  void toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().firstOrNull;
      if (audioTrack != null) {
        audioTrack.enabled = !audioTrack.enabled;
      }
    }
  }

  /// Activer/désactiver la caméra
  void toggleVideo() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        videoTrack.enabled = !videoTrack.enabled;
      }
    }
  }

  /// Terminer l'appel
  Future<void> endCall() async {
    onCallEnded?.call();

    // Arrêter les pistes
    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.getTracks().forEach((track) => track.stop());

    // Fermer les connexions
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;

    // Nettoyer les renderers
    _localRenderer?.srcObject = null;
    _remoteRenderer?.srcObject = null;
  }

  /// Libérer les ressources
  Future<void> dispose() async {
    await endCall();
    await _localRenderer?.dispose();
    await _remoteRenderer?.dispose();
    _localRenderer = null;
    _remoteRenderer = null;
  }

  /// Obtenir le flux média local
  Future<MediaStream> _getUserMedia(bool isVideo) async {
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': isVideo
          ? {
              'facingMode': 'user',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
            }
          : false,
    };

    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  /// Envoyer un candidat ICE au serveur
  Future<void> _sendIceCandidate(int callId, RTCIceCandidate candidate) async {
    try {
      await ApiClient.instance.post('/calls/$callId/ice-candidate', data: {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    } catch (e) {
      print(' [WebRTC] Erreur envoi ICE candidate: $e');
    }
  }

  /// Envoyer la réponse au serveur
  Future<void> _sendAnswer(int callId, RTCSessionDescription answer) async {
    try {
      await ApiClient.instance.post('/calls/$callId/answer', data: {
        'sdp': answer.sdp,
        'type': answer.type,
      });
    } catch (e) {
      print('❌ [WebRTC] Erreur envoi answer: $e');
    }
  }

  /// Getters pour les renderers
  RTCVideoRenderer? get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
}
