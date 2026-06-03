import 'package:flutter/material.dart';
import 'package:app_mobile/features/teacher/pages/attendance_view.dart';
import 'package:app_mobile/features/teacher/pages/textbook_view.dart';
import 'package:app_mobile/features/teacher/pages/teacher_student_list_page.dart';
import 'package:app_mobile/features/teacher/pages/teacher_messages_page.dart';
import 'package:app_mobile/features/teacher/pages/grades_entry_view.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class ClassDashboardPage extends StatefulWidget {
  final int classId;
  final String className;
  final String session;
  final String subject;
  final int teacherId;
  final int studentCount;
  final String schoolName;

  const ClassDashboardPage({
    super.key,
    required this.classId,
    required this.className,
    required this.session,
    required this.subject,
    required this.teacherId,
    required this.studentCount,
    this.schoolName = 'STE THÉRÈSE',
  });

  @override
  State<ClassDashboardPage> createState() => _ClassDashboardPageState();
}

class _ClassDashboardPageState extends State<ClassDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Espace Classe',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER CARD
            _buildHeaderCard(),

            const SizedBox(height: 25),

            // 2. QUICK SHORTCUTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RACCOURCIS RAPIDES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textGrey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                    children: [
                      _buildShortcutCard(
                        title: 'Résultats',
                        icon: Icons.analytics_outlined,
                        color: AppTheme.seaBlue,
                        onTap: () => _navigateToPage(
                          'Gestion des Résultats',
                          const GradesEntryView(),
                        ),
                      ),
                      _buildShortcutCard(
                        title: 'Faire l\'appel',
                        icon: Icons.person_add_alt_1_rounded,
                        color: AppTheme.forestGreen,
                        onTap: () => _navigateToPage(
                          'Appel - ${widget.className}',
                          AttendanceView(
                            studentCount: widget.studentCount,
                            className: widget.className,
                            classeId: widget.classId,
                          ),
                        ),
                      ),
                      _buildShortcutCard(
                        title: 'Cahier de texte',
                        icon: Icons.menu_book_rounded,
                        color: AppTheme.sunYellow,
                        onTap: () => _navigateToPage(
                          'Cahier de texte',
                          TextbookView(
                            className: widget.className,
                            subject: widget.subject,
                          ),
                        ),
                      ),
                      _buildShortcutCard(
                        title: 'Saisie Notes',
                        icon: Icons.grade_rounded,
                        color: AppTheme.seaBlue,
                        onTap: () => _navigateToPage(
                          'Saisie des Notes',
                          const GradesEntryView(),
                        ),
                      ),
                      _buildShortcutCard(
                        title: 'Messages',
                        icon: Icons.chat_bubble_rounded,
                        color: AppTheme.forestGreen,
                        onTap: () => _navigateToPage(
                          'Messages',
                          const TeacherMessagesPage(),
                        ),
                      ),
                      _buildShortcutCard(
                        title: 'Signaler',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherStudentListPage(
                                classId: widget.classId,
                                teacherId: widget.teacherId,
                                className: widget.className,
                                studentCount: widget.studentCount,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. DAILY EVENTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ÉVÉNEMENTS DU JOUR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textGrey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.seaBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTimelineItem(
                    time: '08:00',
                    title: 'Mathématiques',
                    subtitle: 'Calcul mental & Géométrie',
                    isActive: true,
                  ),
                  _buildTimelineItem(
                    time: '12:00',
                    title: 'Pause',
                    subtitle: '',
                    isBreak: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(String title, Widget view) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(title, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: view,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seaBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'COURS - ${widget.schoolName.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Classe : ${widget.className}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.subject,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                '${widget.studentCount} Élèves dans la classe',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withOpacity(0.9), // Harmonized Forest Green pill
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Session : ${widget.session} (08:00 - 12:30)',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherStudentListPage(
                        classId: widget.classId,
                        teacherId: widget.teacherId,
                        className: widget.className,
                        studentCount: widget.studentCount,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Voir la liste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    bool isActive = false,
    bool isBreak = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Time Column
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppTheme.seaBlue : AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Content Column
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBreak ? const Color(0xFFF1F5F9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isBreak
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: isBreak
                  ? Row(
                      children: [
                        const Icon(Icons.coffee_rounded, color: Color(0xFF718096), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
