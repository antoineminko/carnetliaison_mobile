import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:app_mobile/features/parent/services/parent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkChildPage extends StatefulWidget {
  const LinkChildPage({super.key});


  @override
  State<LinkChildPage> createState() => _LinkChildPageState();
}

class _LinkChildPageState extends State<LinkChildPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _linkChild() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final parentId = await AuthService.getParentId() ?? 1;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Vérification en cours...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }

      int targetParentId = parentId;
      final dio = ApiClient.getInstanceForCode(code);

      // Si le code pointe vers un serveur différent, on utilise la méthode centralisée
      if (dio.options.baseUrl != ApiClient.defaultServerUrl && code.contains('-')) {
        final prefix = code.split('-')[0].toUpperCase();
        try {
          final serverParentId = await AuthService.getParentIdForSchool(prefix);
          if (serverParentId != null) {
            targetParentId = serverParentId;
          } else {
            throw Exception("Votre compte n'existe pas encore sur cette école. Veuillez vous inscrire sur leur site web.");
          }
        } catch (e) {
          throw Exception("Votre compte n'existe pas encore sur cette école. Veuillez vous inscrire sur leur site web.");
        }
      }

      final response = await dio.post(
        ApiEndpoints.linkSecretCode,
        data: {
          'code_secret': code,
          'parent_id': targetParentId,
        },
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (response.statusCode == 200 && response.data['success']) {
        final eleve = response.data['eleve'];
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 20),
                  const Text('Enfant lié avec succès !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('${eleve['prenom']} ${eleve['nom']}', style: const TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
          
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context); // Close success dialog
            
            final childIdRaw = eleve['id'];
            if (childIdRaw != null) {
              final childId = int.tryParse(childIdRaw.toString());
              if (childId != null) {
                await ParentService.addLocallyVerifiedChild(childId);
              }
            }
            
            Navigator.pop(context, eleve); // Pop the page
          }
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Erreur de liaison'),
                ],
              ),
              content: const Text("Merci pour votre demande de fusion à cet enfant, mais vous n'êtes pas identifié comme parent. Veuillez contacter l'administration."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Compris'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if error happens
        
        String errorMessage = 'Erreur de connexion à l\'API.';
        if (e is DioException && e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Text('Attention'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lier un enfant manuellement'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Code secret de l\'enfant',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Ex: SEC-K8P9',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _linkChild,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Lier l\'enfant', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
