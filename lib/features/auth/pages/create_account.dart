import 'package:flutter/material.dart';

class CreateAccountPage extends StatelessWidget {
  final String? email;
  final String? childQrCode;

  const CreateAccountPage({super.key, this.email, this.childQrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Création de Compte')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              childQrCode != null 
                ? 'Liaison avec enfant détecté' 
                : 'Créez votre compte Parent',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
             Text(
              'Email: ${email ?? "Non renseigné"}',
              style: TextStyle(color: Colors.grey[600]),
            ),
             if (childQrCode != null)
              Text(
                'Code Enfant: $childQrCode',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                 Navigator.pushNamedAndRemoveUntil(context, '/parent/home', (route) => false);
              },
              child: const Text('SIMULER CRÉATION & CONNEXION'),
            )
          ],
        ),
      ),
    );
  }
}
