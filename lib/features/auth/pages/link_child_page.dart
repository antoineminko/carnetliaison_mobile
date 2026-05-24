import 'package:flutter/material.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

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

      final response = await ApiClient.instance.post(
        ApiEndpoints.linkSecretCode,
        data: {
          'code_secret': code,
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
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion à l\'API.')),
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
