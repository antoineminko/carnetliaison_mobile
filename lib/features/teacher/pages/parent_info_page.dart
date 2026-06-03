import 'package:flutter/material.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/parent/pages/chat_page.dart';
import 'package:app_mobile/features/teacher/pages/create_appointment_page.dart';

class ParentInfoPage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const ParentInfoPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentInfoPage> createState() => _ParentInfoPageState();
}

class _ParentInfoPageState extends State<ParentInfoPage> {
  bool _isLoading = true;
  List<dynamic> _parents = [];
  Map<String, dynamic>? _eleveInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchParentInfo();
  }

  Future<void> _fetchParentInfo() async {
    try {
      final response = await ApiClient.instance.get('/enseignants/student/${widget.studentId}/info');
      if (response.data['success']) {
        setState(() {
          _parents = response.data['parents'] ?? [];
          _eleveInfo = response.data['eleve'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Impossible de charger les informations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dossier Élève'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildStudentBanner(),
        Expanded(
          child: _parents.isEmpty
              ? const Center(child: Text('Aucun parent assigné à cet élève.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _parents.length,
                  itemBuilder: (context, index) {
                    return _buildParentCard(_parents[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentBanner() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(
            widget.studentName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (_eleveInfo != null && _eleveInfo!['age'] != null)
            Text(
              '${_eleveInfo!['age']} ans',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.family_restroom, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${parent['prenom']} ${parent['nom']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        parent['relation'] ?? 'Parent',
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (parent['email'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(parent['email'], style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            if (parent['telephone'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(parent['telephone'], style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            conversation: {
                              'parent_id': parent['id'],
                              'parent_name': '${parent['prenom']} ${parent['nom']}',
                              'subject': 'Discussion avec ${parent['prenom']} ${parent['nom']}',
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6), // AppTheme.seaBlue equivalent
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAppointmentPage(
                            studentId: widget.studentId,
                            parentId: parent['id'],
                            parentName: '${parent['prenom']} ${parent['nom']}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Rendez-vous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6), // AppTheme.seaBlue equivalent
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
