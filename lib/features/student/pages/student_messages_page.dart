import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'student_details_pages.dart';

class StudentMessagesPage extends StatelessWidget {
  const StudentMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Messagerie', style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                
                // Section Administratif
                _buildSectionHeader('ADMINISTRATION & INFOS'),
                _buildChatTile(
                  context,
                  name: 'Secrétariat Général',
                  lastMsg: 'Note: Convocation réunion parents-profs.',
                  time: 'Hier',
                  count: 0,
                  isGroup: true,
                  color: AppTheme.forestGreen,
                ),
                _buildChatTile(
                  context,
                  name: 'Surveillance Générale',
                  lastMsg: 'Rappel : Le port de la tenue est obligatoire.',
                  time: '26 Fév',
                  count: 0,
                  isGroup: true,
                  color: Colors.redAccent,
                ),
                
                const SizedBox(height: 25),
                
                // Section Groupe Classe
                _buildSectionHeader('GROUPES DE CLASSE'),
                _buildChatTile(
                  context,
                  name: 'Ma Classe (Terminale A1)',
                  lastMsg: 'Kévin: Quelqu\'un a les exos de philo ?',
                  time: '12:45',
                  count: 3,
                  isGroup: true,
                  color: AppTheme.seaBlue,
                ),
                _buildChatTile(
                  context,
                  name: 'Coopération Mutuelle',
                  lastMsg: 'Awa: On se voit à la bibliothèque ?',
                  time: '24 Fév',
                  count: 1,
                  isGroup: true,
                  color: AppTheme.sunYellow,
                ),
                
                const SizedBox(height: 25),
                
                // Section Enseignants
                _buildSectionHeader('MES ENSEIGNANTS'),
                _buildChatTile(
                  context,
                  name: 'Mme Eyi (Mathématiques)',
                  lastMsg: 'N\'oubliez pas votre livre demain.',
                  time: 'Hier',
                  count: 0,
                  isGroup: false,
                  color: Colors.purple,
                ),
                _buildChatTile(
                  context,
                  name: 'M. Iboga (Philosophie)',
                  lastMsg: 'Votre dissertation est excellente.',
                  time: 'Lun',
                  count: 0,
                  isGroup: false,
                  color: Colors.orange,
                ),

                const SizedBox(height: 25),
                
                // Section Sociologue / Orientation
                _buildSectionHeader('ORIENTATION & CONSEIL'),
                _buildChatTile(
                  context,
                  name: 'M. Makosso (Sociologue)',
                  lastMsg: 'ANALYSE ORIENTATION : Guide post-bac...',
                  time: 'Ven',
                  count: 1,
                  isGroup: false,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrientationPage())),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.seaBlue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildFilterChip('Tous', true),
            _buildFilterChip('Enseignants', false),
            _buildFilterChip('Administration', false),
            _buildFilterChip('Groupe classe', false),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrientationPage())),
              child: _buildFilterChip('Orientation Métier', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.seaBlue : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isSelected ? AppTheme.seaBlue : Colors.grey[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMsg,
    required String time,
    required int count,
    required bool isGroup,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(name: name, color: color, isGroup: isGroup))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(isGroup ? Icons.groups : Icons.person, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark, overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMsg,
                    style: TextStyle(color: count > 0 ? AppTheme.textDark : Colors.grey[600], fontSize: 13, fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
