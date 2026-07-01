part of 'parent_home_page.dart';

extension DashboardModalsViewExtension on _ParentHomePageState {
  void _showAddChildModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Ajouter un enfant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choisissez une méthode pour ajouter votre enfant',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Carte 1: Scanner
                    _buildMethodCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scanner un QR Code',
                      subtitle: 'Scannez le code fourni par l\'école',
                      color: Colors.blue,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScanPage()),
                        );
                        if (result != null && result is Map) {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool('parent_scan_done', true);
                          });
                          final rawId = result['id'];
                          if (rawId != null) {
                            final childId = rawId is int ? rawId : int.tryParse(rawId.toString());
                            if (childId != null) {
                              await ParentService.addLocallyVerifiedChild(childId);
                              print('[DEBUG] addLocallyVerifiedChild appelé avec id=$childId');
                            }
                          }
                          setState(() { _forceAddChild = false; });
                          await _loadLinkedChildren();
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Carte 2: Manuellement
                    _buildMethodCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Entrer les informations manuellement',
                      subtitle: 'Saisissez le code élève et l\'établissement',
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LinkChildPage(),
                          ),
                        );
                        if (result != null && result is Map) {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool('parent_scan_done', true);
                          });
                          final rawId = result['id'];
                          if (rawId != null) {
                            final childId = rawId is int ? rawId : int.tryParse(rawId.toString());
                            if (childId != null) {
                              await ParentService.addLocallyVerifiedChild(childId);
                              print('[DEBUG] addLocallyVerifiedChild appelé avec id=$childId');
                            }
                          }
                          setState(() { _forceAddChild = false; });
                          await _loadLinkedChildren();
                        }
                      },
                    ),
                    const SizedBox(height: 20), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryModal() {
    String? selectedSchool;
    final schools = [
      'Lycée Léon Mba',
      'Collège Colbert',
      'Lycée Sainte Marie',
      'Lycée d\'Etat',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Saisie manuelle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Champs Manuels
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Code Élève',
                          prefixIcon: const Icon(Icons.pin),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedSchool,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'établissement',
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: schools.map((school) {
                          return DropdownMenuItem(
                            value: school,
                            child: Text(school),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSchool = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enfant ajouté avec succès ! (Démo)',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Valider',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerifyChildModal(Map<String, dynamic> child) {
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
                  const Icon(Icons.lock_outline, size: 50, color: Colors.orange),
                  const SizedBox(height: 15),
                  const Text(
                    'Débloquer l\'accès',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Veuillez entrer le code secret inscrit sur le carnet de ${child['prenom'] ?? child['name']} pour vérifier votre identité.',
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
                                setModalState(() => errorText = 'Veuillez entrer le code secret');
                                return;
                              }
                              setModalState(() {
                                isLoading = true;
                                errorText = null;
                              });

                              final parentId = await AuthService.getParentId();
                              if (parentId != null) {
                                final success = await ParentService.verifyChildAccess(
                                  parentId,
                                  child['id'] ?? child['raw_id'],
                                  code,
                                );

                                if (!mounted) return;
                                if (success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Accès débloqué avec succès !'),
                                      backgroundColor: AppTheme.forestGreen,
                                    ),
                                  );
                                  // Recharger la liste des enfants pour mettre is_verified à true
                                  _loadLinkedChildren();
                                } else {
                                  setModalState(() {
                                    isLoading = false;
                                    errorText = 'Code secret incorrect ou erreur serveur.';
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
                              'Vérifier et Débloquer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
