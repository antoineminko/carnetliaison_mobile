import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';

class TeacherStudentListPage extends StatefulWidget {
  final String className;
  final int studentCount;

  const TeacherStudentListPage({
    super.key,
    required this.className,
    required this.studentCount,
  });

  @override
  State<TeacherStudentListPage> createState() => _TeacherStudentListPageState();
}

class _TeacherStudentListPageState extends State<TeacherStudentListPage> {
  @override
  Widget build(BuildContext context) {
    // Mock students data
    final List<Map<String, String>> students = List.generate(
      widget.studentCount,
      (index) => {
        'name': index == 0 ? 'Junior' : 'Élève Nom ${index + 1}',
        'id': '2024-${(100 + index).toString()}',
        'image': index == 0 ? 'assets/images/profil/eleve3.jpg' : 'assets/images/eleve.png',
        'parent': 'M. Ewosso D-Gall',
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Élèves - ${widget.className}',
          style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.seaBlue, size: 18),
                const SizedBox(width: 10),
                Text(
                  '${widget.studentCount} élèves inscrits dans cette classe',
                  style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.82,
              ),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(context, student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, String> student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.seaBlue.withOpacity(0.1), width: 2),
              image: DecorationImage(
                image: AssetImage(student['image']!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student['name']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            student['id']!,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                context: context,
                icon: Icons.bar_chart_rounded,
                color: AppTheme.sunYellow,
                tooltip: 'Statistiques',
                onTap: () => _showStatsDialog(context, student),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                context: context,
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
                tooltip: 'Signaler Incident',
                onTap: () => _showIncidentDialog(context, student),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                context: context,
                icon: Icons.person_search_rounded,
                color: AppTheme.seaBlue,
                tooltip: 'Info Parent',
                onTap: () => _showParentDialog(context, student),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Statistiques : ${student['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (student['name'] == 'Junior') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.sunYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.sunYellow.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_down, color: AppTheme.sunYellow),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Baisse de performance détectée en Sciences.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              _buildStatRow('Moyenne Générale', student['name'] == 'Junior' ? '09.5/20' : '14.2/20'),
              _buildStatRow('Devoirs Rendus', student['name'] == 'Junior' ? '65%' : '98%'),
              _buildStatRow('Participation', student['name'] == 'Junior' ? 'Faible' : 'Excellente'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (student['name'] == 'Junior')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showParentDialog(context, student);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.seaBlue, foregroundColor: Colors.white),
              child: const Text('Discuter avec le parent'),
            ),
        ],
      ),
    );
  }

  void _showIncidentDialog(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Signaler un incident'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Motif de l\'incident',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              const Text('Gravité :', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilterChip(label: const Text('Mineur'), onSelected: (_) {}),
                  FilterChip(label: const Text('Sérieux'), onSelected: (_) {}, selected: true, selectedColor: Colors.red[100]),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incident enregistré. Fiche parent affichée automatiquement.')),
              );
              _showParentDialog(context, student);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Valider & Prévenir Parent'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  void _showParentDialog(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Parent de ${student['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['parent']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Père', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildContactRow(Icons.phone, '+241 07 45 89 12'),
              const SizedBox(height: 10),
              _buildContactRow(Icons.email, 'dgall.ewosso@email.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentPage(
                    source: AppointmentSource.teacher,
                    targetName: student['parent']!,
                    studentName: student['name'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sunYellow,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Convoquer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.seaBlue),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
