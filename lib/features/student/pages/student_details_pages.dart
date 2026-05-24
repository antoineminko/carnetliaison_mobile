import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class StudentAnnouncementDetailPage extends StatelessWidget {
  final String title;
  const StudentAnnouncementDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Annonce École')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text('Détails de l\'annonce administrative ici...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class StudentNewsDetailPage extends StatelessWidget {
  final String title;
  const StudentNewsDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vie de l\'école')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text('Article complet sur la vie de l\'établissement...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class LessonDetailPage extends StatelessWidget {
  final String title;
  final String? subject;
  final String? date;
  
  const LessonDetailPage({
    super.key, 
    required this.title, 
    this.subject, 
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Détail du cours', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.seaBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subject ?? 'Matière',
                      style: const TextStyle(
                        color: AppTheme.seaBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(
                        date ?? '24 Février 2026',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(
                        'M. Obiang',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RÉSUMÉ DE LA SÉANCE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Aujourd\'hui nous avons abordé les concepts fondamentaux de la leçon. '
                      'Nous avons vu la définition théorique ainsi que plusieurs exemples d\'application directe. '
                      '\n\nPoints clés :\n• Introduction aux concepts\n• Méthodologie de résolution\n• Exercices pratiques en classe',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textDark,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'DOCUMENTS ET LIENS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Fake Attachment 1: PDF
                  _buildAttachmentTile(
                    title: 'Support de cours.pdf',
                    subtitle: '2.4 MB • PDF Document',
                    icon: Icons.picture_as_pdf,
                    color: Colors.redAccent,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Fake Attachment 2: Video Link
                  _buildAttachmentTile(
                    title: 'Vidéo explicative (Lien externe)',
                    subtitle: 'YouTube • 12:45 min',
                    icon: Icons.play_circle_fill,
                    color: Colors.blue,
                    isExternal: true,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Fake Attachment 3: Quiz
                  _buildAttachmentTile(
                    title: 'Auto-évaluation interactive',
                    subtitle: 'Quiz corrigé en ligne',
                    icon: Icons.quiz_rounded,
                    color: AppTheme.sunYellow,
                    isExternal: true,
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_for_offline, size: 20),
                          label: const Text('Tout télécharger'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.seaBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppTheme.seaBlue.withOpacity(0.3)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.seaBlue),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isExternal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isExternal ? Icons.open_in_new : Icons.file_download_outlined,
              color: AppTheme.seaBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class HomeworkDetailPage extends StatelessWidget {
  final String title;
  final String? subject;
  final String? teacher;
  final String? type; // Individuel / Groupe
  final String? dueDate;

  const HomeworkDetailPage({
    super.key, 
    required this.title,
    this.subject,
    this.teacher,
    this.type,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Détail du Devoir', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.seaBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'DEVOIR DE MAISON - ${type?.toUpperCase() ?? 'INDIVIDUEL'}',
                style: const TextStyle(
                  color: AppTheme.seaBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Title & Subject
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 5),
            Text(
              subject ?? 'Mathématiques',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 25),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person_outline, 'Enseignant', teacher ?? 'Mme Eyi'),
                  const Divider(height: 30),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Date de rendu', dueDate ?? 'Lundi 02 Mars'),
                  const Divider(height: 30),
                  _buildInfoRow(Icons.group_outlined, 'Format', type ?? 'Individuel'),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Instructions
            const Text(
              'CONSIGNES DU PROFESSEUR',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '1. Lire attentivement l\'énoncé du chapitre 4.\n'
                '2. Résoudre les exercices 12, 14 et 15 page 82.\n'
                '3. Pour l\'exercice de groupe, veuillez soumettre un seul rapport par équipe.\n\n'
                'N.B: La précision des calculs sera prise en compte dans la notation.',
                style: TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.6),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                label: const Text('REMETTRE MON DEVOIR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.seaBlue, size: 20),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final String name;
  final Color color;
  final bool isGroup;

  const ChatDetailPage({
    super.key, 
    required this.name, 
    this.color = AppTheme.seaBlue,
    this.isGroup = false,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Bonjour Yannick, as-tu bien reçu le support de cours ?', 'isMe': false, 'time': '10:00'},
    {'text': 'Oui Monsieur, je suis en train de le lire.', 'isMe': true, 'time': '10:05'},
    {'text': 'Parfait. N\'hésite pas si tu as des questions.', 'isMe': false, 'time': '10:07'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 70,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.color.withOpacity(0.1),
              child: Icon(widget.isGroup ? Icons.groups : Icons.person, color: widget.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text('en ligne', style: TextStyle(color: AppTheme.forestGreen, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam, color: AppTheme.seaBlue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call, color: AppTheme.seaBlue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.seaBlue), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isMe'], msg['time']);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.seaBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMe ? 15 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 15),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add, color: AppTheme.seaBlue), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Tapez votre message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.seaBlue),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _messages.add({
                    'text': _messageController.text,
                    'isMe': true,
                    'time': 'Aujourd\'hui',
                  });
                  _messageController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

class OrientationPage extends StatelessWidget {
  const OrientationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Orientation Métier', style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOrientationCard(
            context,
            'BAC SÉRIE C (Sciences Exactes)',
            'Le Bac C ouvre les portes des métiers de haute technicité.',
            [
              'Ingénierie (Civil, Pétrole, Informatique)',
              'Architecture & Urbanisme',
              'Finance de marché & Actuariat',
              'Enseignement supérieur & Recherche',
              'Intelligence Artificielle & Data Science',
            ],
            AppTheme.seaBlue,
          ),
          const SizedBox(height: 15),
          _buildOrientationCard(
            context,
            'BAC SÉRIE A1 (Lettres & Langues)',
            'Le Bac A1 est idéal pour les carrières juridiques et de communication.',
            [
              'Droit (Avocat, Notaire, Magistrat)',
              'Diplomatie & Relations Internationales',
              'Journalisme & Communication',
              'Ressources Humaines',
              'Interprétariat & Traduction',
            ],
            Colors.purple,
          ),
          const SizedBox(height: 15),
          _buildOrientationCard(
            context,
            'BAC SÉRIE D (Sciences Expérimentales)',
            'Le Bac D est le parcours privilégié pour le monde de la santé.',
            [
              'Médecine, Pharmacie, Odontologie',
              'Agronomie & Environnement',
              'Biotechnologies',
              'Géologie & Mines',
              'Gestion de projets de santé',
            ],
            AppTheme.forestGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationCard(BuildContext context, String title, String desc, List<String> careers, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          const Text('DÉBOUCHÉS MAJEURS :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(c, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
