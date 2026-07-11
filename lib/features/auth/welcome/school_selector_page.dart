import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';

class SchoolSelectorPage extends StatefulWidget {
  const SchoolSelectorPage({super.key});

  @override
  State<SchoolSelectorPage> createState() => _SchoolSelectorPageState();
}

class _SchoolSelectorPageState extends State<SchoolSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _ecoles = [];
  bool _isLoading = false;

  Future<void> _searchSchools(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiClient.instance.get(
        '/ecoles/search',
        queryParameters: {'q': query},
      );
      setState(() {
        _ecoles = response.data['data'] ?? [];
      });
    } catch (e) {
      debugPrint("Erreur recherche école: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSchool(dynamic ecole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('school_code', ecole['code']);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundWrapper(
        isSubtle: false,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Image.asset('assets/icons/schooly_logo.png', height: 60),
                    const SizedBox(height: 24),
                    const Text(
                      'Trouvez votre école',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recherchez par nom ou ville',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (value.length > 2 || value.isEmpty) {
                      _searchSchools(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Nom de l\'établissement...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.primaryBlue,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Results list
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue,
                          ),
                        )
                      : _ecoles.isEmpty
                      ? _searchController.text.isNotEmpty
                            ? const Center(
                                child: Text(
                                  "Aucun établissement trouvé.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Commencez à taper pour rechercher...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _ecoles.length,
                          itemBuilder: (context, index) {
                            final ecole = _ecoles[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Icons.school,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                title: Text(
                                  ecole['nom'] ?? 'École',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  ecole['ville'] ?? 'Ville non renseignée',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                                onTap: () => _selectSchool(ecole),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
