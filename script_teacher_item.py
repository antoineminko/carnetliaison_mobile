import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update itemBuilder in _buildTeachersTab
teacher_item_builder_old = '''    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final Color tColor = teacher['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: tColor.withOpacity(0.12),
                child: Text(
                  teacher['name'].split(' ').last[0],
                  style: TextStyle(color: tColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      teacher['subject'],
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentPage(
                        source: AppointmentSource.parent,
                        targetName: teacher['name'],
                        studentName: widget.child['name'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2596be),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('RDV', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );'''

teacher_item_builder_new = '''    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final String fullName = " ".trim();
        final String subject = teacher['matiere'] ?? 'Matière Inconnue';
        final bool isPrincipal = teacher['is_principal'] == true;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPrincipal ? AppTheme.seaBlue.withOpacity(0.5) : Colors.grey[100]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.seaBlue.withOpacity(0.12),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isPrincipal) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.seaBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Principal', style: TextStyle(color: Colors.white, fontSize: 10)),
                          )
                        ]
                      ],
                    ),
                    Text(
                      subject,
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentPage(
                        source: AppointmentSource.parent,
                        targetName: fullName,
                        studentName: widget.child['prenom'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2596be),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('Prendre RDV', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );'''

content = content.replace(teacher_item_builder_old, teacher_item_builder_new)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
